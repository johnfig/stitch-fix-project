require 'csv'
require 'ostruct'

class ClearancingService
  attr_accessor :clearancing_status

  def initialize
    @clearancing_status = create_clearancing_status
  end

  def process_file(uploaded_file)
    CSV.foreach(uploaded_file, headers: false) do |row|
      potential_item_id = row[0].to_i
      set_errors_or_clearancable_items(potential_item_id)
    end

    clearance_items!(clearancing_status)
  end

  def process_text_field(string)
    barcode_id_array = formatted_barcode_array(string)

    barcode_id_array.each do |potential_item_id|
      set_errors_or_clearancable_items(potential_item_id)
    end

    clearance_items!(clearancing_status)
  end

  private

  def create_clearancing_status
    OpenStruct.new(
      clearance_batch: ClearanceBatch.new,
      item_ids_to_clearance: [],
      errors: [])
  end

  def formatted_barcode_array(string)
    string.split(',').map { |id| id.to_i }
  end

  def set_errors_or_clearancable_items(potential_item_id)
    clearancing_error = what_is_the_clearancing_error?(potential_item_id)

    if clearancing_error
      clearancing_status.errors << clearancing_error
    else
      clearancing_status.item_ids_to_clearance << potential_item_id
    end
  end

  def what_is_the_clearancing_error?(potential_item_id)
    if potential_item_id.blank? || potential_item_id == 0 || !potential_item_id.is_a?(Integer)
      "Item id #{potential_item_id} is not valid"
    elsif Item.where(id: potential_item_id).none?
      "Item id #{potential_item_id} could not be found"
    elsif Item.sellable.where(id: potential_item_id).none?
      "Item id #{potential_item_id} could not be clearanced"
    else
      nil
    end
  end

  def clearance_items!(clearancing_status)
    if clearancing_status.item_ids_to_clearance.any?
      clearancing_status.clearance_batch.save!

      clearancing_status.item_ids_to_clearance.each do |item_id|
        item = Item.find(item_id)
        item.clearance!
        clearancing_status.clearance_batch.items << item
      end
    end

    clearancing_status
  end
end
