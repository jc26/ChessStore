class Ability
  include CanCan::Ability

  def initialize(user)
    # set user to new User if not logged in
    user ||= User.new # i.e., a guest user

    # set authorizations for different user roles
    if user.role? :admin
      # they get to do it all
      can :manage, :all

    elsif user.role? :manager
      # can see a list of everything
      can :read, :all
      # can see create shippers and customers
      can :create, User do |u|
        u.role? :manager ||  u.role? :shipper
      end
      # can update information of shippers, customers, and themselves
      can :update, User do |u|
        u.role? :manager || u.role? :shipper || u.id == user.id
      end
      # can create, read, update, and destroy Item
      can :manage, Item
      # create new prices for a particular item
      can :create, ItemPrice
      # can adjust the inventory levels for an item by adding purchases
      can :create, Purchase

      # they can update their own profile
      can :update, User do |u|
        u.id == user.id
      end

      # # they can read their own projects' data
      # can :read, Project do |this_project|
      #   my_projects = user.projects.map(&:id)
      #   my_projects.include? this_project.id
      # end
      # # they can create new projects for themselves
      # can :create, Project
      #
      # # they can update the project only if they are the manager (creator)
      # can :update, Project do |this_project|
      #   managed_projects = user.projects.map{|p| p.id if p.manager_id == user.id}
      #   managed_projects.include? this_project.id
      # end
      #
      # # they can read tasks in these projects
      # can :read, Task do |this_task|
      #   project_tasks = user.projects.map{|p| p.tasks.map(&:id)}.flatten
      #   project_tasks.include? this_task.id
      # end
      #
      # # they can update tasks in these projects
      # can :update, Task do |this_task|
      #   project_tasks = user.projects.map{|p| p.tasks.map(&:id)}.flatten
      #   project_tasks.include? this_task.id
      # end
      #
      # # they can create new tasks for these projects
      # can :create, Task do |this_task|
      #   my_projects = user.projects.map(&:id)
      #   my_projects.include? this_task.project_id
      # end

    elsif user.role? :shipper
      can [:read, :update], User do |u|
        u.id == user.id
      end
      can :read, Order
      can [:read, :update], OrderItem
      can :read, Item

    elsif user.role? :customer
      can [:read, :update], User do |u|
        u.id == user.id
      end
      can :manage, Order do |this_order|
        my_orders = user.orders.map(&:id)
        my_orders.include? this_order.id
      end
      can :read, Item
      can :create, School

    else
      # guests can only read domains covered (plus home pages)
      can :read, Domain
    end
  end
end
