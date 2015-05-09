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
    price = wholesale_clearance_price
    pants_or_dress? ? price_with_minimum(price, 5) : price_with_minimum(price, 2)
  end

  def wholesale_clearance_price
    style.wholesale_price * CLEARANCE_PRICE_PERCENTAGE
  end

  def pants_or_dress?
    style.type == 'pants' || style.type == 'dresses'
  end

  def price_with_minimum(price, minimum)
    price < minimum ? minimum : price
  end
end
