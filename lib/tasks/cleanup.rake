require 'lib/overloads/float.rb'
require 'lib/overloads/string.rb'

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

desc 'add missing updated_at values'
task :add_updated_at_dates => :environment do
  cnt = 0
  done_flag = 0
  while done_flag != 1
    edies = Edifice.where("updated_at" => "").limit(200)
    puts "there are #{edies.size} matches"
    if edies.size == 0
      done_flag = 1
    end
    
    edies.each do |edi|
      cnt += 1
      puts "... #{cnt} ..." if cnt % 100 == 0
      if edi['updated_at'].nil?
        puts "updated_at: #{edi['updated_at']}, created_at: #{edi['created_at']}"
        edi['updated_at'] = edi['created_at']
        edi.save
      end
    end
  end
end

desc 'go through all the edifices and make the data strongly typed'
task :type_data => :environment do
  cnt = 0
  done_flag = 0
  
  #numToDo = Edifice.where({ 'processed_type_data' => {'$ne' => true } }).count
  #puts "number to do: #{numToDo}"
 
  #do this 1000 at a time so cursor doesn't time out
  while done_flag != 1
    edis = Edifice.where({ 'processed_type_data' => {'$ne' => true } }).limit(200)
    puts "number of records returned: #{edis.size}"
    
    if edis.size == 0
      done_flag = 1
    end
  
    #edi = Edifice.where(:uuid => "{0b3d5270-22bf-4a02-ab21-1786fde698a1}").first
    ##edi = Edifice.where(:uuid => "{d2a52d39-573f-4d9f-995b-de1f4123c09d}").first


    edis.each do |edi|
      cnt += 1
      puts "... #{cnt} ..." if cnt % 100 == 0
      edi.attributes.each do |att|
        if att.size == 2
          #puts "att0: #{att[0]}, att1: #{att[1]}"
          newval = att[1].to_s.to_value
          
          if newval.class != String
            edi[att[0]] = newval
          else
            #check attributes with exponents in them: convert to floats
            #[0-9]E-[0-9] or [0-9]E[0-9]
            theindex = newval.index(/[0-9]E-[0-9]/)
            theindex2 = newval.index(/[0-9]E[0-9]/)
            if !theindex.nil? or !theindex2.nil?
              #downcase from E to e and convert to float
              newval = newval.gsub('E', 'e').to_f
              #puts "newval: #{newval}"
              edi[att[0]] = newval
            end
          end
        end
      end

      edi.descriptor_values.each do |dv|
        dv.attributes.each do |att|
          if att.size == 2
            #puts att[0]
            newval = att[1].to_s.to_value
            if newval.class != String
              dv[att[0]] = newval
            else
              #check attributes with exponents in them: convert to floats
              #[0-9]E-[0-9] or [0-9]E[0-9]
              theindex = newval.index(/[0-9]E-[0-9]/)
              theindex2 = newval.index(/[0-9]E[0-9]/)
              if !theindex.nil? or !theindex2.nil?
                #downcase from E to e and convert to float
                newval = newval.gsub('E', 'e').to_f
                #puts "newval: #{newval}"
                dv[att[0]] = newval
              end
            end
          end
        end
        dv.save
      end
      
      edi["processed_type_data"] = true
      edi.save
    end
  end #end while loop
end
