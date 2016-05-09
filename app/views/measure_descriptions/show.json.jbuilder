json.set! :measure_description do
  json.set! :id, @measure_description.id.to_s
   @measure_description.attributes.keys.each do |key|
    unless %w(_id).include? key
      json.set! key, @measure_description[key]
    end
  end
end

