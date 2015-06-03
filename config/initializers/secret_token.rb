# Be sure to restart your server when you modify this file.

# Make sure your secret_key_base is kept private if you're sharing your code publicly.
if Rails.env.development? or Rails.env.test?
  Dencity::Application.config.secret_key_base = '887805f793ec6ff95d3b71f52288e21ccc9168b80dd12728d30a316f604a8f6e530bbaab01e668ca4a4db53fc24f735eebbffe14c1056e3c834cec7ae8b63357'
else # for docker and/or production
  Dencity::Application.config.secret_key_base = ENV['SECRET_KEY_BASE']
end