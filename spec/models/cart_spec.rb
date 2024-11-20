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
require 'rails_helper'

RSpec.describe Cart do
  let(:user) { create(:user) }

  subject { create(:cart, user:) }

  describe 'associations' do
    it { is_expected.to belong_to(:user).required }
    it { is_expected.to have_many(:cart_products).dependent(:destroy) }
    it { is_expected.to have_many(:products).through(:cart_products)}
  end

  describe '#total_price' do
    before do
      create_list(:product, 5, unit_price: 10).each do |product|
        create(:cart_product, cart: subject, product:, quantity: 1)
      end
    end

    it 'returns the total price for the products inside the cart' do
      expect(subject.total_price).to eq(50)
    end
  end
end
