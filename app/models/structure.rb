# Structure class
class Structure
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user

end
