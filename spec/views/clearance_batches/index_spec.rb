require 'rails_helper'

describe 'clearance_batches/index.html.erb' do
  let(:clearance_batch) { FactoryGirl.create :clearance_batch }
  let(:item) { FactoryGirl.create :item, clearance_batch_id: clearance_batch.id }
  let(:page)  { Capybara::Node::Simple.new(subject) }

  subject do
    assign(:clearance_batches, [clearance_batch])
    render template: 'clearance_batches/index'
  end

  it 'has an h1 title' do
    expect(page.find('h1').text).to eq 'Stitch Fix Clearance Tool'
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

  it 'has table rows with links to detailed clearance batch info' do
    expect(page.find('tbody a')[:href]).to eq "/clearance_batches/#{clearance_batch.id}"
  end

  def table_headers
    ['', 'Date clearanced', 'Number of items clearanced']
  end

  def table_row(item)
    ["Clearance Batch #{clearance_batch.id}", l(clearance_batch.created_at, format: :short), clearance_batch.items.count]
  end
end
