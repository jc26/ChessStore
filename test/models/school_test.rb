require 'test_helper'

class SchoolTest < ActiveSupport::TestCase
  # test relationships
  should have_many(:orders)
  should have_many(:users).through(:orders)

  # test validations with matchers
  should validate_presence_of(:name)
  should validate_presence_of(:street_1)
  should validate_inclusion_of(:state).in_array(School::STATES_LIST.to_h.values)
  should validate_numericality_of(:min_grade).only_integer.is_greater_than_or_equal_to(0).is_less_than_or_equal_to(12)
  should validate_numericality_of(:max_grade).only_integer

  should allow_value("12345").for(:zip)
  should_not allow_value("1234").for(:zip)
  should_not allow_value("123456").for(:zip)
  should_not allow_value("12345-0001").for(:zip)
  should_not allow_value("1234I").for(:zip)
  should_not allow_value(nil).for(:zip)
  should allow_value(nil).for(:min_grade)
  should allow_value(nil).for(:max_grade)

  context "Within context" do
    setup do
      create_schools
    end

    teardown do
      destroy_schools
    end

    should "have a max grade greater than or equal to min grade" do
      assert_equal 6, @ingomar.min_grade
      @ingomar.max_grade = 6
      assert @ingomar.valid?
      @ingomar.max_grade = 7
      assert @ingomar.valid?
      @ingomar.max_grade = 5
      deny @ingomar.valid?
    end

    should "have a scope to list schools in alphabetical order" do
      assert_equal ["Central Catholic High School","Fairview Elementary School","Ingomar Middle School","Oliver High School","Peebles Elementary School"], School.alphabetical.all.map(&:name)
    end

    should "show that there are two active addresses and one inactive address" do
      assert_equal 4, School.active.all.count
      assert_equal ["Oliver High School"], School.inactive.all.map(&:name).sort
    end


    should "verify school is not already in the system" do
      bad_school = FactoryGirl.build(:school, name: "Fairview Elementary School", street_1: "738 Dorseyville Rd", zip: "15238", min_grade: 2, max_grade: 6)
      # assert bad_school.already_exists?
      deny bad_school.valid?
    end

    should "show that the class method search is working" do
      assert_equal ["Fairview Elementary School", "Peebles Elementary School"],
                    School.search("elementary").active.alphabetical.map { |s| s.name }
    end

    should "allow an existing school to be edited" do
      @cent_cath.street_1 = "5005 Forbes Avenue"
      assert @cent_cath.valid?
    end

    should "not make inactive because of an improper edit" do
      assert @cent_cath.active
      @cent_cath.street_1 = nil
      deny @cent_cath.valid?
      # try to save the invalid record; see that it is not saved (rollback)
      deny @cent_cath.save
      # verify that the rollback did not make the school inactive
      assert @cent_cath.active
    end

    should "be able to make a proper edit" do
      # really testing that school not dup only on create
      assert @cent_cath.active
      @cent_cath.street_1 = "5000 Forbes Avenue"
      assert @cent_cath.valid?
      assert @cent_cath.save
    end

    should "show that a school that has never placed an order can be destroyed" do
      new_school = FactoryGirl.create(:school, name: "Fairview Middle School", street_1: "844 Dorseyville Rd", zip: "15238", min_grade: 6, max_grade: 8)
      new_school.reload
      assert_equal "Fairview Middle School", new_school.name
      new_school.destroy
      assert new_school.destroyed?
    end

    should "make an improperly destroyed school is made inactive" do
      create_customer_users
      create_orders
      assert @fairview.active
      deny @fairview.orders.empty?
      @fairview.destroy
      @fairview.reload
      # verify the school is now inactive
      deny @fairview.active
      # ... and that the orders are still there
      deny @fairview.orders.empty?
      destroy_customer_users
      destroy_orders
    end

  end
end
