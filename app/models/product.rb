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
class Product < ApplicationRecord
  include Discard::Model

  has_many :cart_products, :dependent => :destroy
  has_many :carts, through: :cart_products

  validates :name, :description, presence: true, allow_blank: false
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
