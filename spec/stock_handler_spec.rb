# frozen_string_literal: true

require 'spec_helper'

describe StockHandler do
  subject { described_class.new }

  describe 'initial state' do
    context 'no stock is passed' do
      it 'uses the default stock' do
        expect(subject.stock.keys).to eq [1, 2, 3, 4]
      end
    end

    context 'stock is passed' do
      let(:stock_list) do
        [{ 'code' => 74, 'name' => 'Another Item', 'price' => 10, 'quantity' => 2 }]
      end

      subject { described_class.new(stock_list: stock_list) }

      it 'uses the passed stock' do
        expect(subject.stock.keys).to eq [74]
      end
    end
  end

  describe '#find_by_code' do
    context 'with an invalid item' do
      it 'raises an error' do
        expect { subject.find_by_code(99) }.to raise_error(described_class::ProductNotFoundError)
      end
    end

    context 'with a valid item' do
      let(:item) { subject.find_by_code(1) }

      it 'returns the item' do
        expect(item).to be_an_instance_of Item
        expect(item.code).to eq 1
        expect(item.price).to eq 10
      end
    end
  end

  describe '#reload_item' do
    context 'with a valid item' do
      let(:item_code) { 1 }
      let(:item) { subject.find_by_code(item_code) }
      let(:existing_quantity) { item.send(:quantity) }

      it 'reloads the item (updating the quantity)' do
        expect(item).to receive(:increase_quantity).with(10)

        subject.reload_item(item_code, 10)
      end

      context 'with an invalid quantity' do
        context 'that is NaN' do
          it 'prints a message about the invalid quantity' do
            expect { subject.reload_item(item_code, 'a string') }
              .to output('You need to specify a quantity greater than 0').to_stdout
          end

          it 'does not update the quantity' do
            expect(item).not_to receive(:increase_quantity).with(anything)

            subject.reload_item(item_code, 'a string')
          end
        end

        context 'that is negative' do
          it 'prints a message about the invalid quantity' do
            expect { subject.reload_item(item_code, -1) }
              .to output('You need to specify a quantity greater than 0').to_stdout
          end
        end
      end
    end

    context 'with an invalid product' do
      it 'raises an error' do
        expect { subject.reload_item(999, 100) }
          .to raise_error(described_class::ProductNotFoundError)
      end

      it 'does not increase the quantity of any items' do
        expect_any_instance_of(Item).not_to receive(:increase_quantity).with(anything)

        safe_reload_item(999, 100)
      end
    end
  end

  def safe_reload_item(code, quantity)
    subject.reload_item(code, quantity)
  rescue StockHandler::ProductNotFoundError
    nil
  end
end
