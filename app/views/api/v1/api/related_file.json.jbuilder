json.set! :id, @rf.id.to_s
json.set! :structure_id, @structure.id.to_s
json.extract! @rf, :file_name, :file_size, :file_type, :uri, :created_at, :updated_at
