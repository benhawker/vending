# frozen_string_literal: true

require './lib/sku'
require './lib/item'
require './lib/stock_handler'
require './lib/money_handler'

require 'pry'

# A +VendingMachine+ instance contains:
#   - a +StockHandler+ that handles all stock
#   - a +MoneyHandler+ that handles all cash transactions
#   - a selected_item_code that tracks the state of the user selection.
#
# This is the only class the user need interact with directly.
class VendingMachine
  attr_reader :stock_handler, :money_handler, :selected_item_code

  def initialize(stock_list: nil)
    @stock_handler = StockHandler.new(stock_list: stock_list)
    @money_handler = MoneyHandler.new
    @selected_item_code = nil
  end

  def insert_coin(amount:)
    money_handler.insert(amount)

    validate_can_release_item if @selected_item_code
  end

  def select_item(code:)
    item = stock_handler.find_by_code(code)

    @selected_item_code = item.code

    return print "Please insert some money first \n" if money_handler.no_money_inserted?

    validate_can_release_item
  end

  # The spec states 'There should be a way of reloading products'.
  # I have interpreted this as reloading only existing stock.
  # No functionality provided to add 'new' products after initialization.
  # The +StockHandler+ could be easily extended to accomodate.
  def reload_item(code:, quantity: 1)
    stock_handler.reload_item(code, quantity)
  end

  private

  # We only allow/provide functionality for a single product to be released at any one time.
  def validate_can_release_item
    item = stock_handler.find_by_code(@selected_item_code)

    # Favour just printing the error string rather than raising a specific error for simplicity.
    # In the context of this small CLI program the desired effect is achieved.
    # (i.e. the user is aware of the issue and by `return`ing execution is halted)
    return print "Out of stock \n" unless item.in_stock?

    return release_item(item) if money_handler.can_buy?(item.price)

    print_shortfall(item)
  end

  def release_item(item)
    money_handler.process_transaction(item.price)
    item.decrease_quantity(1)
    @selected_item_code = nil

    print "Sale completed! \n"
  end

  def print_shortfall(item)
    shortfall = money_handler.price_less_debited(item.price)
    print "Insufficient funds to purchase this item. Please add another #{shortfall}\n"
  end
end
