# frozen_string_literal: true

# +Item+ represents a Sku held in stock in the machine.
# It essentially just represents a 'decorated' instance of a sku, including quantity.
# This approach allows separation of the 2 distinct concepts + extension if required.
#
# At this point in time it could be considered overkill but these are 2 different concepts to me.
class Item
  def initialize(sku:, quantity:)
    @sku = sku
    @quantity = quantity
  end

  def price
    @sku.price
  end

  def code
    @sku.code
  end

  def in_stock?
    @quantity.positive?
  end

  def increase_quantity(increase_by)
    @quantity += increase_by
  end

  def decrease_quantity(decrease_by)
    @quantity -= decrease_by
  end
end
