# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  administrator          :boolean          default(FALSE), not null
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  name                   :string           not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :trackable, :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  has_many :carts, dependent: :destroy

  def jwt_payload
    {
      sub: id,
      scp: :user,
      jti: SecureRandom.uuid,
      iat: Time.zone.now.to_i,
      cart_id: Cart.create!(user: self).id,
      exp: ENV.fetch('JWT_EXPIRATION_IN_DAYS', 10).to_i.days.from_now.to_i
    }
  end
end
