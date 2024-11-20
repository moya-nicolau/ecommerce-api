# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :set_current_cart
  skip_before_action :authenticate_user!, only: :create

  def create
    service = UserService.new(create_params).tap(&:create)

    if service.success?
      response.set_header('Authorization', "Bearer #{JWT.encode(service.record.jwt_payload, ENV.fetch('JWT_SECRET'))}")

      render json: UserSerializer.render(service.record, root: :user), status: :created
    else
      render json: { errors: service.errors }, status: :unprocessable_entity
    end
  end

  def update
    service = UserService.new(update_params)

    service.update(current_user.id)

    if service.success?
      render json: UserSerializer.render(service.record, root: :user), status: :ok
    else
      render json: { errors: service.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    service = UserService.new

    service.destroy(current_user.id)

    if service.success?
      head :no_content
    else
      render json: { errors: service.errors }, status: :unprocessable_entity
    end
  end

  def me
    render json: UserSerializer.render(current_user, root: :user), status: :ok
  end

  private

  def create_params
    params.require(:user).permit(:name, :email, :password)
  end

  def update_params
    create_params
  end
end
