require 'spec_helper'

describe ClearanceBatchReport do
  let(:clearance_batch) { FactoryGirl.create :clearance_batch }
  let(:item)            { FactoryGirl.create :item, clearance_batch: clearance_batch }

  subject { described_class.generate_report(clearance_batch) }

  it 'has specific header' do
    header_columns.each do |header_column|
      expect(subject).to include header_column
    end
  end

  it 'contains data of item in report' do
    formatted_array = item_attributes(item).map { |attr| attr.to_s }

    formatted_array.each do |item_attribute|
      expect(subject).to include item_attribute
    end
  end

  def item_attributes(item)
    [
      item.id,
      item.size,
      item.color,
      item.status,
      item.price_sold,
      item.style_id,
      item.clearance_batch_id,
      item.created_at
    ]
  end

  def header_columns
    [
      'ID',
      'Size',
      'Color',
      'Status',
      'Price Sold',
      'Sold At',
      'Style ID',
      'Clearance Batch Id',
      'Sold At'
    ]
  end
end
