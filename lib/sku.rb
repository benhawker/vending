# frozen_string_literal: true

# +Sku+ is a distinct *type* of item for sale.
#
# NB: The definition of a product (Sku) is separated from the quantity of a given product
# in the +VendingMachine+ at any point in time. This class just repesents the
# 'definition' of a sellable item (stock-keeping unit).
#
# I strongly belive it is important to separate this from the +Item+  class for extensibility.
class Sku
  attr_reader :code, :name, :price

  def initialize(code:, name:, price:)
    @code = code
    @name = name
    @price = price
  end
end
