require 'net/http'
require 'rexml/document'
require 'zip/zip'

#this first method is really broken out just for debuggin purposes.
def get_bcl_search_string(search_string, filter)
  apikey = "fM9SwvMbeWeDevZwKsgrBrXqQc5TvpSv"
  if filter == ""
    url = "http://bcl.nrel.gov/api/search/#{search_string.downcase}.xml?oauth_consumer_key=#{apikey}"
  else
    url = "http://bcl.nrel.gov/api/search/#{search_string.downcase}.xml?filters=#{filter}&oauth_consumer_key=#{apikey}"
  end 
end

def get_bcl_search(search_string, filter)
  #make sure to put in your api key here
  
  url = get_bcl_search_string(search_string, filter)
                  
  # Get XML data as a string
  xml_data = Net::HTTP.get_response(URI.parse(url)).body
  
  # Parse the XML
  doc = REXML::Document.new(xml_data)
  
  # Set up our array of data
  data = []
          
  # Fill in the data
  cnt = 0
  results = doc.elements.each('result/results/item') do |res|
    data << []

    res.elements.each('component/general/name') do |ele|
      data[cnt] << [ ele.text ]
    end
    res.elements.each('nid') do |ele|
      data[cnt] << [ ele.text ] 
    end
    
    cnt += 1
  end

  return data
end

def get_bcl_component(node_id_arr, destination_file)
  # Send our hash as a POST to our bulk downloader
  #   The bulk downloader expects a list of nids in POST, like so: nids => nid,nid,nid,nid,
  #   It will build every nid it receives into a component folder with the
  #   data file, component.xml, and any images or video, then output a zip file
  
  # also note that this is changing in the next release and we will be adding the
  # need to submit your api key to download.
  resp = Net::HTTP.post_form(URI.parse("http://bcl.nrel.gov/api/component/download"), {"nids" => node_id_arr})
  # Write the response to a file in the local directory
  file = File.new("#{destination_file}", "wb")
  file.write(resp.body)
  file.close
  
  return destination_file
end

def extract_component(comp_zip_file, destination)
  path_to_comp_file = ""

  FileUtils.mkdir_p(destination)

  Zip::ZipFile.open(comp_zip_file) { |zip_file|
   zip_file.each { |f|
     f_path=File.join(destination, f.name)
     FileUtils.mkdir_p(File.dirname(f_path))
     zip_file.extract(f, f_path) unless File.exist?(f_path)
   }
  }
  
  get_file = Pathname.glob(destination + '/bcl_download/**/*.epw')
  path_to_comp_file = get_file[0]
  
  
  return path_to_comp_file
end

