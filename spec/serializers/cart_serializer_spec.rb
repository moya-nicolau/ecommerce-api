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

RSpec.describe CartSerializer, type: :serializer do
  subject { described_class.render_as_hash(cart) }

  let(:user) { create(:user) }
  let(:cart) { create(:cart, user:, products:) }
  let(:products) { create_list(:product, 2) }

  it 'returns the proper data' do
    expect(subject[:id]).to eq(cart.id)
    expect(subject[:total_price]).to eq(cart.total_price.to_f.round(2))
    expect(subject[:products]).to be_present
  end
end
