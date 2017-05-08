require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  # test relationships
  should have_many(:order_items)
  should have_many(:item_prices)
  should have_many(:purchases)
  should have_many(:orders).through(:order_items)

  # test nested attributes
  should accept_nested_attributes_for(:item_prices).allow_destroy(true)

  # test validations with matchers
  should validate_presence_of(:name)
  should validate_uniqueness_of(:name).case_insensitive
  should validate_numericality_of(:weight).is_greater_than(0)
  should validate_numericality_of(:inventory_level).only_integer.is_greater_than_or_equal_to(0)
  should validate_numericality_of(:reorder_level).only_integer.is_greater_than_or_equal_to(0)
  should validate_inclusion_of(:category).in_array(Item::CATEGORIES.to_h.values)

  # not necessary, but don't hurt...
  should allow_value(10).for(:weight)
  should allow_value(10.5).for(:weight)
  should allow_value(25).for(:inventory_level)
  should allow_value(20).for(:reorder_level)
  should allow_value(0).for(:inventory_level)
  should allow_value(0).for(:reorder_level)

  should_not allow_value(-10).for(:inventory_level)
  should_not allow_value(10.5).for(:inventory_level)
  should_not allow_value(-10).for(:reorder_level)
  should_not allow_value(10.5).for(:reorder_level)
  should_not allow_value(-1).for(:weight)
  should_not allow_value(0).for(:weight)

  # set up context
  context "Within context" do
    setup do
      create_pieces
    end

    teardown do
      destroy_pieces
    end

    should "show that there are four items in in alphabetical order" do
      assert_equal ["Basic Chess Pieces", "Weighted Chess Pieces", "Wooden Chess Pieces", "Zagreb Chess Pieces"], Item.alphabetical.all.map(&:name)
    end

    should "show that there are three active items and one inactive item" do
      assert_equal ["Basic Chess Pieces", "Weighted Chess Pieces", "Wooden Chess Pieces"], Item.active.all.map(&:name).sort
      assert_equal ["Zagreb Chess Pieces"], Item.inactive.all.map(&:name).sort
    end

    should "show that there is a working for_category scope" do
      create_clocks
      assert_equal ["Basic Chess Pieces", "Weighted Chess Pieces", "Wooden Chess Pieces", "Zagreb Chess Pieces"], Item.for_category('pieces').all.map(&:name).sort
      assert_equal 4, Item.for_category('clocks').all.count
      destroy_clocks
    end

    should "show that there is a working for_color scope" do
      create_clocks
      assert_equal ["Basic Analog Chess Clock", "Basic Chess Pieces", "Weighted Chess Pieces", "ZMF-II Digital Chess Timer Green"], Item.for_color('black').all.map(&:name).sort
      assert_equal 1, Item.for_color('red').all.count
      destroy_clocks
    end

    should "show that there is a working need_reorder scope" do
      assert_equal 0, Item.need_reorder.all.count
      @weighted_pieces.inventory_level = 20 # factories set reorder_level at 25
      @weighted_pieces.save
      assert_equal ["Weighted Chess Pieces"], Item.need_reorder.all.map(&:name).sort
    end

    should "show that the class method search is working" do
      create_boards
      assert_equal ["Vinyl Chess Board - Black & White", "Vinyl Chess Board - Blue & White", "Vinyl Chess Board - Green & White", "Vinyl Chess Board - Red & White"],
                    Item.search("vinyl").alphabetical.map { |i| i.name }
      destroy_boards
    end

    should "have an instance method reorder? for items where inventory too low" do
      deny @basic_pieces.reorder?
      deny @weighted_pieces.reorder?
      @weighted_pieces.inventory_level = 20
      @weighted_pieces.save
      assert @weighted_pieces.reorder?
    end

    should "return correct current price" do
      create_piece_prices_wholesale
      assert_equal 4.95, @basic_pieces.current_price
      assert_equal 8.95, @weighted_pieces.current_price
      destroy_piece_prices_wholesale
    end

    should "return correct current manufacturer price" do
      create_piece_prices_manufacturer
      assert_equal 2.50, @basic_pieces.current_manufacturer_price
      assert_equal 4.50, @weighted_pieces.current_manufacturer_price
      destroy_piece_prices_manufacturer
    end

    should "return correct price for past date" do
      create_piece_prices_wholesale
      assert_equal 4.25, @basic_pieces.price_on_date(8.months.ago.to_date)
      assert_equal 7.50, @weighted_pieces.price_on_date(8.months.ago.to_date)
      destroy_piece_prices_wholesale
    end

    should "return correct manufacturer price for past date" do
      create_piece_prices_manufacturer
      assert_equal 2.25, @basic_pieces.manufacturer_price_on_date(8.months.ago.to_date)
      assert_equal 3.50, @weighted_pieces.manufacturer_price_on_date(8.months.ago.to_date)
      destroy_piece_prices_manufacturer
    end

    should "return nil for current or past price if not set" do
      create_piece_prices_wholesale
      create_piece_prices_manufacturer
      assert_nil @zagreb_pieces.current_manufacturer_price
      assert_nil @zagreb_pieces.current_price
      assert_nil @basic_pieces.manufacturer_price_on_date(36.months.ago.to_date)
      assert_nil @weighted_pieces.price_on_date(36.months.ago.to_date)
      destroy_piece_prices_wholesale
      destroy_piece_prices_manufacturer
    end

    should "show that an item that has been shipped cannot be destroyed" do
      create_boards
      create_clocks
      create_supplies
      create_item_prices
      create_customer_users
      create_schools
      create_orders
      create_order_items
      @demo_board.destroy
      deny @demo_board.destroyed?
      destroy_boards
      destroy_clocks
      destroy_supplies
      destroy_item_prices
      destroy_customer_users
      destroy_schools
      destroy_orders
      destroy_order_items
    end

    should "show that an item that has never shipped can be destroyed" do
      create_boards
      create_clocks
      create_supplies
      create_item_prices
      create_customer_users
      create_schools
      create_orders
      create_order_items
      @analog_clock.destroy
      assert @analog_clock.destroyed?
      destroy_boards
      destroy_clocks
      destroy_supplies
      destroy_item_prices
      destroy_customer_users
      destroy_schools
      destroy_orders
      destroy_order_items
    end

    should "show that a destroyed item is not part of unshipped, unpaid orders" do
      create_boards
      create_clocks
      create_supplies
      create_item_prices
      create_customer_users
      create_schools
      create_orders
      create_order_items
      # add the maple board (never ordered before) to Mark's order items
      extra_item = FactoryGirl.create(:order_item, order: @markv_o2, item: @maple_board, quantity: 1)
      assert_equal 2, @markv_o2.order_items.count
      @maple_board.destroy
      assert @maple_board.destroyed?
      @markv_o2.reload
      # the maple board should be deleted from Mark's order items
      assert_equal 1, @markv_o2.order_items.count
      destroy_boards
      destroy_clocks
      destroy_supplies
      destroy_item_prices
      destroy_customer_users
      destroy_schools
      destroy_orders
      destroy_order_items
    end

    should "make an improperly destroyed item inactive" do
      create_boards
      create_clocks
      create_supplies
      create_item_prices
      create_customer_users
      create_schools
      create_orders
      create_order_items
      assert @basic_pieces.active
      assert_equal 2, @basic_pieces.order_items.count
      @basic_pieces.destroy
      # check that it is now inactive
      deny @basic_pieces.active
      # check that we have removed the item from unshipped orders
      assert_equal 1, @basic_pieces.order_items.count
      destroy_boards
      destroy_clocks
      destroy_supplies
      destroy_item_prices
      destroy_customer_users
      destroy_schools
      destroy_orders
      destroy_order_items
    end

    should "not make an item inactive because of an improper edit" do
      assert @basic_pieces.active
      @basic_pieces.name = nil
      deny @basic_pieces.valid?
      deny @basic_pieces.save
      assert @basic_pieces.active
    end

  end

end
