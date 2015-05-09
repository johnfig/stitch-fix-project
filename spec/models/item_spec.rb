require 'rails_helper'

describe Item do

  it { should belong_to(:style) }
  it { should belong_to(:clearance_batch) }

  describe '#sellable' do
    let!(:unsellable_item) { FactoryGirl.create :item, status: 'not sellable' }

    context 'item is has status of `sellable`' do
      it 'returns an array of all sellable items' do
        sellable_item_1 = FactoryGirl.create :item, status: 'sellable'
        sellable_item_2 = FactoryGirl.create :item, status: 'sellable'
        expect(described_class.sellable).to eq [sellable_item_1, sellable_item_2]
      end
    end

    context 'items are unsellable' do
      it 'returns an empty array' do
        expect(described_class.sellable).to eq []
      end
    end
  end

  describe '#order_by_status' do
    it 'returns an array of items grouped by status with newest items first' do
      sellable_1 = FactoryGirl.create :item, status: 'sellable'
      sold_1 =  FactoryGirl.create :item, status: 'sold'
      sellable_2 = FactoryGirl.create :item, status: 'sellable'
      sold_2     = FactoryGirl.create :item, status: 'sold'

      expect(Item.order_by_status).to eq [sellable_2, sellable_1, sold_2, sold_1]
    end
  end

  describe '#order_by_batch' do
    let(:batch_1) { FactoryGirl.create :clearance_batch }
    let(:batch_2) { FactoryGirl.create :clearance_batch }

    it 'returns an array of items grouped by clearance_batch_id with newest items first' do
      batch_1_item_1 = FactoryGirl.create :item, status: 'sellable', clearance_batch: batch_1
      batch_2_item_1 =  FactoryGirl.create :item, status: 'sellable', clearance_batch: batch_2
      batch_1_item_2 = FactoryGirl.create :item, status: 'sellable', clearance_batch: batch_1
      batch_2_item_2 = FactoryGirl.create :item, status: 'sellable', clearance_batch: batch_2

      result_array = [batch_2_item_2, batch_2_item_1, batch_1_item_2, batch_1_item_1]
      expect(Item.order_by_batch).to eq result_array
    end
  end

  describe "#clearance!" do
    let(:wholesale_price) { 100 }
    let(:type)  { 'pants' }
    let(:style) { FactoryGirl.create :style, wholesale_price: wholesale_price, type: type }
    let(:item)  { FactoryGirl.create(:item, style: style) }

    before do
      item.clearance!
      item.reload
    end

    it 'should mark the item status as clearanced' do
      expect(item.status).to eq('clearanced')
    end

    context 'item is pants or dresses' do
      context 'pants at 75% wholesale are less than $5' do
        let(:wholesale_price) { 6 }
        let(:type)  { 'pants' }

        it 'returns a minimum of $5' do
          expect(item.price_sold).to eq(BigDecimal.new('5'))
        end
      end

      context 'dresses at 75% wholesale are less than $5' do
        let(:wholesale_price) { 6 }
        let(:type) { 'dresses' }

        it 'returns a minimum of $5' do
          expect(item.price_sold).to eq(BigDecimal.new('5'))
        end
      end

      context 'pants/dresses at 75% wholesale are more than $5' do
        let(:wholesale_price) { 10 }
        let(:type) { 'dresses' }

        it 'returns 75% of wholesale value' do
          expect(item.price_sold).to eq(BigDecimal.new(wholesale_price) * BigDecimal.new("0.75"))
        end
      end
    end

    context 'item is not pants or dresses' do
      context 'item at 75% wholesale are more than $2' do
        it "sets the price_sold as 75% of the wholesale_price" do
          expect(item.price_sold).to eq(BigDecimal.new(wholesale_price) * BigDecimal.new("0.75"))
        end
      end

      context 'item at 75% wholesale are less than $2' do
        let(:wholesale_price) { 2 }
        let(:type) { 'shirts' }

        it "sets the price to $2" do
          expect(item.price_sold).to eq(2)
        end
      end
    end
  end
end
