# RelatedFile class
class RelatedFile
  include Mongoid::Document
  include Mongoid::Timestamps

  field :file_type, type: String # the kind of file (HTML, CSV, etc)
  field :file_name, type: String
  field :file_size, type: Integer # kb
  field :file_time, type: Date
  field :file_modified_time, type: Date
  field :uri, type: String

  embedded_in :structure

  def self.add_from_path(file_path)
    if File.exist? "#{Rails.root}/#{file_path}"
      new_path = "#{Rails.root}/#{file_path}"
      rf = RelatedFile.new
      rf.uri = file_path
      rf.file_name = File.basename(new_path)
      rf.file_type = File.extname(rf.file_name).gsub('.', '').downcase
      rf.file_time = File.ctime(new_path).utc
      rf.file_modified_time = File.mtime(new_path).utc
      rf.file_size = (File.size(new_path) / 1024).to_i

      return rf
    else
      logger.error "Could not find file path: #{file_path} to add to RelatedFile"
    end

    false
  end
end
