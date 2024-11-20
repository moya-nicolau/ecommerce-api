# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserService, type: :service do
  describe '#create' do
    subject { described_class.new(parameters) }

    context 'with invalid data' do
      let(:parameters) { attributes_for(:user, name: nil) }

      it 'does not create any user' do
        expect { subject.create }.not_to change(User, :count)
      end

      it 'returns false' do
        subject.create

        expect(subject).not_to be_success
      end

      it 'returns no record' do
        subject.create

        expect(subject.record).to be_nil
      end

      it 'returns the errors' do
        subject.create

        expect(subject.errors).not_to be_empty
      end
    end

    context 'with valid data' do
      let(:parameters) { attributes_for(:user) }

      it 'creates a new record' do
        expect { subject.create }.to change(User, :count).by(1)
      end

      it 'returns the record' do
        subject.create

        data = User.order(created_at: :desc).first

        expect(data).to eq(subject.record)
      end

      it 'succeeds' do
        subject.create

        expect(subject).to be_success
      end

      it 'returns no errors' do
        subject.create

        expect(subject.errors).to be_empty
      end
    end
  end

  describe '#update' do
    subject { described_class.new(parameters) }

    let(:user) { create(:user) }
    let(:id) { user.id }

    context 'with invalid data' do
      let(:parameters) { attributes_for(:user, name: '') }

      it 'does not update the user' do
        expect { subject.update(id) }.not_to(change { user.reload.updated_at })
      end

      it 'fails' do
        subject.update(id)

        expect(subject).not_to be_success
      end

      it 'returns no record' do
        subject.update(id)

        expect(subject.record).to be_nil
      end

      it 'returns the errors' do
        subject.update(id)

        expect(subject.errors).not_to be_empty
      end
    end

    context 'with valid data' do
      let(:parameters) { attributes_for(:user, name: 'foobar') }

      it 'updates the user' do
        expect { subject.update(id) }.to(change { user.reload.updated_at })
      end

      it 'returns true' do
        subject.update(id)

        expect(subject).to be_success
      end

      it 'returns the record' do
        subject.update(id)

        expect(subject.record).to eq(user.reload)
      end

      it 'updates the record with the correct parameters' do
        subject.update(id)

        %i[name email].each do |attribute|
          expect(parameters[attribute]).to eq(user.reload[attribute])
        end
      end

      it 'returns no errors' do
        subject.update(id)

        expect(subject.errors).to be_empty
      end
    end
  end

  describe '#destroy' do
    subject { described_class.new }

    let!(:user) { create(:user) }
    let(:id) { user.id }

    it 'destroy the record' do
      expect { subject.destroy(id) }.to change(User, :count).by(-1)
    end

    it 'succeeds' do
      subject.destroy(id)

      expect(subject).to be_success
    end

    it 'returns no errors' do
      subject.destroy(id)

      expect(subject.errors).to be_empty
    end

    context 'when there is an error destroying the record' do
      before do
        allow(User).to receive(:find).with(id).and_return(user)
        allow(user).to receive(:destroy).and_return(false)
        allow(user).to receive_message_chain(:errors, :full_messages).and_return(['foobar'])
      end

      it 'fails' do
        subject.destroy(id)

        expect(subject).not_to be_success
      end

      it 'returns the errors' do
        subject.destroy(id)

        expect(subject.errors).to eq(['foobar'])
      end
    end
  end
end
