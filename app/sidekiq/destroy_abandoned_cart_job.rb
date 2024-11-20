# frozen_string_literal: true

class DestroyAbandonedCartJob
  include Sidekiq::Job

  MAX_IDLE_TIME_IN_DAYS = 7

  sidekiq_options queue: :destroy_abandoned_carts, retry: 1, tags: %w[destroy-abandoned-carts]

  def perform
    Cart.where(abandoned_at: ...MAX_IDLE_TIME_IN_DAYS.days.ago).destroy_all
  end
end
