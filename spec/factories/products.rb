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
FactoryBot.define do
  factory :product do
    name { Faker::Name.name }
    description { Faker::Name.name }
    unit_price { Faker::Commerce.price(range: 100..1000.0) }
  end
end
