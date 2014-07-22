json.array!(@measure_instances) do |measure_instance|
  json.extract! measure_instance, :id
  json.url measure_instance_url(measure_instance, format: :json)
end
