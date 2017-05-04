class School < ActiveRecord::Base

  # get an array of the states in U.S.
  STATES_LIST = [['Alabama', 'AL'],['Alaska', 'AK'],['Arizona', 'AZ'],['Arkansas', 'AR'],['California', 'CA'],['Colorado', 'CO'],['Connectict', 'CT'],['Delaware', 'DE'],['District of Columbia ', 'DC'],['Florida', 'FL'],['Georgia', 'GA'],['Hawaii', 'HI'],['Idaho', 'ID'],['Illinois', 'IL'],['Indiana', 'IN'],['Iowa', 'IA'],['Kansas', 'KS'],['Kentucky', 'KY'],['Louisiana', 'LA'],['Maine', 'ME'],['Maryland', 'MD'],['Massachusetts', 'MA'],['Michigan', 'MI'],['Minnesota', 'MN'],['Mississippi', 'MS'],['Missouri', 'MO'],['Montana', 'MT'],['Nebraska', 'NE'],['Nevada', 'NV'],['New Hampshire', 'NH'],['New Jersey', 'NJ'],['New Mexico', 'NM'],['New York', 'NY'],['North Carolina','NC'],['North Dakota', 'ND'],['Ohio', 'OH'],['Oklahoma', 'OK'],['Oregon', 'OR'],['Pennsylvania', 'PA'],['Rhode Island', 'RI'],['South Carolina', 'SC'],['South Dakota', 'SD'],['Tennessee', 'TN'],['Texas', 'TX'],['Utah', 'UT'],['Vermont', 'VT'],['Virginia', 'VA'],['Washington', 'WA'],['West Virginia', 'WV'],['Wisconsin ', 'WI'],['Wyoming', 'WY']].freeze

  # Relationships
  has_many :orders
  has_many :users, through: :orders

  # Scopes
  scope :alphabetical,  -> { order(:name) }
  scope :active,        -> { where(active: true) }
  scope :inactive,      -> { where(active: false) }

  # Validations
  validates_presence_of :name, :street_1
  validates_format_of :zip, with: /\A\d{5}\z/, message: "should be five digits long"
  validates_inclusion_of :state, in: STATES_LIST.map{|key, value| value}, message: "is not an option"
  validates_numericality_of :min_grade, greater_than_or_equal_to: 0, less_than_or_equal_to: 12, only_integer: true, allow_blank: true
  validates_numericality_of :max_grade, greater_than_or_equal_to: :min_grade, less_than_or_equal_to: 12, only_integer: true, allow_blank: true
  validates_inclusion_of :state, in: STATES_LIST.to_h.values, message: "is not an option"
  validate :school_is_not_a_duplicate, on: :create

  def already_exists?
    School.where(name: self.name, zip: self.zip).size == 1
  end

  def self.search(query)
    where("name LIKE ?", "%#{query}%")
  end

  # Callbacks
  before_destroy :is_destroyable?
  after_rollback :make_inactive_if_trying_to_destroy

  # Other methods
  attr_reader :destroyable

  private
  def is_destroyable?
    @destroyable = self.orders.empty?
  end

  def make_inactive_if_trying_to_destroy
    if !@destroyable.nil? && @destroyable == false
      self.update_attribute(:active, false)
    end
    @destroyable = nil
  end

  def school_is_not_a_duplicate
    return true if self.name.nil? || self.street_1.nil? || self.zip.nil?
    if self.already_exists?
      errors.add(:name, "already exists for this school at this location")
    end
  end
end
