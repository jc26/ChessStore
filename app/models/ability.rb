class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.role? :admin
      can :manage, :all

    elsif user.role? :manager
      # can see a list of everything
      can :read, :all
      # can see create shippers and customers
      can :create, User do |u|
        u.role? :shipper
      end
      # can update information of shippers, customers, and themselves
      can :update, User do |u|
        u.role? :shipper || u.id == user.id
      end
      # can create, read, update, and destroy Item
      can :manage, Item
      # create new prices for a particular item
      can :create, ItemPrice
      # can adjust the inventory levels for an item by adding purchases
      can :create, Purchase

      can :read, School
      can :dashboard, User
      # they can update their own profile
      can :toggle, OrderItem

    elsif user.role? :shipper
      can [:show, :update], User do |u|
        u.id == user.id
      end
      can :read, Order
      can [:read, :update], OrderItem
      can :read, Item
      can :dashboard, User
      can :toggle, OrderItem
      can :read, School

    elsif user.role? :customer
      can [:read, :update], User do |u|
        u.id == user.id
      end
      can [:show, :destroy], Order do |this_order|
        my_orders = user.orders.map(&:id)
        my_orders.include? this_order.id
      end
      can :new, Order
      can :create, Order
      can :read, Item
      can [:read, :create], School
      can :dashboard, User
      can :add_item, Item
      can :remove_item, Item
      can :empty_cart, Order
      can :checkout, Order
      can :cart, Order

    else
      can :create, User
      can :read, Domain
      can :choose, User
      can :create, School
    end
  end
end
