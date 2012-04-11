
desc 'add created_at time to edifices'
task :add_created_time => :environment do

  edies = Edifice.find(:all)
  edies.each do |edi|
    if edi.created_at.nil?
      #extract from unique_name
      name = edi.unique_name
      time = name.gsub('Building', '')
      time = time.gsub('-' , ' ')
      time = time.insert(4, '-')
      time = time.insert(7, '-')
      time = time.insert(13, ':')
      time = time.insert(16, ':')
      #save time
      edi.created_at = Time.parse(time)
      edi.save       
    end
  end
end

desc 'strip lat/long from descriptors into edifices coordinates'
task :get_coordinates => :environment do

  edies = Edifice.find(:all)
  edies.each do |edi|
    edi.get_coordinates_v1()
  end

end

desc 'backfill data: hardcode missing lat/lng/coords'
task :add_missing_coordinates => :environment do
  edies = Edifice.find(:all)
  edies.each do |edi|
    edi.add_missing_coordinates_v1()
  end
end


desc 'add uuids to older records that do not have them'
task :add_uuids => :environment do
  edis = Edifice.find(:all)
  edis.each do |edi|
    if edi[:uuid].nil?
      #puts "uuid is nil for building #{edi._id}"
      edi[:uuid] = edi.unique_name
      edi.save
    end
  end
end

desc 'delete tmp files in /public/tmpdata'
task :delete_tmpdata => :environment do
  
  Dir.glob("#{RAILS_ROOT}/public/tmpdata/*.csv") do |file|
    File.delete(file)
  end

end

desc 'fix exponent problem for tdv and tdv intensity'
task :fix_exponents => :environment do

  edies = Edifice.find(:all)
  edies.each do |edi|
    if !edi['time_dependent_valuation'].nil?
      edi['time_dependent_valuation'] = edi['time_dependent_valuation'].gsub('e ', 'e+')
    end
    if !edi['time_dependent_valuation_intensity'].nil?
      edi['time_dependent_valuation_intensity'] = edi['time_dependent_valuation_intensity'].gsub('e ', 'e+')
    end
    edi.save
  end      
end