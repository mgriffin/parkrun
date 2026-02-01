Sequel.migration do
  change do
    create_table(:distances) do
      primary_key :id
      foreign_key :start_id, :events
      foreign_key :finish_id, :events
      Float :distance, null: false
      Float :duration, null: false
    end
  end
end
