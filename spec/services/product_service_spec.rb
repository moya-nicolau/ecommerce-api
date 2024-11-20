# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductService, type: :service do
  describe '#create' do
    subject { described_class.new(parameters) }

    context 'with invalid data' do
      let(:parameters) { attributes_for(:product, name: nil) }

      it 'does not create any product' do
        expect { subject.create }.not_to change(Product, :count)
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
      let(:parameters) { attributes_for(:product) }

      it 'creates a new record' do
        expect { subject.create }.to change(Product, :count).by(1)
      end

      it 'returns the record' do
        subject.create

        data = Product.order(created_at: :desc).first

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

    let(:product) { create(:product) }
    let(:id) { product.id }

    context 'with invalid data' do
      let(:parameters) { attributes_for(:product, name: '') }

      it 'does not update the product' do
        expect { subject.update(id) }.not_to(change { product.reload.updated_at })
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
      let(:parameters) { attributes_for(:product, name: 'foobar') }

      it 'updates the product' do
        expect { subject.update(id) }.to(change { product.reload.updated_at })
      end

      it 'returns true' do
        subject.update(id)

        expect(subject).to be_success
      end

      it 'returns the record' do
        subject.update(id)

        expect(subject.record).to eq(product.reload)
      end

      it 'updates the record with the correct parameters' do
        subject.update(id)

        %i[name description unit_price].each do |attribute|
          expect(parameters[attribute]).to eq(product.reload[attribute])
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

    let(:id) { product.id }
    let!(:product) { create(:product) }

    it 'discards the record' do
      expect { subject.destroy(id) }.to change { product.reload.discarded? }.from(false).to(true)
    end

    it 'succeeds' do
      subject.destroy(id)

      expect(subject).to be_success
    end

    it 'returns no errors' do
      subject.destroy(id)

      expect(subject.errors).to be_empty
    end

    context 'when there is an error discarding the record' do
      before do
        allow(Product).to receive(:find).with(id).and_return(product)
        allow(product).to receive(:discard!).and_return(false)
        allow(product).to receive_message_chain(:errors, :full_messages).and_return(['foobar'])
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
