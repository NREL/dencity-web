class State
  include Mongoid::Document
  
  field :name, :type => String
  field :abbr, :type => String
end
