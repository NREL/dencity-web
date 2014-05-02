json.array!(@metas) do |meta|
  json.extract! meta, :id, :name, :display_name, :description, :datatype, :units, :user_defined
  json.url meta_url(meta, format: :json)
end
