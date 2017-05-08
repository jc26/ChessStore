require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should have_many(:orders)
  should have_secure_password

  # test validations
  should validate_presence_of(:username)
  should validate_presence_of(:email)
  should validate_uniqueness_of(:username).case_insensitive
  should validate_uniqueness_of(:email).case_insensitive
  should validate_inclusion_of(:role).in_array(%w[admin manager shipper customer])

  # additional tests for role (not essential)
  should allow_value("admin").for(:role)
  should allow_value("manager").for(:role)
  should allow_value("shipper").for(:role)
  should allow_value("customer").for(:role)
  should_not allow_value("bad").for(:role)
  should_not allow_value("hacker").for(:role)
  should_not allow_value(10).for(:role)
  should_not allow_value("leader").for(:role)
  should_not allow_value(nil).for(:role)

  # tests for phone
  should allow_value("4122683259").for(:phone)
  should allow_value("412-268-3259").for(:phone)
  should allow_value("412.268.3259").for(:phone)
  should allow_value("(412) 268-3259").for(:phone)
  should allow_value(nil).for(:phone)
  should_not allow_value("2683259").for(:phone)
  should_not allow_value("14122683259").for(:phone)
  should_not allow_value("4122683259x224").for(:phone)
  should_not allow_value("800-EAT-FOOD").for(:phone)
  should_not allow_value("412/268/3259").for(:phone)
  should_not allow_value("412-2683-259").for(:phone)


  # context
  context "Within context" do
    setup do
      create_employee_users
    end

    teardown do
      destroy_employee_users
    end

    should "have a name method for last, first name listing" do
      assert_equal "Heimann, Mark", @mark.name
    end

    should "have a proper_name method for first & last name listing" do
      assert_equal "Mark Heimann", @mark.proper_name
    end

    should "require users to have unique, case-insensitive usernames" do
      assert_equal "mark", @mark.username
      # try to switch to Alex's username 'tank'
      @mark.username = "TANK"
      deny @mark.valid?, "#{@mark.username}"
    end

    should "require a password for new users" do
      bad_user = FactoryGirl.build(:user, username: "wheezy", password: nil)
      deny bad_user.valid?
    end

    should "require passwords to be confirmed and matching" do
      bad_user_1 = FactoryGirl.build(:user, username: "wheezy", password: "secret", password_confirmation: nil)
      deny bad_user_1.valid?
      bad_user_2 = FactoryGirl.build(:user, username: "wheezy", password: "secret", password_confirmation: "sauce")
      deny bad_user_2.valid?
    end

    should "require passwords to be at least four characters" do
      bad_user = FactoryGirl.build(:user, username: "wheezy", password: "no", password_confirmation: "no")
      deny bad_user.valid?
    end

    should "have a role? method to use in authorization" do
      assert @mark.role?(:admin)
      deny @mark.role?(:shipper)
      assert @shipper.role?(:shipper)
      deny @shipper.role?(:admin)
    end

    should "have a working scope called active" do
      assert_equal ["inventory","mark","shipper","tank"], User.active.all.map(&:username).sort
    end

    should "have a working scope called inactive" do
      assert_equal ["old_shipper"], User.inactive.all.map(&:username).sort
    end

    should "have a working scope called employees" do
      create_customer_users
      assert @markv.active
      assert_equal ["inventory","mark","old_shipper","shipper","tank"], User.employees.all.map(&:username).sort
      destroy_customer_users
    end

    should "have a working scope called customers" do
      create_customer_users
      assert @mark .active
      assert_equal ["bjunker", "imadueme", "kirvine", "melfree", "mvella"], User.customers.all.map(&:username).sort
      destroy_customer_users
    end

    should "have a working scope called alphabetical" do
      assert_equal ["Heimann, Alex", "Heimann, Mark", "Manager, Inventory", "Shipper, Old", "Shipper, Young"], User.alphabetical.all.map(&:name)
    end

    should "have a working scope called search" do
      create_customer_users
      assert_equal ["Heimann, Mark", "Vella, Mark"], User.search("mark").alphabetical.map { |u| u.name }
      destroy_customer_users
    end

    should "have a working instance method called money_spent" do
      create_customer_users
      create_schools
      create_orders
      assert_equal 76.4, @markv.money_spent
      destroy_customer_users
      destroy_schools
      destroy_orders
    end

    should "shows that Mark's phone is stripped of non-digits" do
      assert_equal "4122688211", @mark.phone
    end

    should "shows that a user cannot be destroyed" do
      assert @mark.active
      deny @mark.destroy
      @mark.reload
      assert @mark.active
    end

  end
end
