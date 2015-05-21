class Attachment
  include Mongoid::Document
  include Mongoid::Timestamps

  # Fields
  field :filename, type: String
  field :type, type: String
  field :data, type: Hash

  # Relations
  belongs_to :structure
end
