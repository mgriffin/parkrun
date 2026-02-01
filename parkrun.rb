require "faraday"
require "json"
require "sequel"

DB = Sequel.connect("sqlite://db/parkrun.sqlite")
Sequel.extension :migration
Sequel::Migrator.check_current(DB, './db/migrations')

class Event < Sequel::Model
  one_to_many :distances
end

class Distance < Sequel::Model
  many_to_one :start, foreign_key: :start_id, class: :Event
  many_to_one :finish, foreign_key: :finish_id, class: :Event
end

class Itinerary
  attr_reader :distance, :duration, :stops

  def initialize(distance:, duration:, stops:)
    @distance = distance
    @duration = duration
    @stops = stops
  end
end

class Float
  def to_km
    (self / 1000).round
  end

  def to_human_time
    secs = self.round
    [[60, :seconds], [60, :minutes], [24, :hours], [Float::INFINITY, :days]].map do |count, name|
      next unless secs > 0

      secs, number = secs.divmod(count)
      "#{number.to_i} #{number == 1 ? name.to_s.delete_suffix('s') : name}" unless number.to_i == 0
    end.compact.reverse.join(', ')
  end
end

parkrun_events_file = "events.json"

File.open(parkrun_events_file, "w") do |f|
  response = Faraday.get("https://images.parkrun.com/events.json")
  f.puts response.body
end unless File.exist?(parkrun_events_file)

json = JSON.load_file(parkrun_events_file)

puts "Getting county information"
### Ireland has a country code of 42
json.dig("events", "features").each { |j|
  next unless j["properties"]["countrycode"] == 42

  next unless Event.where(slug: j.dig("properties", "eventname")).all.empty?

  longitude = j.dig("geometry", "coordinates").first
  latitude = j.dig("geometry", "coordinates").last

  url = "https://nominatim.openstreetmap.org/reverse?lat=#{latitude}&lon=#{longitude}&format=json"
  response = Faraday.get(url)

  body = JSON.parse(response.body)
  county = body.dig("address", "county")&.sub("County ", "") || body.dig("address", "city")

  Event.create { |e|
    e.slug = j.dig("properties", "eventname")
    e.longname = j.dig("properties", "EventLongName")
    e.shortname = j.dig("properties", "EventShortName")
    e.county = county
    e.latitude = latitude
    e.longitude = longitude
  }
}

mayo_events = Event.where(county: "Mayo").all

puts "Calculating distances"
mayo_events.combination(2) do |source, target|
  next unless Distance.where(start_id: source.id, finish_id: target.id).all.empty?

  url = "http://router.project-osrm.org/route/v1/driving/#{source.longitude},#{source.latitude};#{target.longitude},#{target.latitude}"
  response = Faraday.get(url)

  json = JSON.parse response.body
  Distance.create { |d|
    d.start_id = source.id
    d.finish_id = target.id
    d.distance = json.dig("routes", 0, "distance")
    d.duration = json.dig("routes", 0, "duration")
  }

  distance = ((JSON.parse(response.body).dig("routes", 0, "distance")) / 1000).round
  puts "#{source.longname} to #{target.longname} is #{distance}km"
end

puts "Calculating permutations"
sorted_by_distance = mayo_events.permutation.map { |events|
  distance = 0
  duration = 0
  stops = events.map(&:shortname).join(", ")

  events.each_with_index { |event, i|
    next if events.length == i + 1

    # Yuck, I've only stored one direction in the database, so sometimes
    # the expected start is the finish place in the database and vice versa
    travel = Distance.where(start: event, finish: events[i + 1]).first || Distance.where(start: events[i + 1], finish: event).first
    distance += travel.distance
    duration += travel.duration
    #puts "#{event.longname} to #{events[i + 1].longname} is #{travel.distance.to_km}"
  }

  Itinerary.new(distance:, duration:, stops:)
}.sort_by { |e| e.distance }

puts "The shortest driving distance is #{sorted_by_distance.first.distance.to_km}km for #{sorted_by_distance.first.stops}, which would take #{sorted_by_distance.first.duration.to_human_time}"
puts "The longest driving distance is #{sorted_by_distance.last.distance.to_km}km for #{sorted_by_distance.last.stops}, which would take #{sorted_by_distance.last.duration.to_human_time}"
