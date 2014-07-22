json.array!(@measure_descriptions) do |measure_description|
  json.extract! measure_description, :id
  json.url measure_description_url(measure_description, format: :json)
end
