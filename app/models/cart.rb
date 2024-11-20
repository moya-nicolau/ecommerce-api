# frozen_string_literal: true

# == Schema Information
#
# Table name: carts
#
#  id           :bigint           not null, primary key
#  abandoned_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :uuid             not null
#
# Indexesp
#
#  index_carts_on_abandoned_at  (abandoned_at) WHERE (abandoned_at IS NOT NULL)
#  index_carts_on_user_id       (user_id)
#
class Cart < ApplicationRecord
  belongs_to :user

  has_many :cart_products, :dependent => :destroy
  has_many :products, through: :cart_products

  def total_price
    cart_products.joins(:product).sum('quantity * products.unit_price')
  end
end
