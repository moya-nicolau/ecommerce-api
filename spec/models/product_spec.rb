# frozen_string_literal: true

# == Schema Information
#
# Table name: products
#
#  id           :bigint           not null, primary key
#  description  :string           not null
#  discarded_at :datetime
#  name         :string           not null
#  unit_price   :decimal(, )      not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_products_on_discarded_at  (discarded_at) WHERE (discarded_at IS NULL)
#
require 'rails_helper'

RSpec.describe Product do
  subject { build(:product) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:unit_price) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_numericality_of(:unit_price).is_greater_than_or_equal_to(0) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:cart_products).dependent(:destroy) }
    it { is_expected.to have_many(:carts).through(:cart_products)}
  end
end
