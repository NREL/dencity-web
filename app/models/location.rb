class Location
  include Mongoid::Document
  
  field :zipcode,       :type => String, :unique => true
  field :county_name,   :type => String
  field :state,         :type => String
  field :cec2009_cz,    :type => String
  field :ashrae2004_cz, :type => String
  
end
