class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # , :encryptable, :confirmable, :lockable, :rememberable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :token_authenticatable,
         :recoverable, :trackable, :validatable

  ## Database authenticatable
  field :email,              :type => String, :null => false
  field :encrypted_password, :type => String, :null => false

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ## Token authenticatable
  field :authentication_token, :type => String

  # Custom
  field :username, :type => String
  field :api_key, :type => String
  field :role, :type => String
  
  #possible roles
  #admin
  
  attr_accessible :email, :password, :password_confirmation
  

  
  # Indexes

  # Relationships
  references_many :edifices
  
  # Class Methods
  def admin?
    if self.role == 'admin'
      return true
    else
      return false
    end
  end
end
