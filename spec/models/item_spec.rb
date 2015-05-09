require 'rails_helper'

describe Item do
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

    context 'item is pants or a dress' do
      context 'pants at 75% wholesale are less than $5' do
        let(:wholesale_price) { 6 }
        let(:type)  { 'pants' }

        it 'returns a minimum of $5' do
          expect(item.price_sold).to eq(BigDecimal.new('5'))
        end
      end

      context 'dresses at 75% wholesale are less than $5' do
        let(:wholesale_price) { 6 }
        let(:type) { 'dress' }

        it 'returns a minimum of $5' do
          expect(item.price_sold).to eq(BigDecimal.new('5'))
        end
      end

      context 'pants/dress at 75% wholesale are more than $5' do
        it 'returns 75% of wholesale value' do
          expect(item.price_sold).to eq(BigDecimal.new(wholesale_price) * BigDecimal.new("0.75"))
        end
      end
    end

    context 'item is not pants or a dress' do
      it "should set the price_sold as 75% of the wholesale_price" do
        expect(item.price_sold).to eq(BigDecimal.new(wholesale_price) * BigDecimal.new("0.75"))
      end
    end
  end
end
