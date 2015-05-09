class Item < ActiveRecord::Base

  CLEARANCE_PRICE_PERCENTAGE  = BigDecimal.new("0.75")

  belongs_to :style
  belongs_to :clearance_batch

  scope :sellable, -> { where(status: 'sellable') }

  def clearance!
    update_attributes!(status: 'clearanced',
                       price_sold: calculate_wholesale_price)
  end

  private

  def calculate_wholesale_price
    wholesale_clearance_price < 5 && pants_or_dress? ? 5 : wholesale_clearance_price
  end

  def wholesale_clearance_price
    style.wholesale_price * CLEARANCE_PRICE_PERCENTAGE
  end

  def pants_or_dress?
    style.type == 'pants' || style.type == 'dress'
  end
end
