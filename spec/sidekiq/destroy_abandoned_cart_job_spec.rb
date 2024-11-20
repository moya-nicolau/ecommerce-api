# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DestroyAbandonedCartJob, type: :job do
  it { is_expected.to be_processed_in :destroy_abandoned_carts }
  it { is_expected.to be_retryable 1 }

  describe '#perform' do
    subject { described_class.new }

    let(:user) { create(:user) }
    let!(:cart) { create(:cart, user:) }
    let!(:cart2) { create(:cart, user:, abandoned_at: described_class::MAX_IDLE_TIME_IN_DAYS.next.days.ago) }

    it "destroys the carts abandoned for more than #{described_class::MAX_IDLE_TIME_IN_DAYS} days" do
      expect{ subject.perform }.to change(Cart, :count).by(-1).and change{ Cart.find_by(id: cart2.id) }.to(nil)
    end
  end
end
