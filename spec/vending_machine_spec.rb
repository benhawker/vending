# frozen_string_literal: true

require 'spec_helper'

describe VendingMachine do
  subject { described_class.new }

  describe 'initial state' do
    it 'has a MoneyHandler' do
      expect(subject.money_handler).to be_an_instance_of(MoneyHandler)
    end

    it 'has a StockHandler' do
      expect(subject.stock_handler).to be_an_instance_of(StockHandler)
    end

    it 'the selected_item_code is nil' do
      expect(subject.selected_item_code).to eq nil
    end
  end

  describe '#insert_coin' do
    context 'with a selected item' do
      before { subject.select_item(code: 1) }

      it 'adds the money' do
        allow(subject.money_handler).to receive(:insert)

        subject.insert_coin(amount: 10)

        expect(subject.money_handler).to have_received(:insert).with(10)
      end

      it 'checks whether the item can be released' do
        expect(subject).to receive(:validate_can_release_item)
        subject.insert_coin(amount: 10)
      end
    end

    context 'without a selected item' do
      it 'adds the money' do
        allow(subject.money_handler).to receive(:insert)

        subject.insert_coin(amount: 10)

        expect(subject.money_handler).to have_received(:insert).with(10)
      end

      it 'does NOT check whether the item can be released' do
        expect(subject).not_to receive(:validate_can_release_item)

        subject.insert_coin(amount: 10)
      end
    end

    context 'invalid coin' do
      it 'raises an error' do
        expect { subject.insert_coin(amount: 12) }
          .to raise_error(MoneyHandler::CoinNotRecognisedError)
      end
    end
  end

  describe '#select_item' do
    context 'with an invalid product' do
      it 'raises an error' do
        expect { subject.select_item(code: 999) }
          .to raise_error(StockHandler::ProductNotFoundError)
      end

      it 'does not set the selected_item_code' do
        expect { safe_select_item(999) }
          .not_to change { subject.selected_item_code }.from(nil)
      end

      it 'does NOT check whether the item can be released' do
        expect(subject).not_to receive(:validate_can_release_item)

        safe_select_item(999)
      end
    end

    context 'with a valid product' do
      it 'sets the selected_item_code' do
        expect { subject.select_item(code: 1) }
          .to change { subject.selected_item_code }.from(nil).to(1)
      end

      context 'when the user has not entered any money first' do
        it 'print a message about inserting money' do
          expect { subject.select_item(code: 1) }
            .to output("Please insert some money first \n").to_stdout
        end

        it 'does NOT check whether the item can be released' do
          expect(subject).not_to receive(:validate_can_release_item)

          subject.select_item(code: 1)
        end
      end

      context 'when the user has put money in first' do
        let(:item) { subject.stock_handler.find_by_code(1) }

        context 'when the item is out of stock' do
          before do
            allow(item).to receive(:in_stock?) { false }
            subject.insert_coin(amount: 10)
          end

          it 'prints a message about the stock level' do
            expect { subject.select_item(code: 1) }
              .to output("Out of stock \n").to_stdout
          end

          it 'does NOT check whether the item can be released' do
            expect(subject).not_to receive(:release_item)

            subject.select_item(code: 1)
          end
        end

        context 'when the user changes their selection' do
          before do
            subject.insert_coin(amount: 1)
            subject.select_item(code: 1)
          end

          it 'changes the selected_item_code' do
            expect { subject.select_item(code: 3) }
              .to change { subject.selected_item_code }.from(1).to(3)
          end
        end

        context 'when the user has not entered enough money for the selected item' do
          before { subject.insert_coin(amount: 1) }

          it 'prints a message about the insufficient funds' do
            expect { subject.select_item(code: 1) }
              .to output("Insufficient funds to purchase this item. Please add another 9\n").to_stdout
          end
        end

        context 'when the user has entered the exact money for the selected item' do
          before { subject.insert_coin(amount: 50) }

          it 'releases the item' do
            allow(subject).to receive(:release_item)

            subject.select_item(code: 1)

            expect(subject).to have_received(:release_item).with(item)
          end
        end

        context 'when the user entered more money than required for the selected item' do
          before { subject.insert_coin(amount: 200) }

          it 'releases the item' do
            allow(subject).to receive(:release_item)

            subject.select_item(code: 1)

            expect(subject).to have_received(:release_item).with(item)
          end
        end

        context 'when the user makes a purchase' do
          before { subject.select_item(code: 1) }

          it 'sets the selected_item_code to nil' do
            expect(subject.selected_item_code).to eq 1

            subject.insert_coin(amount: 200)

            expect(subject.selected_item_code).to eq nil
          end
        end
      end
    end
  end

  describe '#reload_item' do
    it 'calls the stock handler' do
      expect(subject.stock_handler).to receive(:reload_item).with(1, 10)

      subject.reload_item(code: 1, quantity: 10)
    end
  end

  def safe_select_item(code)
    subject.select_item(code: code)
  rescue StockHandler::ProductNotFoundError
    nil
  end
end
