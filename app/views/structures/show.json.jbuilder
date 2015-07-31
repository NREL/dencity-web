json.set! :id, @structure.id.to_s
json.extract! @structure, :user_defined_id, :building_type, :building_area, :created_at, :updated_at

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