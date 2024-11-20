# frozen_string_literal: true

# == Schema Information
#
# Table name: cart_products
#
#  id         :bigint           not null, primary key
#  quantity   :integer          default(1), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  cart_id    :bigint           not null
#  product_id :bigint           not null
#
# Indexes
#
#  index_cart_products_on_cart_id                 (cart_id)
#  index_cart_products_on_cart_id_and_product_id  (cart_id,product_id) UNIQUE
#  index_cart_products_on_product_id              (product_id)
#
class CartProductSerializer < ApplicationSerializer
  fields :quantity

  field :total_price do |instance|
    instance.total_price.to_f.round(2)
  end

  %i[id name].each do |attribute|
    field attribute do |instance|
      instance.product.send(attribute)
    end
  end

  %i[unit_price].each do |attribute|
    field attribute do |instance|
      instance.product.send(attribute).to_f.round(2)
    end
  end
end
