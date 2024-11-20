# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ProductsController' do
  before do
    allow(ProductSerializer).to receive(:render).and_call_original
  end

  describe 'GET api/v1/products' do
    def do_get
      get '/api/v1/products', headers:
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
        allow(Product).to receive(:all).and_return(products)
      end

      let(:user) { create(:user) }
      let!(:products) { create_list(:product, 5) }
      let(:headers) { authenticated_header({}, user) }

      it 'finds all the products' do
        do_get

        expect(Product).to have_received(:all)
      end

      it 'calls for the product serializer' do
        do_get

        expect(ProductSerializer).to have_received(:render).with(products, root: :products)
      end

      it 'returns the ok http status' do
        do_get

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET api/v1/products/:id' do
    def do_get
      get "/api/v1/products/#{product.id}", headers:
    end

    let(:product) { create(:product) }

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
        allow(Product).to receive(:find).with(product.id.to_s).and_return(product)
      end

      let(:user) { create(:user) }
      let(:headers) { authenticated_header({}, user) }

      it 'finds for the products with the given id' do
        do_get

        expect(Product).to have_received(:find).with(product.id.to_s)
      end

      it 'calls for the product serializer' do
        do_get

        expect(ProductSerializer).to have_received(:render).with(product, root: :product)
      end

      it 'returns the ok http status' do
        do_get

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'POST api/v1/products' do
    def do_post
      post '/api/v1/products', headers:, params:
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
        allow(ProductService).to receive(:new).and_return(service)
      end

      let(:user) { create(:user) }
      let(:record) { create(:product) }
      let(:headers) { authenticated_header({}, user) }
      let(:params) { { product: attributes_for(:product) } }
      let(:service) { instance_double(ProductService, create: true, success?: true, record: record) }

      it 'creates a new instance of the product service' do
        do_post

        expect(ProductService).to have_received(:new).with(to_strong_parameters(params[:product]))
      end

      it 'calls for the create method on the new instance' do
        do_post

        expect(service).to have_received(:create)
      end

      it 'calls for the product serializer' do
        do_post

        expect(ProductSerializer).to have_received(:render).with(record, root: :product)
      end

      it 'returns the created http status' do
        do_post

        expect(response).to have_http_status(:created)
      end

      context 'when the service fails' do
        let(:errors) { ['this is my creation error'] }
        let(:service) { instance_double(ProductService, create: true, success?: false, errors:) }

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

  describe 'PUT api/v1/products/:id' do
    def do_put
      put "/api/v1/products/#{product.id}", headers:, params:
    end

    let(:product) { create(:product) }

    context 'when the user is not logged in' do
      let(:params) { {} }
      let(:headers) { {} }

      it 'returns unauthorized http status' do
        do_put

        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns the error message' do
        do_put

        expect(response.parsed_body['error']).to eq('Para continuar, efetue login ou registre-se.')
      end
    end

    context 'when the user is logged in' do
      before do
        allow(ProductService).to receive(:new).and_return(service)
      end

      let(:user) { create(:user) }
      let(:headers) { authenticated_header({}, user) }
      let(:params) { { product: attributes_for(:product) } }
      let(:service) { instance_double(ProductService, update: true, success?: true, record: product) }

      it 'creates a new instance of the product service' do
        do_put

        expect(ProductService).to have_received(:new).with(to_strong_parameters(params[:product]))
      end

      it 'calls for the update method on the new instance' do
        do_put

        expect(service).to have_received(:update).with(product.id.to_s)
      end

      it 'calls for the product serializer' do
        do_put

        expect(ProductSerializer).to have_received(:render).with(product, root: :product)
      end

      it 'returns the ok http status' do
        do_put

        expect(response).to have_http_status(:ok)
      end

      context 'when the service fails' do
        let(:errors) { ['this is my update error'] }
        let(:service) { instance_double(ProductService, update: true, success?: false, errors:) }

        it 'returns the error message' do
          do_put

          expect(response.parsed_body['errors']).to eq(errors)
        end

        it 'returns the unprocessable_entity http status' do
          do_put

          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end
  end

  describe 'DELETE api/v1/products/:id' do
    def do_delete
      delete "/api/v1/products/#{product.id}", headers:
    end

    let(:product) { create(:product) }

    context 'when the user is not logged in' do
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
        allow(ProductService).to receive(:new).and_return(service)
      end

      let(:user) { create(:user) }
      let(:headers) { authenticated_header({}, user) }
      let(:service) { instance_double(ProductService, destroy: true, success?: true) }

      it 'creates a new instance of the product service' do
        do_delete

        expect(ProductService).to have_received(:new)
      end

      it 'calls for the destroy method on the new instance' do
        do_delete

        expect(service).to have_received(:destroy).with(product.id.to_s)
      end

      it 'returns the no_content http status' do
        do_delete

        expect(response).to have_http_status(:no_content)
      end

      context 'when the service fails' do
        let(:errors) { ['this is my destroy error'] }
        let(:service) { instance_double(ProductService, destroy: true, success?: false, errors:) }

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
