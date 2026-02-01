Sequel.migration do
  change do
    create_table(:events) do
      primary_key :id
      String :slug, null: false
      String :longname
      String :shortname
      String :county
      Float :latitude, null: false
      Float :longitude, null: false
    end
  end
end
