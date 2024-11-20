require 'rails_helper'

RSpec.describe ApplicationController do
  controller do
    def index
      head :ok
    end
  end

  describe 'current cart' do
    def do_get(headers = {})
      request.headers.merge!(**headers) if headers.present?

      get :index
    end

    context 'when the user is not logged in' do
      it 'returns the login error' do
        do_get

        expect(response.body).to eq('Para continuar, efetue login ou registre-se.')
      end

      it 'returns the unauthorized http status' do
        do_get

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the user is logged in' do
      let(:user) { create(:user) }

      context 'when the cart is present' do
        let(:headers) { { 'Authorization' => "Bearer #{JWT.encode(user.jwt_payload, ENV['JWT_SECRET'])}" } }

        it 'returns the ok http status' do
          do_get(headers)

          expect(response).to have_http_status(:ok)
        end
      end

      context 'when the cart is not present' do
        let(:headers) { { 'Authorization' => "Bearer #{JWT.encode(user.jwt_payload.except(:cart_id), ENV['JWT_SECRET'])}" } }

        it 'returns the login error' do
          do_get(headers)

          expect(response.parsed_body).to eq({"error"=>"Não foi possível encontrar o seu carrinho"})
        end

        it 'returns the unauthorized http status' do
          do_get(headers)

          expect(response).to have_http_status(422)
        end
      end
    end
  end

  include Devise::Test::ControllerHelpers
end
