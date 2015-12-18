
json.set! :total_results, @total_results
#json.set! :results_per_page, @results_per_page
json.set! :measure_filters do
  json.array!(@measures) do |m|
    json.extract! m, :uuid, :version_id, :arguments
  end
end

json.set! :structure_ids do
  json.array! @results.map(&:_id).map(&:to_s)
end

=begin
@bld_id = nil
json.set! :results do
  json.array!(@results) do |res|
    res.attributes.each_pair do |k, v|
      if k == '_id'
        json.set! :id, v.to_s
        @bld_id = v.to_s
      elsif k == 'related_files'
        json.set! :related_files do
          json.array!(v) do |file|

           file.each_pair do |fk, fv|
              if fk == '_id'
                json.set! :id, fv.to_s
                @file_id = fv.to_s
              elsif fk == 'file_name'
                json.set! fk, fv  
              elsif fk == 'uri'
                json.set! :uri, download_file_structure_url(@bld_id, related_file_id: @file_id) 
              end
            end
          end
        end  
      else
        json.set! k, v
      end
    end
  end
end
=end
