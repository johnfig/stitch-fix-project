require 'csv'

class ClearanceBatchReport
  def self.generate_report(clearance_batch)
    CSV.generate do |csv|
      csv << ['ID', 'Size', 'Color', 'Status', 'Price Sold', 'Style ID', 'Clearance Batch Id', 'Sold At']
      clearance_batch.items.each do |item|
        csv << [
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
    end
  end
end
