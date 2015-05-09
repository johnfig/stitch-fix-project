class ItemsController < ApplicationController
  def index
    group_items
  end

  private

  def group_items
    if params[:group_by] == 'status'
      @items = Item.order_by_status
    elsif params[:group_by] == 'batch'
      @items = Item.order_by_batch
    else
      @items = Item.all
    end
  end
end
