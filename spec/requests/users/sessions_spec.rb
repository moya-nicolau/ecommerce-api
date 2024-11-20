# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SessionsSpec' do
  describe 'POST /api/v1/users/sign_in' do
    def do_post
      post '/api/v1/users/sign_in', params: { user: user.slice(:email, :password) }
    end

    let(:user) { create(:user) }

    it 'returns the jwt token with the custom payload' do
      do_post

      cart_id = JWT.decode(response.headers['Authorization'].split(' ').second, ENV['JWT_SECRET']).first['cart_id']

      expect(cart_id).to eq(Cart.last.id)
    end
  end
end
