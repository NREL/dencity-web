json.array!(@provenances) do |provenance|
  json.extract! provenance, :id
  json.url provenance_url(provenance, format: :json)
end
