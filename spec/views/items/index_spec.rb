require 'rails_helper'

describe 'items/index.html.erb' do
  let(:page)  { Capybara::Node::Simple.new(subject) }
  let(:item) { FactoryGirl.create :item }

  subject do
    assign(:items, [item])
    render template: 'items/index'
  end

  it 'has an h1 title `Items`' do
    expect(page.find('h1').text).to eq 'Items'
  end

  it 'has table headers with item attributes' do
    table_headers.each do |header|
      expect(page.find('table thead')).to have_content header
    end
  end

  it 'has table rows with correct data' do
    table_row(item).each do |attributes|
      expect(page.find('table tbody')).to have_content attributes
    end
  end

  def table_headers
    ['ID', 'Size', 'Color', 'Status', 'Price Sold', 'Style ID', 'Clearance Batch ID', 'Sold At']
  end

  def table_row(item)
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
end
