class ClearanceBatchesController < ApplicationController

  def index
    @clearance_batches = ClearanceBatch.all
  end

  def show
    @clearance_batch = ClearanceBatch.includes(:items).find(params[:id])

    respond_to do |format|
      format.csv { render text: ClearanceBatchReport.generate_report(@clearance_batch) }
    end
  end

  def create
    clearancing_status = process_clearance_batch
    set_flash_message(clearancing_status)
    redirect_to action: :index
  end

  private

  def set_flash_message(clearancing_status)
    clearance_batch = clearancing_status.clearance_batch
    alert_messages  = []

    if clearance_batch.persisted?
      flash[:notice]  = "#{clearance_batch.items.count} items clearanced in batch #{clearance_batch.id}"
    else
      alert_messages << "No new clearance batch was added"
    end

    if clearancing_status.errors.any?
      alert_messages << "#{clearancing_status.errors.count} item ids raised errors and were not clearanced"
      clearancing_status.errors.each {|error| alert_messages << error }
    end

    flash[:alert] = alert_messages.join("<br/>") if alert_messages.any?
  end


  def process_clearance_batch
    if params[:csv_batch_file]
      return clearancing_status = ClearancingService.new.process_file(params[:csv_batch_file].tempfile)
    elsif params[:barcode_batch_string]
      return clearancing_status = ClearancingService.new.process_text_field(params[:barcode_batch_string])
    end
  end
end

