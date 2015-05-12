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

  context 'file upload form' do
    it 'submits to correct route' do
      expect(page.find('form.file-upload-form')['action']).to eq '/clearance_batches'
    end

    it 'has form with file upload' do
      expect(page.find('form.file-upload-form label').text).to eq 'Select batch file'
    end

    it 'has form with barcode text field' do
      expect(page.find('form #csv_batch_file')).to be
    end
  end

  context 'text field form' do
    it 'submits to correct route' do
      expect(page.find('form.text-field-form')['action']).to eq '/clearance_batches'
    end

    it 'has form with file upload' do
      expect(page.find('form.text-field-form label').text).to eq "Scan Barcode ID's"
    end

    it 'has form with barcode text field' do
      expect(page.find('form #barcode_batch_string')).to be
    end
  end

  context 'table' do
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

    it 'has table rows with links to clearance batch info report' do
      expect(page.find('tbody a')[:href]).to eq "/clearance_batches/#{clearance_batch.id}.csv"
    end

    def table_headers
      ['', 'Date clearanced', 'Number of items clearanced', 'Download CSV']
    end

    def table_row(item)
      ["Clearance Batch #{clearance_batch.id}", l(clearance_batch.created_at, format: :short), clearance_batch.items.count, 'Download Batch Report']
    end
  end
end
