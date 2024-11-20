# frozen_string_literal: true

class CartProductService < ApplicationService
  service_for :cart_product

  def bulk_create(cart_id)
    ActiveRecord::Base.transaction do
      @parameters.each do |attributes|
        cart_product = CartProduct.find_or_initialize_by(cart_id:, product_id: attributes[:product_id])

        accumulator = cart_product.new_record? ? 0 : cart_product.quantity

        cart_product.assign_attributes(attributes.slice(:quantity))

        if cart_product.save
          @success = true

          cart_product.update_columns(quantity: [attributes[:quantity].to_i, accumulator].sum)
        else
          abort(cart_product.errors.full_messages)
        end
      end
    end
  end

  def bulk_destroy(cart_id)
    ActiveRecord::Base.transaction do
      @parameters.each do |attributes|
        cart_product = CartProduct.find_by(cart_id:, product_id: attributes[:product_id])

        return abort("Produto com id '#{attributes[:product_id]}' não está presente no carrinho") if cart_product.nil?
        return abort("Somente valores positivos são permitidos") unless attributes[:quantity].to_i.positive?

        new_quantity = cart_product.quantity - attributes[:quantity].to_i

        if new_quantity.positive?
          cart_product.quantity = new_quantity

          return abort(cart_product.errors.full_messages) unless cart_product.save
        else
          return abort(cart_product.errors.full_messages) unless cart_product.destroy
        end

        @success = true
      end
    end
  end

  private

  def abort(errors)
    @success = false
    @errors = [errors, @errors].flatten

    raise ActiveRecord::Rollback
  end
end
