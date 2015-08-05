json.array!(@analyses) do |analysis|
  json.set! :id, analysis.id.to_s
  json.extract! analysis, :name
  json.set! :user_id, analysis.user_id.to_s
  json.url analysis_url(analysis, format: :json)
end
