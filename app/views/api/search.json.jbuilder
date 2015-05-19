
json.set! :total_results, @total_results
json.set! :results_per_page, @results_per_page
json.set! :current_page, @page
json.set! :return_only, @return_only
json.set! :filters do
	json.array!(@filters) do |f|
	  json.extract! f, :name, :value, :operator
	end
end	
json.set! :results do
	json.array!(@results) do |res|
	  res.attributes.each_pair do |k, v|
	  	if k == '_id'
	  		json.set! :id, v.to_s
	  	else
	  		json.set! k, v
	  	end
	  end

	end
end	
