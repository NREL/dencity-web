#arg: extension (string)
#return: tmp_file
def get_next_tmp_file(ext)
  tmp_file = "#{Rails.root}/tmp/simulation-0.#{extension}"
  id = 0
  while File.exists?(tmp_file) do
    tmp_file = "#{Rails.root}/tmp/simulation-#{id}.#{extension}"        
    id += 1
  end
  
  return tmp_file
end

#return: openstudio model
def get_os_model()
  #need to import the basics of an IDF to run
  idf_filepath = OpenStudio::Path.new("#{Rails.root}") / OpenStudio::Path.new("lib/openstudio/templates/base.idf")
  idf_file = OpenStudio::IdfFile.load(idf_filepath, "EnergyPlus".to_IddFileType)
  base_idf = idf_file.get()
  base_workspace = OpenStudio::Workspace.new(base_idf)
  
  reverse_translator = OpenStudio::EnergyPlus::ReverseTranslator.new(base_workspace)
  os_model_trans = reverse_translator.convert
  if os_model_trans.empty?
    logger.error "Translation from EnergyPlus to Model failed"
    exit
  end
  
  # get model
  os_model = os_model_trans.get
  
  return os_model
end
