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
class ProductSerializer < ApplicationSerializer
  identifier :id

  fields :name, :description, :unit_price
end
