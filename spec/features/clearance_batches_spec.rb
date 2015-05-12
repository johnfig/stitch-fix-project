require "rails_helper"

describe "add new monthly clearance_batch" do

  describe "clearance_batches index", type: :feature do

    describe "see previous clearance batches" do

      let!(:clearance_batch_1) { FactoryGirl.create(:clearance_batch) }
      let!(:clearance_batch_2) { FactoryGirl.create(:clearance_batch) }

      it "displays a list of all past clearance batches" do
        visit "/"
        expect(page).to have_content("Stitch Fix Clearance Tool")
        expect(page).to have_content("Clearance Batches")
        within('table.clearance_batches') do
          expect(page).to have_content("Clearance Batch #{clearance_batch_1.id}")
          expect(page).to have_content("Clearance Batch #{clearance_batch_2.id}")
        end
      end

    end

    describe "add a new clearance batch with file upload" do

      context "total success" do

        it "should allow a user to upload a new clearance batch successfully" do
          items = 5.times.map{ FactoryGirl.create(:item) }
          file_name = generate_csv_file(items)
          visit "/"
          within('table.clearance_batches') do
            expect(page).not_to have_content(/Clearance Batch \d+/)
          end
          attach_file("Select batch file", file_name)
          click_button "upload batch file"
          new_batch = ClearanceBatch.first
          expect(page).to have_content("#{items.count} items clearanced in batch #{new_batch.id}")
          expect(page).not_to have_content("item ids raised errors and were not clearanced")
          within('table.clearance_batches') do
            expect(page).to have_content(/Clearance Batch \d+/)
          end
        end

      end

      context "partial success" do

        it "should allow a user to upload a new clearance batch partially successfully, and report on errors" do
          valid_items   = 3.times.map{ FactoryGirl.create(:item) }
          invalid_items = [[987654], ['no thanks']]
          file_name     = generate_csv_file(valid_items + invalid_items)
          visit "/"
          within('table.clearance_batches') do
            expect(page).not_to have_content(/Clearance Batch \d+/)
          end
          attach_file("Select batch file", file_name)
          click_button "upload batch file"
          new_batch = ClearanceBatch.first
          expect(page).to have_content("#{valid_items.count} items clearanced in batch #{new_batch.id}")
          expect(page).to have_content("#{invalid_items.count} item ids raised errors and were not clearanced")
          within('table.clearance_batches') do
            expect(page).to have_content(/Clearance Batch \d+/)
          end
        end

      end

      context "total failure" do

        it "should allow a user to upload a new clearance batch that totally fails to be clearanced" do
          invalid_items = [[987654], ['no thanks']]
          file_name     = generate_csv_file(invalid_items)
          visit "/"
          within('table.clearance_batches') do
            expect(page).not_to have_content(/Clearance Batch \d+/)
          end
          attach_file("Select batch file", file_name)
          click_button "upload batch file"
          expect(page).not_to have_content("items clearanced in batch")
          expect(page).to have_content("No new clearance batch was added")
          expect(page).to have_content("#{invalid_items.count} item ids raised errors and were not clearanced")
          within('table.clearance_batches') do
            expect(page).not_to have_content(/Clearance Batch \d+/)
          end
        end
      end
    end

    describe "add a new clearance batch with text field input" do
      context "total success" do
        it "should allow a user to upload a new clearance batch successfully" do
          item_1 = FactoryGirl.create(:item)
          item_2 = FactoryGirl.create(:item)

          visit "/"
          within('table.clearance_batches') do
            expect(page).not_to have_content(/Clearance Batch \d+/)
          end
          fill_in "Scan Barcode ID's", with: "#{item_1.id}, #{item_2.id}"
          click_button "submit barcode ids"
          new_batch = ClearanceBatch.first
          expect(page).to have_content("2 items clearanced in batch #{new_batch.id}")
          expect(page).not_to have_content("item ids raised errors and were not clearanced")
          within('table.clearance_batches') do
            expect(page).to have_content(/Clearance Batch \d+/)
          end
        end
      end

      context "partial success" do
        it "should allow a user to upload a new clearance batch partially successfully, and report on errors" do
          valid_item_id  = [FactoryGirl.create(:item).id]
          invalid_items  = [['987654'], ['no thanks']]
          barcode_string = [valid_item_id + invalid_items].flatten.join(',')
          visit "/"
          within('table.clearance_batches') do
            expect(page).not_to have_content(/Clearance Batch \d+/)
          end

          fill_in "Scan Barcode ID's", with: barcode_string
          click_button "submit barcode ids"

          new_batch = ClearanceBatch.first

          expect(page).to have_content("1 items clearanced in batch #{new_batch.id}")
          expect(page).to have_content("#{invalid_items.count} item ids raised errors and were not clearanced")
          within('table.clearance_batches') do
            expect(page).to have_content(/Clearance Batch \d+/)
          end
        end
      end

      context "total failure" do
        it "should allow a user to upload a new clearance batch that totally fails to be clearanced" do
          invalid_items  = [['987654'], ['no thanks']]
          invalid_string = invalid_items.flatten.join(',')
          visit "/"
          within('table.clearance_batches') do
            expect(page).not_to have_content(/Clearance Batch \d+/)
          end
          fill_in "Scan Barcode ID's", with: invalid_string
          click_button "submit barcode ids"
          expect(page).not_to have_content("items clearanced in batch")
          expect(page).to have_content("No new clearance batch was added")
          expect(page).to have_content("#{invalid_items.count} item ids raised errors and were not clearanced")
          within('table.clearance_batches') do
            expect(page).not_to have_content(/Clearance Batch \d+/)
          end
        end
      end
    end
  end
end

