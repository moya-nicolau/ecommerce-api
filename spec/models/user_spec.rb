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
require 'rails_helper'

RSpec.describe User do
  subject { build(:user) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'associations' do
    it { is_expected.to have_many(:carts).dependent(:destroy)}
  end

  describe '#jwt_payload' do
    subject { create(:user) }

    let(:uuid) { SecureRandom.uuid }
    let(:cart) { create(:cart, user: subject) }
    let(:jwt_payload) do
      {
        sub: subject.id,
        scp: :user,
        jti: SecureRandom.uuid,
        iat: Time.zone.now.to_i,
        cart_id: Cart.create!(user: self).id,
        exp: ENV.fetch('JWT_EXPIRATION_IN_DAYS', 10).to_i.days.from_now.to_i
      }
    end

    before do
      allow(Cart).to receive(:create!).and_return(cart)
      allow(SecureRandom).to receive(:uuid).and_return(uuid)
    end

    it 'returns the proper payload' do
      expect(subject.jwt_payload).to eq(jwt_payload)
    end
  end
end
