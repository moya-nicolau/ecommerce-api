# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'UsersController' do
  before do
    allow(UserSerializer).to receive(:render).and_call_original
  end

  describe 'GET /api/v1/users/me' do
    def do_get
      get '/api/v1/users/me', headers:
    end

    let(:user) { create(:user) }

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
      let(:headers) { authenticated_header({}, user) }

      it 'returns the ok http status' do
        do_get

        expect(response).to have_http_status(:ok)
      end

      it 'calls for the user serializer' do
        do_get

        expect(UserSerializer).to have_received(:render).with(user, root: :user)
      end
    end
  end

  describe 'POST /api/v1/users' do
    def do_post
      post '/api/v1/users', params: { user: params }
    end

    let(:params) { attributes_for(:user) }
    let(:record) { create(:user, **params) }
    let(:service) { instance_double(UserService, create: true, success?: true, record:) }

    before do
      allow(UserService).to receive(:new).and_return(service)
    end

    it 'creates a new instance of the user service' do
      do_post

      expect(UserService).to have_received(:new).with(to_strong_parameters(params))
    end

    it 'calls for the create method on the new instance' do
      do_post

      expect(service).to have_received(:create)
    end

    it 'calls for the user serializer' do
      do_post

      expect(UserSerializer).to have_received(:render).with(service.record, root: :user)
    end

    it 'returns the created http status' do
      do_post

      expect(response).to have_http_status(:created)
    end

    context 'when the service fails' do
      let(:service) { instance_double(UserService, create: true, success?: false, errors: 'fooobar') }

      it 'returns the errors' do
        do_post

        expect(response.parsed_body).to eq({ 'errors' => 'fooobar' })
      end

      it 'returns the unprocessable entity http status' do
        do_post

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'PUT /api/v1/users' do
    def do_put
      put '/api/v1/users', headers:, params: { user: params }
    end

    let(:user) { create(:user) }
    let(:params) { attributes_for(:user) }
    let(:service) { instance_double(UserService, update: true, success?: true, record: user) }

    before do
      allow(UserService).to receive(:new).and_return(service)
    end

    context 'when the user is not logged in' do
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
      let(:headers) { authenticated_header({}, user) }

      it 'creates a new instance of the user service' do
        do_put

        expect(UserService).to have_received(:new).with(to_strong_parameters(params))
      end

      it 'calls for the update method on the new instance' do
        do_put

        expect(service).to have_received(:update).with(user.id)
      end

      it 'returns the ok http status' do
        do_put

        expect(response).to have_http_status(:ok)
      end

      it 'calls for the user serializer' do
        do_put

        expect(UserSerializer).to have_received(:render).with(user, root: :user)
      end

      context 'when the service fails' do
        let(:service) { instance_double(UserService, update: true, success?: false, errors: 'foobar') }

        it 'returns the unprocessable entity http status' do
          do_put

          expect(response).to have_http_status(:unprocessable_content)
        end

        it 'returns the error message' do
          do_put

          expect(response.parsed_body).to eq({ 'errors' => 'foobar' })
        end
      end
    end
  end

  describe 'DELETE /api/v1/users' do
    def do_delete
      delete '/api/v1/users', headers:
    end

    let(:user) { create(:user) }
    let(:service) { instance_double(UserService, destroy: true, success?: true) }

    before do
      allow(UserService).to receive(:new).and_return(service)
    end

    context 'when the user is not logged in' do
      let(:id) { user.id }
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
      let(:headers) { authenticated_header({}, user) }

      it 'creates a new instance of the user service' do
        do_delete

        expect(UserService).to have_received(:new)
      end

      it 'calls for the destroy method on the new instance' do
        do_delete

        expect(service).to have_received(:destroy).with(user.id)
      end

      it 'returns the no_content http status' do
        do_delete

        expect(response).to have_http_status(:no_content)
      end

      context 'when the service fails' do
        let(:service) { instance_double(UserService, destroy: true, success?: false, errors: 'foobar') }

        it 'returns the unprocessable entity http status' do
          do_delete

          expect(response).to have_http_status(422)
        end

        it 'returns the error message' do
          do_delete

          expect(response.parsed_body).to eq({ 'errors' => 'foobar' })
        end
      end
    end
  end
end
