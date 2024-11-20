class Users::SessionsController < Devise::SessionsController
  def create
    super do |resource|
      response.set_header('Authorization', "Bearer #{JWT.encode(resource.jwt_payload, ENV['JWT_SECRET'])}")
    end
  end
end
