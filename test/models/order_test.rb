require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  require 'base64'

  # test relationships
  should have_many(:order_items)
  should have_many(:items).through(:order_items)
  should belong_to(:user)
  should belong_to(:school)

  # test simple validations with matchers
  should validate_numericality_of(:grand_total).is_greater_than_or_equal_to(0)
  # ... if there is a validation on date field
  # should allow_value(Date.current).for(:date)
  # should allow_value(1.day.ago.to_date).for(:date)
  # should allow_value(1.day.from_now.to_date).for(:date)
  # should_not allow_value("bad").for(:date)
  # should_not allow_value(2).for(:date)
  # should_not allow_value(3.14159).for(:date)

   context "Within context" do
    setup do
      create_items
      create_item_prices
      create_customer_users
      create_schools
      create_orders
      create_order_items
    end

    teardown do
      destroy_items
      destroy_item_prices
      destroy_customer_users
      destroy_schools
      destroy_orders
      destroy_order_items
    end

    should "verify that the date is set for today unless otherwise specified" do
      assert_equal @karen_o1.date, 5.months.ago.to_date  # a specified date is unchanged
      markv_o3 = FactoryGirl.create(:order, user: @markv, school: @ingomar, grand_total: 100.00, date: nil)
      assert_equal markv_o3.date, Date.current  # an order without any date is set to today by default
      markv_o3.delete
      ben_o2 = FactoryGirl.create(:order, user: @ben, school: @cent_cath, grand_total: 100.00, date: "groundhog day")
      assert_equal ben_o2.date, Date.current  # an order without a legitimate date is set to today by default
      ben_o2.delete
    end

    should "verify that the user is active in the system" do
      # inactive user
      @bad_order = FactoryGirl.build(:order, user: @melanie, school: @cent_cath, grand_total: 5.25, payment_receipt: "dcmjgwwtsd39x6wfc1", date: 5.days.ago.to_date)
      deny @bad_order.valid?
      # non-existent user
      ghost = FactoryGirl.build(:user, first_name: "Ghost")
      non_user_order = FactoryGirl.build(:order, user: ghost, school: @cent_cath)
      deny non_user_order.valid?
    end

    should "verify that the school is active in the system" do
      # inactive school
      @bad_order = FactoryGirl.build(:order, user: @karen, school: @oliver, grand_total: 5.25, payment_receipt: "dcmjgwwtsd39x6wfc1", date: 5.days.ago.to_date)
      deny @bad_order.valid?
      # non-existent school
      ghost = FactoryGirl.build(:school, name: "Ghost")
      non_school_order = FactoryGirl.build(:order, user: @karen, school: ghost)
      deny non_school_order.valid?
    end

    should "have a pay method which generates a receipt string" do
      assert_nil @markv_o2.payment_receipt
      @markv_o2.pay
      @markv_o2.reload
      assert_not_nil @markv_o2.payment_receipt
    end

    should "not be able to pay twice for same order" do
      assert_nil @markv_o2.payment_receipt
      first_pay = @markv_o2.pay
      assert_not_nil @markv_o2.payment_receipt
      second_pay = @markv_o2.pay
      deny second_pay
      assert_not_equal first_pay, second_pay
    end

    should "have a properly formatted payment receipt" do
      @karen_o1.pay
      assert_equal "order: #{@karen_o1.id}; amount_paid: #{@karen_o1.grand_total}; received: #{@karen_o1.date}; card: #{@karen_o1.credit_card_type} ****#{@karen_o1.credit_card_number[-4..-1]}", Base64.decode64(@karen_o1.payment_receipt)
    end

    should "correctly calculate total weight of the order" do
      assert_equal 8.75, @karen_o1.total_weight
      assert_equal 6.75, @karen_o3.total_weight
      assert_equal 2.50, @markv_o2.total_weight
    end

    should "correctly assess shipping costs of the order" do
      assert_equal 6.25, @karen_o1.shipping_costs
      assert_equal 5.75, @karen_o3.shipping_costs
      assert_equal 5.00, @markv_o2.shipping_costs
    end

    should "correctly destroy an order that is unshipped" do
      order_id = @ben_o1.id
      assert_not_nil OrderItem.find_by_order_id(order_id)
      @ben_o1.destroy
      assert @ben_o1.destroyed?
      assert_nil OrderItem.find_by_order_id(order_id)
    end

    should "not destroy an order that has already fully shipped" do
      # verify that this was a shipped order
      deny @karen_o1.order_items.shipped.empty?
      @karen_o1.destroy
      deny @karen_o1.destroyed?
      # verify that nothing was deleted from order_items
      deny @karen_o1.order_items.empty?
    end

    should "not destroy an order that has partially shipped" do
      # ship part of an order
      assert_equal 3, @ben_o1.order_items.unshipped.count
      @ben_o1_3.shipped_on = Date.current
      @ben_o1_3.save
      @ben_o1.reload
      assert_equal 2, @ben_o1.order_items.unshipped.count
      @ben_o1.destroy
      @ben_o1.reload
      deny @ben_o1.destroyed?
      # verify that remaining items (2) were deleted from order_items
      assert_equal 1, @ben_o1.order_items.shipped.count
      assert_equal 0, @ben_o1.order_items.unshipped.count
    end

    should "not remove order items because of an improper edit" do
      assert_equal 3, @ben_o1.order_items.unshipped.count
      @ben_o1.school_id = @oliver.id
      deny @ben_o1.valid?
      deny @ben_o1.save
      assert_equal 3, @ben_o1.order_items.unshipped.count
    end

    should "have a working scope called paid" do
      assert_equal [43.9, 79.75, 94.95, 388.5], Order.paid.all.map(&:grand_total).sort
    end

    should "have a working scope called chronological" do
      assert_equal [54.5, 32.5, 388.5, 79.75, 43.9, 94.95], Order.chronological.all.map(&:grand_total)
    end

    should "have a working scope called for_school" do
      assert_equal [54.5, 79.75, 94.95], Order.for_school(@fairview).all.map(&:grand_total).sort
    end

    should "have a working class method called not_shipped" do
      assert_equal [388.5, 54.5, 32.5], Order.not_shipped.all.map(&:grand_total).sort.reverse
    end

    should "have a working class method called search" do
      assert_equal ["Mark"], Order.search("5").map { |o| o.user.first_name }
    end

    should "have a working class method called revenue_from_last_6_months" do
      assert_equal [94.95, 0.0, 0.0, 0.0, 512.15, 87.0], Order.revenue_from_last_6_months
    end

    should "have accessor methods for credit card data" do
      assert Order.new.respond_to? :credit_card_number
      assert Order.new.respond_to?(:credit_card_number=)
      assert Order.new.respond_to? :expiration_year
      assert Order.new.respond_to?(:expiration_year=)
      assert Order.new.respond_to? :expiration_month
      assert Order.new.respond_to?(:expiration_month=)
    end

    should "identify different types of credit card by their pattern" do
      # lengths are all correct for these tests, but prefixes are not
      assert @karen_o3.valid?
      numbers = {4123456789012=>"VISA", 4123456789012345=>"VISA", 5123456789012345=>"MC", 5412345678901234=>"MC", 6512345678901234=>"DISC", 6011123456789012=>"DISC", 30012345678901=>"DCCB", 30312345678901=>"DCCB", 341234567890123=>"AMEX", 371234567890123=>"AMEX",7123456789012=>"N/A",30612345678901=>"N/A",351234567890123=>"N/A",5612345678901234=>"N/A",6612345678901234=>"N/A"}
      numbers.each do |num, name|
        @karen_o3.credit_card_number = num
        assert_equal name, @karen_o3.credit_card_type, "#{@karen_o3.credit_card_type} :: #{@karen_o3.credit_card_number}"
      end
    end

    should "detect different types of valid and invalid credit card numbers" do
      # similar to previous, but testing the actual validation method exists
      @karen_o3.credit_card_number = nil
      deny @karen_o3.valid?
      valid_numbers = %w[4123456789012 4123456789012345 5123456789012345 5412345678901234 6512345678901234 6011123456789012 30012345678901 30312345678901 341234567890123 371234567890123]
      valid_numbers.each do |num|
        @karen_o3.credit_card_number = num
        assert @karen_o3.valid?, "#{@karen_o3.credit_card_number}"
      end
      invalid_numbers = %w[7123456789012 30612345678901 351234567890123 5612345678901234 6612345678901234]
      invalid_numbers.each do |num|
        @karen_o3.credit_card_number = num
        deny @karen_o3.valid?, "#{@karen_o3.credit_card_number}"
      end
    end

    should "detect different types of too-short credit card numbers" do
      # prefixes are all correct for these tests, but length is too short for card type
      assert @karen_o3.valid?
      short_numbers = %w[412345678901 412345678901234 512345678901234 541234567890123 651234567890123 601112345678901 3001234567890 3031234567890 34123456789012 37123456789012]
      short_numbers.each do |num|
        @karen_o3.credit_card_number = num
        deny @karen_o3.valid?, "#{@karen_o3.credit_card_number}"
      end
    end

    should "detect different types of too-long credit card numbers" do
      # prefixes are all correct for these tests, but length is too long for card type
      assert @karen_o3.valid?
      long_numbers = %w[41234567890121 41234567890123451 51234567890123451 54123456789012341 65123456789012341 60111234567890121 300123456789011 303123456789011 3412345678901231 3712345678901231]
      long_numbers.each do |num|
        @karen_o3.credit_card_number = num
        deny @karen_o3.valid?, "#{@karen_o3.credit_card_number}"
      end
    end

    should "detect valid and invalid expiration dates" do
      assert @karen_o3.valid?
      @karen_o3.expiration_year = 1.year.ago.year
      deny @karen_o3.valid?
      @karen_o3.expiration_year = Date.current.year
      @karen_o3.expiration_month = Date.current.month
      assert @karen_o3.valid?
      @karen_o3.expiration_year = Date.current.year
      @karen_o3.expiration_month = Date.current.month - 1
      deny @karen_o3.valid?
      @karen_o3.expiration_year = Date.current.year
      @karen_o3.expiration_month = Date.current.month + 1
      assert @karen_o3.valid?
    end

  end
end
