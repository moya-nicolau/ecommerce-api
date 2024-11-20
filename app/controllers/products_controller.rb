# frozen_string_literal: true

class ProductsController < ApplicationController
  def index
    products = Product.all

    render json: ProductSerializer.render(products, root: :products), status: :ok
  end

  def show
    product = Product.find(params[:id])

    render json: ProductSerializer.render(product, root: :product), status: :ok
  end

  def create
    service = ProductService.new(create_params).tap(&:create)

    if service.success?
      render json: ProductSerializer.render(service.record, root: :product), status: :created
    else
      render json: { errors: service.errors }, status: :unprocessable_entity
    end
  end

  def update
    service = ProductService.new(update_params)

    service.update(params[:id])

    if service.success?
      render json: ProductSerializer.render(service.record, root: :product), status: :ok
    else
      render json: { errors: service.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    service = ProductService.new

    service.destroy(params[:id])

    if service.success?
      head :no_content
    else
      render json: { errors: service.errors }, status: :unprocessable_entity
    end
  end

  private

  def create_params
    params.require(:product).permit(:name, :unit_price, :description)
  end

  def update_params
    create_params
  end
end
