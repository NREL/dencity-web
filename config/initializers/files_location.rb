
    # configure files path.  storage_type is set in environments/*
    if Rails.application.config.storage_type == :s3
    	RELATED_FILES_BASIC_PATH = ''
    else
    	RELATED_FILES_BASIC_PATH = '/data/related_files/'
   	end