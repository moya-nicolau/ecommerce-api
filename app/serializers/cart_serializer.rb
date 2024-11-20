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
# Indexes
#
#  index_carts_on_abandoned_at  (abandoned_at) WHERE (abandoned_at IS NOT NULL)
#  index_carts_on_user_id       (user_id)
#
class CartSerializer < ApplicationSerializer
  identifier :id

  field :total_price do |instance|
    instance.total_price.to_f.round(2)
  end

  association :cart_products, name: :products, blueprint: CartProductSerializer
end
