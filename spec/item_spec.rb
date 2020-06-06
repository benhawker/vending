# frozen_string_literal: true

require 'spec_helper'

describe Item do
  let(:quantity) { 10 }

  subject do
    described_class.new(
      sku: Sku.new(
        code: 1,
        name: 'Test Product',
        price: 10
      ),
      quantity: quantity
    )
  end

  describe '#price' do
    it 'returns the item price' do
      expect(subject.price).to eq 10
    end
  end

  describe '#code' do
    it 'returns the item code' do
      expect(subject.code).to eq 1
    end
  end

  describe '#in_stock?' do
    context 'when the quantity is > 0' do
      it 'returns true when the quantity is >0' do
        expect(subject.in_stock?).to be true
      end
    end

    context 'when the quantity is 0' do
      let(:quantity) { 0 }

      it 'returns false ' do
        expect(subject.in_stock?).to be false
      end
    end
  end
end
