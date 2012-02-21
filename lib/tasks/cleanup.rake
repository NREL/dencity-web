
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

desc 'delete tmp files in /public/tmpdata'
task :delete_tmpdata => :environment do
  
  Dir.glob("#{RAILS_ROOT}/public/tmpdata/*.csv") do |file|
    File.delete(file)
  end

end