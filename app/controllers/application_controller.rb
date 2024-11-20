# frozen_string_literal: true

class ApplicationController < ActionController::API
  attr_accessor :current_cart

  respond_to :json

  include ActionController::MimeResponds

  class SetCurrentCartError < StandardError; end

  before_action :set_locale
  before_action :authenticate_user!

  before_action :set_current_cart

  rescue_from SetCurrentCartError do
    render json: { error: 'Não foi possível encontrar o seu carrinho' }, status: :unprocessable_entity
  end

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def set_current_cart
    return unless current_user.present?
    
    @current_cart = Cart.find(JWT.decode(request.headers['Authorization'].split(' ').second, ENV['JWT_SECRET']).first['cart_id'])
  rescue StandardError => e
    Rails.logger.error "[APPLICATION CONTROLLER][SET_CART_ID] ERROR WHILE SETTING CART_ID: #{e.message}"

    raise SetCurrentCartError
  end
end
