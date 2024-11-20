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
FactoryBot.define do
  factory :cart do
  end
end
