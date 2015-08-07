json.set! :id, @user.id.to_s
json.extract! @user, :email, :created_at, :updated_at
