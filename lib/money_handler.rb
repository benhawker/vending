# frozen_string_literal: true

# +MoneyHandler+ handles all money movements in the machine.
# `box` represents the 'stored value' (i.e. money provided as a 'float' or already collected)
# `coin_slot` represents the money put into the machine immediately prior to a sale being made
class MoneyHandler
  class CoinNotRecognisedError < StandardError
    def initialize
      super("We only accept #{VALID_COINS}.join(', ')")
    end
  end

  attr_reader :coin_slot

  VALID_COINS = [1, 2, 5, 10, 20, 50, 100, 200].freeze

  def initialize
    @coin_slot = []
  end

  def insert(coin)
    raise CoinNotRecognisedError unless VALID_COINS.include?(coin)

    coin_slot << coin
  end

  def no_money_inserted?
    @coin_slot.empty?
  end

  def can_buy?(price)
    return false if price.nil?

    price <= @coin_slot.sum
  end

  def price_less_debited(price)
    price - @coin_slot.sum
  end

  # This method could be adapted to return a bool (success or failure) state
  # that the +VendingMachine+ could then use. This would allow 'rollback' in case
  # of failure so don't end up dispensing product/returning money or vice versa.
  #
  # This method could return a negative amount, although in practice the vending
  # machine class guards against this by calling MoneyHandler#can_buy? prior to calling
  # MoneyHandler#process_transaction.
  def process_transaction(price)
    amount_to_return = coin_slot.sum - price

    if amount_to_return.positive?
      change = coins_to_return(amount_to_return)
      print "Returning change as follows: #{change.join(', ')} \n"
    end

    @coin_slot.clear

    amount_to_return
  end

  private

  # Note that this approach assumes (intentionally naively)
  # that the machine has an infinite 'till float' which
  # can be used when returning exact change.
  #
  # This class can be extended to contain both a `coin_slot` and
  # a `till_float/coin_box` to separate the concepts cleanly.
  # The coin_slot can be 'cleared' and money moved into the coin_box
  # at the end of a transaction.
  def coins_to_return(amount_to_return)
    i = 0
    coins = []

    until amount_to_return.zero?
      coin = VALID_COINS.reverse[i]

      if coin > amount_to_return
        i += 1
        next
      end

      coins << coin
      amount_to_return -= coin
    end

    coins
  end
end
