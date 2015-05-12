json.array!(@units) do |unit|
  json.extract! unit, :id, :display_name, :name, :type, :symbol
  json.url unit_url(unit, format: :json)
end
