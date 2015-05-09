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
end
