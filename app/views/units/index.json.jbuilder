json.array!(@units) do |unit|
  json.extract! unit, :id, :machine_name, :name, :symbol
  json.url unit_url(unit, format: :json)
end
