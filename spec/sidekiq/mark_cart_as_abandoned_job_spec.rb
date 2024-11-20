# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  it { is_expected.to be_processed_in :mark_cart_as_abandoned }
  it { is_expected.to be_retryable 1 }

  describe '#perform' do
    subject { described_class.new }

    let(:user) { create(:user) }

    describe 'for carts with no cart products' do
      let!(:cart) { create(:cart, user:, created_at: 1.hour.ago) }
      let!(:cart2) { create(:cart, user:, created_at: 2.hours.ago) }
      let!(:cart3) { create(:cart, user:, created_at: described_class::MAX_IDLE_TIME_IN_HOURS.next.hours.ago) }
      let!(:cart4) { create(:cart, user:, created_at: described_class::MAX_IDLE_TIME_IN_HOURS.next.next.hours.ago) }

      it "updates the carts that were created before #{described_class::MAX_IDLE_TIME_IN_HOURS} hours ago" do
        expect{ subject.perform }.to change{ cart3.reload.abandoned_at }.from(nil).to(a_value_within(2.seconds).of(Time.zone.now)).and change{ cart4.reload.abandoned_at }.from(nil).to(a_value_within(2.seconds).of(Time.zone.now))
      end

      it "does not updates the carts that were created before #{described_class::MAX_IDLE_TIME_IN_HOURS} hours ago" do
        expect{ subject.perform }.not_to change{ [cart, cart2].map(&:reload).map(&:abandoned_at) }
      end
    end

    describe 'for carts with cart products' do
      let(:cart) { create(:cart, user:, created_at: 6.hours.ago) }
      let(:cart2) { create(:cart, user:, created_at: 7.hours.ago) }
      let(:cart3) { create(:cart, user:, created_at: 11.hours.ago) }
      let(:cart4) { create(:cart, user:, created_at: 15.hours.ago) }

      let!(:cart_product1) { create(:cart_product, cart:, product: create(:product), updated_at: 2.hours.ago) }
      let!(:cart_product2) { create(:cart_product, cart:, product: create(:product), updated_at: 5.hours.ago) }
      let!(:cart_product3) { create(:cart_product, cart: cart2, product: create(:product), updated_at: 10.hours.ago) }
      let!(:cart_product4) { create(:cart_product, cart: cart2, product: create(:product), updated_at: 8.hours.ago) }
      let!(:cart_product5) { create(:cart_product, cart: cart3, product: create(:product), updated_at: 3.5.hours.ago) }
      let!(:cart_product6) { create(:cart_product, cart: cart3, product: create(:product), updated_at: 4.hours.ago) }
      let!(:cart_product7) { create(:cart_product, cart: cart4, product: create(:product), updated_at: 1.hour.ago) }
      let!(:cart_product8) { create(:cart_product, cart: cart4, product: create(:product), updated_at: 5.hours.ago) }

      it 'updates the carts wit no activity for the least three hours' do
        expect{ subject.perform }.to change{ cart2.reload.abandoned_at }.from(nil).to(a_value_within(2.seconds).of(Time.zone.now)).and change{ cart3.reload.abandoned_at }.from(nil).to(a_value_within(2.seconds).of(Time.zone.now))
      end

      it 'does not update the carst with activity for the last three hours' do
        expect{ subject.perform }.not_to change{ [cart, cart4].map(&:reload).map(&:abandoned_at) }
      end
    end
  end
end
