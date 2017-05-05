class Order < ActiveRecord::Base
  # get module to help with some functionality
  include ChessStoreHelpers::Validations
  include ChessStoreHelpers::Shipping
  require 'base64'

  # Relationships
  has_many :order_items
  has_many :items, through: :order_items
  belongs_to :school
  belongs_to :user

  # Virtual attributes (non-saved)
  attr_accessor :credit_card_number
  attr_accessor :expiration_year
  attr_accessor :expiration_month
  attr_reader :destroyable

  # Scopes
  scope :chronological, -> { order(date: :desc) }
  scope :paid,          -> { where.not(payment_receipt: nil) }
  scope :for_school,    ->(school_id) { where(school_id: school_id) }
  scope :shipped,       -> { joins(:order_items).where("order_items.shipped_on IS NOT NULL").uniq! }

  # Class methods
  def self.not_shipped
    joins(:order_items).where("order_items.shipped_on IS NULL").uniq!
  end

  def self.search(query)
    where("orders.id == ?", "#{query}")
  end

  def self.revenue_from_last_6_months
    result = []
    for n in 0..5
      result.push(Order.all.select { |o| o.date.month == n.months.ago.to_date.month }
                           .map { |o| o.grand_total }
                           .inject(0){|sum, n| sum + n }.round(2) )
    end
    result.reverse
  end

  # Validations
  # validates_date :date  # not essential, but permittable
  validates_numericality_of :grand_total, greater_than_or_equal_to: 0, allow_blank: true
  validate :user_is_active_in_system
  validate :school_is_active_in_system
  validate :credit_card_number_is_valid
  validate :expiration_date_is_valid

  # Other methods
  def pay
    return false unless self.payment_receipt.nil?
    generate_payment_receipt
    self.save!
    self.payment_receipt
  end

  def total_weight
    weight = self.order_items.inject(0){|sum, oi| sum += oi.item.weight * oi.quantity}
  end

  def shipping_costs
    calculate_shipping_costs(self.total_weight, base=5.00)
  end

  def credit_card_type
    credit_card.type.nil? ? "N/A" : credit_card.type.name
  end

  # Callbacks
  before_create :set_date_if_not_given
  before_destroy :is_destroyable?
  # after_destroy :remove_unshipped_order_items
  # after_rollback :remove_remaining_unshipped_order_items
  after_rollback :remove_unshipped_order_items

  private
  def user_is_active_in_system
    is_active_in_system(:user)
  end

  def school_is_active_in_system
    is_active_in_system(:school)
  end

  def set_date_if_not_given
    unless self.date && self.date.is_a?(Date)
      self.date = Date.current
    end
  end

  def generate_payment_receipt
    self.payment_receipt = Base64.encode64("order: #{self.id}; amount_paid: #{self.grand_total}; received: #{self.date}; card: #{self.credit_card_type} ****#{self.credit_card_number[-4..-1]}")
  end

  def credit_card
    CreditCard.new(self.credit_card_number, self.expiration_year, self.expiration_month)
  end

  def credit_card_number_is_valid
    return false if self.expiration_year.nil? || self.expiration_month.nil?
    if self.credit_card_number.nil? || credit_card.type.nil?
      errors.add(:credit_card_number, "is not valid")
      return false
    end
    true
  end

  def expiration_date_is_valid
    return false if self.credit_card_number.nil?
    if self.expiration_year.nil? || self.expiration_month.nil? || credit_card.expired?
      errors.add(:expiration_year, "is expired")
      return false
    end
    true
  end

  def is_destroyable?
    @destroyable = self.order_items.shipped.empty?
    remove_unshipped_order_items
    return @destroyable
  end

  def remove_unshipped_order_items
    self.order_items.unshipped.each{ |oi| oi.destroy } unless destroyable.nil?
  end

  # def remove_remaining_unshipped_order_items
  #   if !destroyable.nil? && destroyable == false
  #     remove_unshipped_order_items
  #   end
  #   @destroyable = nil
  # end

end
