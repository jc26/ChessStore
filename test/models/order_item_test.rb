require 'test_helper'

class OrderItemTest < ActiveSupport::TestCase

  # test relationships
  should belong_to(:order)
  should belong_to(:item)

  # test simple validations with matchers
  should validate_numericality_of(:quantity).only_integer.is_greater_than(0)
  # should allow_value(Date.current).for(:shipped_on)
  # should allow_value(1.day.ago.to_date).for(:shipped_on)
  # should allow_value(1.day.from_now.to_date).for(:shipped_on)
  # should_not allow_value("bad").for(:shipped_on)
  # should_not allow_value(2).for(:shipped_on)
  # should_not allow_value(3.14159).for(:shipped_on)

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

    should "verify that the item is active in the system" do
      @bad_order_item = FactoryGirl.build(:order_item, order: @markv_o2, item: @zagreb_pieces)
      deny @bad_order_item.valid?
    end

    should "have a method which calculates the subtotal for current date" do
      assert_equal (4.95*5), @karen_o1_1.subtotal
      assert_equal (2.95*10), @markv_o2_1.subtotal
    end

    should "have a method which calculates the subtotal for a past date" do
      assert_equal (3.99*5), @karen_o1_1.subtotal(1.year.ago.to_date)
    end

    should "return nil for a subtotal for a future date" do
      assert_nil @markv_o2_1.subtotal(1.year.from_now.to_date)
    end

    should "have shipped method set the shipped_on date" do
      assert_nil @markv_o2_1.shipped_on          # confirm not yet shipped
      @markv_o2_1.shipped                        # ship the item
      @markv_o2_1.reload                         # reload item data from database
      assert_not_nil @markv_o2_1.shipped_on      # confirm shipped_on date set
      assert_equal Date.current, @markv_o2_1.shipped_on
    end

    should "have shipped method reduces inventory level by correct amount" do
      assert_nil @markv_o2_1.shipped_on       # confirm not yet shipped
      current_item = @markv_o2_1.item
      current_inventory = current_item.inventory_level
      @markv_o2_1.shipped                      # ship the item
      current_item.reload
      assert_equal (current_inventory - 10), current_item.inventory_level
    end

    should "have unshipped method set the shipped_on to nil" do
      assert_equal 4.days.ago.to_date, @karen_o1_1.shipped_on
      @karen_o1_1.unshipped
      @karen_o1_1.reload
      assert_nil @karen_o1_1.shipped_on
    end

    should "have unshipped method increases inventory level by correct amount" do
      assert_equal 4.days.ago.to_date, @karen_o1_1.shipped_on
      current_item = @karen_o1_1.item
      current_inventory = current_item.inventory_level
      @karen_o1_1.unshipped
      current_item.reload
      assert_equal (current_inventory + 5), current_item.inventory_level
    end

    should "have a working scope called shipped" do
      assert_equal 5, OrderItem.shipped.count
    end

    should "have a working scope called unshipped" do
      assert_equal 6, OrderItem.unshipped.count
    end
  end
end
