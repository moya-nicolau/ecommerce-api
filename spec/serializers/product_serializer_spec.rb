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

RSpec.describe ProductSerializer, type: :serializer do
  subject { described_class.render_as_hash(product, root: :product) }

  let(:product) { create(:product) }

  it 'returns the product data' do
    %i[id description name unit_price].each do |attribute|
      expect(subject.dig(:product, attribute)).to eq(product.send(attribute))
    end
  end
end
