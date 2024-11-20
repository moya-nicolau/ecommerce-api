# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CartProductService, type: :service do
  let(:user) { create(:user) }
  let(:product) { create(:product) }
  let(:cart) { create(:cart, user:) }
  let(:default_params) { { cart_id: cart.id, product_id: product.id } }

  describe '#create' do
    subject { described_class.new(parameters) }

    context 'with invalid data' do
      let(:parameters) { attributes_for(:cart_product, quantity: -1, **default_params) }

      it 'does not create any cart product' do
        expect { subject.create }.not_to change(CartProduct, :count)
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
      let(:parameters) { attributes_for(:cart_product, **default_params) }

      it 'creates a new record' do
        expect { subject.create }.to change(CartProduct, :count).by(1)
      end

      it 'returns the record' do
        subject.create

        data = CartProduct.order(created_at: :desc).first

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

    let(:id) { cart_product.id }
    let(:cart_product) { create(:cart_product, **default_params) }

    context 'with invalid data' do
      let(:parameters) { attributes_for(:cart_product, quantity: 0) }

      it 'does not update the cart product' do
        expect { subject.update(id) }.not_to(change { cart_product.reload.updated_at })
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
      let(:parameters) { attributes_for(:cart_product, quantity: 132156) }

      it 'updates the cart_product' do
        expect { subject.update(id) }.to(change { cart_product.reload.updated_at })
      end

      it 'returns true' do
        subject.update(id)

        expect(subject).to be_success
      end

      it 'returns the record' do
        subject.update(id)

        expect(subject.record).to eq(cart_product.reload)
      end

      it 'updates the record with the correct parameters' do
        subject.update(id)

        %i[quantity].each do |attribute|
          expect(parameters[attribute]).to eq(cart_product.reload[attribute])
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

    let(:id) { cart_product.id }
    let!(:cart_product) { create(:cart_product, **default_params) }

    it 'destroy the record' do
      expect { subject.destroy(id) }.to change(CartProduct, :count).by(-1)
    end

    it 'succeeds' do
      subject.destroy(id)

      expect(subject).to be_success
    end

    it 'returns no errors' do
      subject.destroy(id)

      expect(subject.errors).to be_empty
    end

    context 'when there is an error destroing the record' do
      before do
        allow(CartProduct).to receive(:find).with(id).and_return(cart_product)
        allow(cart_product).to receive(:destroy).and_return(false)
        allow(cart_product).to receive_message_chain(:errors, :full_messages).and_return(['foobar'])
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

  describe '#bulk_create' do
    let(:params) do
      [
        { product_id: product.id, quantity: 10 },
        { product_id: product2.id, quantity: 15 }
      ]
    end

    let(:product2) { create(:product) }

    subject { described_class.new(params) }

    it 'creates a new cart product for each product on the params' do
      expect{ subject.bulk_create(cart.id) }.to change(CartProduct, :count).by(2)
    end

    it 'creates the records with the correct params' do
      subject.bulk_create(cart.id)

      data = cart.cart_products.map { |element| element.slice(:product_id, :quantity).with_indifferent_access }

      expect(data).to eq(params.map(&:with_indifferent_access))
    end

    it 'succeeds' do
      subject.bulk_create(cart.id)

      expect(subject).to be_success
    end

    it 'returns no errors' do
      subject.bulk_create(cart.id)

      expect(subject.errors).to be_empty
    end

    context 'when some cart product fails' do
      let(:params) do
        [
          { product_id: product.id, quantity: -1 },
          { product_id: product2.id, quantity: 15 }
        ]
      end

      it 'does not create any cart product' do
        expect{ subject.bulk_create(cart.id) }.not_to change(CartProduct, :count)
      end

      it 'fails' do
        subject.bulk_create(cart.id)

        expect(subject).not_to be_success
      end

      it 'returns the errors' do
        subject.bulk_create(cart.id)

        expect(subject.errors).not_to be_empty
      end
    end

    context 'when the cart already have the product' do
      before do
        @existing_cart_product = create(:cart_product, cart:, product:, quantity: 2)
      end

      it 'creates the remaining cart products' do
        expect{ subject.bulk_create(cart.id) }.to change(CartProduct, :count).by(1)
      end

      it 'updates the existing cart product quantity' do
        expect{ subject.bulk_create(cart.id) }.to change{ @existing_cart_product.reload.quantity }.from(2).to(12)
      end
    end
  end

  describe '#bulk_destroy' do
    subject { described_class.new(params) }

    let(:params) do
      [
        { product_id: product.id, quantity: 2 },
        { product_id: product2.id, quantity: 2 }
      ]
    end

    let(:product2) { create(:product) }

    before do
      create(:cart_product, cart:, product:, quantity: 2)
      create(:cart_product, cart:, product: product2, quantity: 2)
    end

    it 'destroys all the cart products' do
      expect{ subject.bulk_destroy(cart.id) }.to change(CartProduct, :count).by(-2)
    end

    it 'succeeds' do
      subject.bulk_destroy(cart.id)

      expect(subject).to be_success
    end

    it 'returns no errors' do
      subject.bulk_destroy(cart.id)

      expect(subject.errors).to be_empty
    end

    context 'when some not included product id is given' do
      let(:params) do
        [
          { product_id: product.id, quantity: 2 },
          { product_id: product2.id, quantity: 2 },
          { product_id: 456456, quantity: 2 }
        ]
      end

      it 'does not destroy any cart product' do
        expect{ subject.bulk_destroy(cart.id) }.not_to change(CartProduct, :count)
      end

      it 'fails' do
        subject.bulk_destroy(cart.id)

        expect(subject).not_to be_success
      end

      it 'returns the errors' do
        subject.bulk_destroy(cart.id)

        expect(subject.errors).to eq(['Produto com id \'456456\' não está presente no carrinho'])
      end
    end

    context 'when some negative quantity is given' do
      let(:params) do
        [
          { product_id: product.id, quantity: 2 },
          { product_id: product2.id, quantity: -15 }
        ]
      end

      it 'does not destroy any cart product' do
        expect{ subject.bulk_destroy(cart.id) }.not_to change(CartProduct, :count)
      end

      it 'fails' do
        subject.bulk_destroy(cart.id)

        expect(subject).not_to be_success
      end

      it 'returns the errors' do
        subject.bulk_destroy(cart.id)

        expect(subject.errors).to eq(['Somente valores positivos são permitidos'])
      end
    end

    context 'when the given quantity is greater then the current quantity' do
      let(:params) do
        [
          { product_id: product.id, quantity: 1000 },
          { product_id: product2.id, quantity: 10000 }
        ]
      end

      it 'destroys all the cart products' do
        expect{ subject.bulk_destroy(cart.id) }.to change(CartProduct, :count).by(-2)
      end
    end

    context 'when the given quantity is smaller then the current quantity' do
      let(:params) do
        [
          { product_id: product.id, quantity: 1 },
          { product_id: product2.id, quantity: 1 }
        ]
      end

      it 'updates the cart products quantities' do
        expect{ subject.bulk_destroy(cart.id) }.to change{ cart.cart_products.map(&:reload).pluck(:quantity) }.from([2,2]).to([1,1])
      end
    end
  end
end
