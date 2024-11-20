# frozen_string_literal: true

class CartsController < ApplicationController
  def current
    render json: CartSerializer.render(current_cart), status: :ok
  end

  def add_items
    service = CartProductService.new(add_items_params)

    service.bulk_create(current_cart.id)

    if service.success?
      render json: CartSerializer.render(current_cart), status: :ok
    else
      render json: { errors: service.errors }, status: :unprocessable_entity
    end
  end

  def remove_items
    service = CartProductService.new(remove_items_params)

    service.bulk_destroy(current_cart.id)

    if service.success?
      render json: CartSerializer.render(current_cart), status: :ok
    else
      render json: { errors: service.errors }, status: :unprocessable_entity
    end
  end

  private

  def add_items_params
    params.permit(_json: %i[product_id quantity])
  end

  def remove_items_params
    add_items_params
  end
end
