class Order < ApplicationRecord
  belongs_to :user
  enum status: { pending: 0, completed: 1, canceled: 2 }
  enum order_type: { other: 0, buy: 1, sell: 2 }

  scope :completed_buy_orders, -> {
    where(order_type: Order.order_types[:buy], status: Order.statuses[:completed])
  }

  # SELECT SUM(quantity) as total_quantity
  # FROM orders
  # WHERE user_id = $#{user_id} AND status = $2

  scope :total_quantity_for_user, ->(user_id) {
    where(user_id: user_id, status: Order.statuses[:completed])
      .sum(:quantity)
  }

  def process_order
    begin
      threshold = buy? ? buy_threshold : sell_threshold

      if buy? && price < buy_threshold || (sell? && price > sell_threshold)
        update!(status: Order.statuses[:completed])
      else
        update!(status: Order.statuses[:canceled])
      end
    rescue StandardError => e
      Rails.logger.error("Error processing order #{id}: #{e.message}")
    end
  end

  private

  def buy_threshold
    100
  end

  def sell_threshold
    200
  end
end
