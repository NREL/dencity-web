json.array!(@analyses) do |analysis|
  json.extract! analysis, :id
  json.url analysis_url(analysis, format: :json)
end
