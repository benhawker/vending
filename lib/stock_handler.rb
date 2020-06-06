# frozen_string_literal: true

require 'yaml'

# +StockHandler+ handles the 'stock' in the machine.
# Stock is stored as a hash keyed by the sku_code, with item values.
class StockHandler
  class ProductNotFoundError < StandardError
    def initialize
      super('That code does not exist in our system.')
    end
  end

  # A default list is provided via this YAML file
  DEFAULT_STOCK = YAML.safe_load(File.open(File.join('config', 'stock.yml')))
  DEFAULT_QUANTITY = 2

  attr_reader :stock

  # Allows overriding of the default stock list (open for extension)
  def initialize(stock_list: nil)
    @stock = load_stock(stock_list || DEFAULT_STOCK)
  end

  def find_by_code(code)
    item = stock.fetch(code, nil)

    raise ProductNotFoundError unless item

    item
  end

  def reload_item(code, quantity)
    return print 'You need to specify a quantity greater than 0' unless quantity.to_i.positive?

    item = find_by_code(code)

    item.increase_quantity(quantity)
  end

  private

  def load_stock(stock_list)
    stock_list.each_with_object({}) do |product, obj|
      obj[product['code']] = Item.new(
        sku: Sku.new(
          code: product['code'],
          name: product['name'],
          price: product['price']
        ),
        quantity: product['quantity'] || DEFAULT_QUANTITY
      )
    end
  end
end
