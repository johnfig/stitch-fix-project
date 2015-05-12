require "rails_helper"

describe "view sortable items" do
  describe "items index", type: :feature do
    let(:clearance_batch_1) { FactoryGirl.create :clearance_batch }
    let(:clearance_batch_2) { FactoryGirl.create :clearance_batch }
    let!(:item_1) { FactoryGirl.create(:item, status: 'sellable', clearance_batch: clearance_batch_1) }
    let!(:item_2) { FactoryGirl.create(:item, status: 'clearanced', clearance_batch: clearance_batch_2) }

    describe "see items in table" do
      it "displays a list of all items" do
        visit '/items'

        header_columns.each do |header_column|
          expect(page).to have_content header_column
        end

        formatted_array = item_attributes(item_1).map { |attr| attr.to_s }
        formatted_array.each do |item_attribute|
          expect(page).to have_text item_attribute
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
          'Clearance Batch ID',
          'Sold At'
        ]
      end
    end

    it 'can be ordered by status' do
        visit '/items'
        row_1 = page.all('tr')[1]
        row_2 = page.all('tr')[2]
        expect(row_1).to have_content item_1.id
        expect(row_2).to have_content item_2.id

        select "status", :from => "group_by"
        click_button 'Sort'

        row_1 = page.all('tr')[1]
        row_2 = page.all('tr')[2]
        expect(row_1).to have_content item_2.id
        expect(row_2).to have_content item_1.id
    end

    it 'can be ordered by batch' do
        visit '/items'
        row_1 = page.all('tr')[1]
        row_2 = page.all('tr')[2]
        expect(row_1).to have_content item_1.id
        expect(row_2).to have_content item_2.id

        select "batch", :from => "group_by"
        click_button 'Sort'

        row_1 = page.all('tr')[1]
        row_2 = page.all('tr')[2]
        expect(row_1).to have_content item_2.id
        expect(row_2).to have_content item_1.id
    end
  end
end
