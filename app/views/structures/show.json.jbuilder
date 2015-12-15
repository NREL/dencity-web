json.set! :id, @structure.id.to_s
json.set! :user_id, @structure.user.id.to_s
json.set! :analysis_id, @structure.analysis.id.to_s
json.extract! @structure, :user_defined_id, :created_at, :updated_at

@structure.attributes.keys.each do |key|
  unless ['created_at', 'updated_at', 'analysis_id', 'related_files', '_id', 'user_defined_id', 'user_id'].include? key
    json.set! key, @structure[key]
  end
end

json.set! :related_files do
	json.array!(@structure.related_files) do |file|
	  file.attributes.each do |fk, fv|
	    if fk == '_id'
	      json.set! :id, fv.to_s
	      @file_id = fv.to_s
	    elsif fk == 'uri'
	      json.set! :uri, download_file_structure_url(@structure.id, related_file_id: file.id) 
	    else
	    	json.set! fk, fv
	    end
	  end
	end
end

json.set! :measure_instances do
  json.array!(@structure.measure_instances) do |measure|
  	json.extract! measure, :uuid, :version_id, :uri, :arguments
  end
end

if defined?(warnings)
	json.set! :warnings do
  	json.array!(warnings) do |warning|
  		json.set! :warning, warning
  	end
  end
end
