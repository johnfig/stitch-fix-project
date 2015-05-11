require 'rails_helper'

describe  ClearanceBatchesController do
  describe '#index' do
    subject { get :index }

    it 'renders the clearance_batches/index template' do
      expect(subject).to render_template 'clearance_batches/index'
    end

    it 'returns an array of all ClearanceBatch objects' do
      subject
      expect(assigns(:clearance_batches)).to eq ClearanceBatch.all
    end
  end

  describe '#show' do
    let(:clearance_batch) { FactoryGirl.create :clearance_batch }
    subject { get :show, id: clearance_batch.id }

    it 'renders the clearance_batch/show template' do
      expect(subject).to render_template 'clearance_batches/show'
    end

    it 'returns a ClearanceBatch object' do
      subject
      expect(assigns(:clearance_batch)).to eq clearance_batch
    end
  end

  describe '#create' do
    context 'file upload' do
      subject { get :create, csv_batch_file: fixture_file_upload('spec/fixtures/example_csv.csv', 'text/csv') }

      context 'clearance batch is persisted' do
        let!(:item) { FactoryGirl.create :item, id: 488, status: 'sellable' }

        it 'returns a flash notice with the item count in batch' do
          subject
          notice = "1 items clearanced in batch 1"
          expect(flash[:notice]).to eq notice
        end
      end

      context 'clearance batch is not persisted' do
        it 'has a flash alert with errors about non persisted batch and not found items' do
          subject
          expect(flash[:alert]).to eq "No new clearance batch was added<br/>1 item ids raised errors and were not clearanced<br/>Item id 488 could not be found"
        end
      end
    end
  end

  context 'barcode text field clearance batching' do
    let!(:item) { FactoryGirl.create :item, id: 488, status: 'sellable' }
    subject { get :create, barcode_batch_string: "#{item.id})" }

    context 'clearance batch is persisted' do
      it 'returns a flash notice with the item count in batch' do
        subject
        notice = "1 items clearanced in batch 1"
        expect(flash[:notice]).to eq notice
      end
    end

    context 'clearance batch is not persisted' do
      it 'has a flash alert with errors about non persisted batch and not found items' do
        item.update_attribute(:status, 'clearanced')
        subject
        expect(flash[:alert]).to eq "No new clearance batch was added<br/>1 item ids raised errors and were not clearanced<br/>Item id 488 could not be clearanced"
      end
    end
  end
end
