require 'rails_helper'

describe ItemsController do
  describe '#index' do
    let(:params) { {} }
    subject { get :index, params }

    it 'renders the index template' do
      expect(subject).to render_template :index
    end

    context 'when no params are present' do
      it 'returns all items' do
        subject
        expect(assigns(:items)).to eq Item.all
      end
    end

    context 'when :group_by params are present' do
      it 'calls #group_items' do
        params[:group_by] = :status
        expect(controller).to receive(:group_items)
        subject
      end

      context 'when params[:group_by] is `status`' do
        it 'calls a scope on item to return items ordered by batch' do
          params[:group_by] = 'status'
          expect(Item).to receive(:order_by_status)
          subject
        end
      end

      context 'when params[:group_by] is `batch`' do
        it 'calls a scope on item to return items ordered by batch' do
          params[:group_by] = 'batch'
          expect(Item).to receive(:order_by_batch)
          subject
        end
      end
    end
  end
end
