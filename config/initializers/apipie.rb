Apipie.configure do |config|
  config.app_name                = "DEnCity"
  config.app_info["1"] 				   = "API for searching and uploading structures and related data to DEnCity."
  config.api_base_url            = "/api"
  config.doc_base_url            = "/apidocs"
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
  config.default_version = "1"
  config.validate = false
end
