# frozen_string_literal: true

class MarkCartAsAbandonedJob
  include Sidekiq::Job

  MAX_IDLE_TIME_IN_HOURS = 3

  sidekiq_options queue: :mark_cart_as_abandoned, retry: 1, tags: %w[mark-cart-as-abandoned]

  def perform
    carts_with_products.update_all(abandoned_at: Time.zone.now)
    carts_without_products.update_all(abandoned_at: Time.zone.now)
  end

  private

  def carts_without_products
    Cart.where.not(id: CartProduct.all.select(:cart_id)).where(created_at: ...MAX_IDLE_TIME_IN_HOURS.hours.ago)
  end

  def carts_with_products
    Cart.joins(:cart_products).group("cart_products.cart_id, carts.id").having("MAX(cart_products.updated_at) < ?", MAX_IDLE_TIME_IN_HOURS.hours.ago)
  end
end
