class OrderItem < ActiveRecord::Base
  # get module to help with some functionality
  include ChessStoreHelpers::Validations

  # Relationships
  belongs_to :order
  belongs_to :item

  # Scopes
  scope :shipped,   -> { where.not(shipped_on: nil) }
  scope :unshipped, -> { where(shipped_on: nil) }

  # Validations
  validates_numericality_of :quantity, only_integer: true, greater_than: 0
  # validates_date :shipped_on, allow_blank: true
  validate :item_is_active_in_system

  # Other methods
  def subtotal(date=Date.current)
    return nil if !date.respond_to?(:future?) || date.future?
    self.item.price_on_date(date) * self.quantity
  end

  def shipped
    set_shipped_on_date_to_today
    reduce_inventory_of_item_by_quantity_ordered
  end

  def unshipped
    set_shipped_on_to_nil
    increase_inventory_of_item_by_quantity_ordered
  end

  private
  def item_is_active_in_system
    is_active_in_system(:item)
  end

  def set_shipped_on_date_to_today
    self.shipped_on = Date.current
    self.save!
  end

  def reduce_inventory_of_item_by_quantity_ordered
    item = self.item
    item.inventory_level -= self.quantity
    item.save!
  end

  def set_shipped_on_to_nil
    self.shipped_on = nil
    self.save!
  end

  def increase_inventory_of_item_by_quantity_ordered
    item = self.item
    item.inventory_level += self.quantity
    item.save!
  end
end
