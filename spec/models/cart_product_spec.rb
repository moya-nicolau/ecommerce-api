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

RSpec.describe CartProduct do
  let(:user) { create(:user) }
  let(:cart) { create(:cart, user:) }
  let(:product) { create(:product, unit_price: 10) }

  subject { create(:cart_product, cart:, product:, quantity: 1) }

  describe 'associations' do
    it { is_expected.to belong_to(:cart).required }
    it { is_expected.to belong_to(:product).required }
  end

  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:cart_id).scoped_to(:product_id).case_insensitive }
    it { is_expected.to validate_numericality_of(:quantity).is_greater_than_or_equal_to(1).only_integer }
  end

  describe '#total_price' do
    it 'returns the total price for the item' do
      expect(subject.total_price).to eq(10)
    end
  end

  describe 'lifetime hooks' do
    describe 'after_commit' do
      let(:cart) { create(:cart, user:, abandoned_at: Time.zone.now) }

      describe 'on create' do
        subject { build(:cart_product, cart:, product:, quantity: 1) }

        it 'marks the cart as not abandoned' do
          expect{ subject.save }.to change{ cart.reload.abandoned_at }.to(nil)
        end
      end

      describe 'on update' do
        it 'marks the cart as not abandoned' do
          expect{ subject.update(quantity: 2) }.to change{ cart.reload.abandoned_at }.to(nil)
        end
      end

      describe 'on destroy' do
        it 'marks the cart as not abandoned' do
          expect{ subject.destroy }.to change{ cart.reload.abandoned_at }.to(nil)
        end
      end
    end
  end
end
