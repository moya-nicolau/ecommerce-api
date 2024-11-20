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
class CartProduct < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  after_commit :mark_cart_as_not_abandoned

  validates :cart_id, uniqueness: { scope: :product_id, case_sensitive: false }
  validates :quantity, numericality: { greater_than_or_equal_to: 1, only_integer: true }

  def total_price
    product.unit_price * quantity
  end

  private

  def mark_cart_as_not_abandoned
    cart.update_column(:abandoned_at, nil)
  end
end
