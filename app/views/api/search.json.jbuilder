
json.set! :total_results, @total_results
json.set! :results_per_page, @results_per_page
json.set! :current_page, @page
json.set! :filters do
	json.array!(@filters) do |f|
	  json.extract! f, :name, :value, :operator
	end
end	
json.set! :results do
	json.array!(@results) do |res|
	  json.extract! res, :id, :building_area
	end
end	
