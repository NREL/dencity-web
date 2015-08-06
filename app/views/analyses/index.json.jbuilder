json.array!(@analyses) do |analysis|
  json.set! :id, analysis.id.to_s
  json.extract! analysis, :name, :structures_count, :created_at, :updated_at
  json.set! :user_id, analysis.user_id.to_s
  json.url analysis_url(analysis, format: :json)
end
