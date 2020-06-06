# frozen_string_literal: true

require 'spec_helper'

describe MoneyHandler do
  subject { described_class.new }

  describe '#can_buy?' do
    before do
      subject.insert(200)
    end

    context 'when price is nil' do
      it 'returns false' do
        expect(subject.can_buy?(nil)).to be false
      end
    end

    context 'when price is less than the slot total' do
      it 'returns true' do
        expect(subject.can_buy?(49)).to be true
      end
    end

    context 'when price is equal to the slot total' do
      it 'returns true' do
        expect(subject.can_buy?(200)).to be true
      end
    end

    context 'when price is greater than the slot total' do
      it 'returns false' do
        expect(subject.can_buy?(201)).to be false
      end
    end
  end

  describe '#insert' do
    context 'with a single valid coin' do
      before { subject.insert(10) }

      it 'adds it to the coin_slot' do
        expect(subject.coin_slot).to eq [10]
      end
    end

    context 'with multiple valid coins' do
      before do
        subject.insert(10)
        subject.insert(50)
        subject.insert(100)
      end

      it 'adds it to the coin_slot' do
        expect(subject.coin_slot).to eq [10, 50, 100]
      end
    end

    context 'with an invalid coin' do
      it 'raises MoneyHandler::CoinNotRecognisedError' do
        expect { subject.insert(12) }
          .to raise_error(described_class::CoinNotRecognisedError)
      end
    end
  end

  describe '#no_money_inserted?' do
    context 'when the coin slot is empty' do
      it 'returns true' do
        expect(subject.no_money_inserted?).to be true
      end
    end

    context 'when the coin slot has coins in it' do
      before { subject.insert(10) }

      it 'returns false' do
        expect(subject.no_money_inserted?).to be false
      end
    end
  end

  describe '#process_transaction' do
    let(:price) { 90 }

    context 'when the coin slot has the exact money as the item price' do
      before do
        subject.insert(20)
        subject.insert(20)
        subject.insert(50)
      end

      it 'returns the correct change' do
        expect(subject.process_transaction(price)).to eq 0
      end

      it 'clears the slot' do
        expect { subject.process_transaction(price) }
          .to change { subject.coin_slot }.from([20, 20, 50]).to([])
      end
    end

    context 'when the coin slot has more money than the item price' do
      before do
        subject.insert(10)
        subject.insert(50)
        subject.insert(100)
      end

      it 'returns the correct change' do
        expect(subject.process_transaction(price)).to eq 70
      end

      it 'clears the slot' do
        expect { subject.process_transaction(price) }
          .to change { subject.coin_slot }.from([10, 50, 100]).to([])
      end
    end
  end
end
