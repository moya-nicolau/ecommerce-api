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
require 'rails_helper'

RSpec.describe CartProductSerializer, type: :serializer do
  subject { described_class.render_as_hash(cart_product) }

  let(:user) { create(:user) }
  let(:product) { create(:product) }
  let(:cart) { create(:cart, user:) }
  let(:cart_product) { create(:cart_product, product:, cart:) }

  it 'returns the proper data' do
    expect(subject[:id]).to eq(product.id)
    expect(subject[:name]).to eq(product.name)
    expect(subject[:unit_price]).to eq(product.unit_price)
    expect(subject[:total_price]).to eq(cart_product.total_price)
    expect(subject[:quantity]).to eq(cart_product.quantity)
  end
end
