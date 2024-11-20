# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'CartsController' do
  before do
    allow(CartSerializer).to receive(:render).and_call_original
  end

  describe 'GET api/v1/cart/current' do
    def do_get
      get '/api/v1/cart/current', headers:
    end

    context 'when the user is not logged in' do
      let(:headers) { {} }

      it 'returns unauthorized http status' do
        do_get

        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns the error message' do
        do_get

        expect(response.parsed_body['error']).to eq('Para continuar, efetue login ou registre-se.')
      end
    end

    context 'when the user is logged in' do
      before do
        allow(user).to receive(:jwt_payload).and_return(jwt_payload)
        allow(Cart).to receive(:find).with(cart.id).and_return(cart)
      end

      let(:user) { create(:user) }
      let(:cart) { create(:cart, user:) }
      let(:headers) { authenticated_header({}, user) }
      let(:jwt_payload) do
        {
          sub: user.id,
          scp: :user,
          jti: SecureRandom.uuid,
          iat: Time.zone.now.to_i,
          cart_id: cart.id,
          exp: ENV.fetch('JWT_EXPIRATION_IN_DAYS', 10).to_i.days.from_now.to_i
        }
      end

      it 'calls for the cart serializer with the current cart' do
        do_get

        expect(CartSerializer).to have_received(:render).with(cart)
      end

      it 'returns the ok http status' do
        do_get

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'POST api/v1/cart/add_items' do
    def do_post
      post '/api/v1/cart/add_items', headers:, params:
    end

    context 'when the user is not logged in' do
      let(:params) { {} }
      let(:headers) { {} }

      it 'returns unauthorized http status' do
        do_post

        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns the error message' do
        do_post

        expect(response.parsed_body['error']).to eq('Para continuar, efetue login ou registre-se.')
      end
    end

    context 'when the user is logged in' do
      before do
        allow(CartProductService).to receive(:new).and_return(service)
        allow(user).to receive(:jwt_payload).and_return(jwt_payload)
      end

      let(:user) { create(:user) }
      let(:cart) { create(:cart, user:) }
      let(:headers) { authenticated_header({}, user) }
      let(:service) { instance_double(CartProductService, bulk_create: true, success?: true) }
      let(:params) { { _json: create_list(:product, 3).map { |product| { product_id: product.id.to_s, quantity: rand(1..100).to_s } } } }
      let(:jwt_payload) do
        {
          sub: user.id,
          scp: :user,
          jti: SecureRandom.uuid,
          iat: Time.zone.now.to_i,
          cart_id: cart.id,
          exp: ENV.fetch('JWT_EXPIRATION_IN_DAYS', 10).to_i.days.from_now.to_i
        }
      end

      it 'creates a new instance of the cart service' do
        do_post

        expect(CartProductService).to have_received(:new).with(to_strong_parameters(params))
      end

      it 'calls for the bulk create method on the new instance' do
        do_post

        expect(service).to have_received(:bulk_create).with(cart.id)
      end

      it 'calls for the cart serializer' do
        do_post

        expect(CartSerializer).to have_received(:render).with(cart)
      end

      it 'returns the created http status' do
        do_post

        expect(response).to have_http_status(:ok)
      end

      context 'when the service fails' do
        let(:errors) { ['this is my creation error'] }
        let(:service) { instance_double(CartProductService, bulk_create: true, success?: false, errors:) }

        it 'returns the error message' do
          do_post

          expect(response.parsed_body['errors']).to eq(errors)
        end

        it 'returns the unprocessable_entity http status' do
          do_post

          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end
  end

  describe 'DELETE api/v1/cart/remove_items' do
    def do_delete
      delete '/api/v1/cart/remove_items', headers:, params:
    end

    context 'when the user is not logged in' do
      let(:params) { {} }
      let(:headers) { {} }

      it 'returns unauthorized http status' do
        do_delete

        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns the error message' do
        do_delete

        expect(response.parsed_body['error']).to eq('Para continuar, efetue login ou registre-se.')
      end
    end

    context 'when the user is logged in' do
      before do
        allow(CartProductService).to receive(:new).and_return(service)
        allow(user).to receive(:jwt_payload).and_return(jwt_payload)
      end

      let(:user) { create(:user) }
      let(:cart) { create(:cart, user:) }
      let(:headers) { authenticated_header({}, user) }
      let(:service) { instance_double(CartProductService, bulk_destroy: true, success?: true) }
      let(:params) { { _json: create_list(:product, 3).map { |product| { product_id: product.id.to_s, quantity: rand(1..100).to_s } } } }
      let(:jwt_payload) do
        {
          sub: user.id,
          scp: :user,
          jti: SecureRandom.uuid,
          iat: Time.zone.now.to_i,
          cart_id: cart.id,
          exp: ENV.fetch('JWT_EXPIRATION_IN_DAYS', 10).to_i.days.from_now.to_i
        }
      end

      it 'creates a new instance of the cart service' do
        do_delete

        expect(CartProductService).to have_received(:new).with(to_strong_parameters(params))
      end

      it 'calls for the bulk destroy method on the new instance' do
        do_delete

        expect(service).to have_received(:bulk_destroy).with(cart.id)
      end

      it 'calls for the cart serializer' do
        do_delete

        expect(CartSerializer).to have_received(:render).with(cart)
      end

      it 'returns the ok http status' do
        do_delete

        expect(response).to have_http_status(:ok)
      end

      context 'when the service fails' do
        let(:errors) { ['this is my destroy error'] }
        let(:service) { instance_double(CartProductService, bulk_destroy: true, success?: false, errors:) }

        it 'returns the error message' do
          do_delete

          expect(response.parsed_body['errors']).to eq(errors)
        end

        it 'returns the unprocessable_entity http status' do
          do_delete

          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end
  end
end
