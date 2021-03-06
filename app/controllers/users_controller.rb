class UsersController < ApplicationController
  before_action :check_login, except: [:new, :create, :choose]
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :set_heading, except: [:dashboard, :new, :create]
  authorize_resource
  # skip_authorize_resource only: [:choose, :new, :create]
  skip_authorize_resource only: [:choose, :new, :create]

  def index
    if params[:search]
      @users = User.all.alphabetical.search(params[:search])
      if @users.empty?
        redirect_to users_path, notice: "Sorry, there are no users with name similar to '#{params[:search]}.'"
      end
    else
      @users = User.all.alphabetical
    end
    @customers = @users.customers.paginate(:page => params[:customers_page]).per_page(10)
    @employees = @users.employees.paginate(:page => params[:employees_page]).per_page(10)
  end

  def show
    @orders = @user.orders.chronological.to_a
  end

  def new
    if params[:from]
      @current_user = User.new

    end
    @user = User.new
    @school = School.new
    if params[:is_employee]
      @is_employee = true
    end
    @title = "REGISTER"
    @path_name = "/users/new"
  end

  def create
    @user = User.new(user_params)
    # @title = "ITEMS"
    # @path_name = "/items"
    if @user.save
      session[:user_id] = @user.id
      if logged_in?
        redirect_to user_path(@user), notice: "#{@user.role.capitalize}, #{@user.proper_name}, has been made."
      else
        redirect_to login_path, notice: "Thank you for signing up!"
      end
    else
      if logged_in?
        @is_employee = true
      end
      flash[:error] = "This user could not be created."
      render "new"
    end
  end

  def edit
  end

  def update
    @user = current_user
    if @user.update_attributes(user_params)
      flash[:notice] = "#{@user.proper_name} is updated."
      redirect_to @user
    else
      render :action => 'edit'
    end
  end

  def dashboard
    if current_user.role?(:admin)
      @boards_revenue = OrderItem.revenue_by_category('boards')
      @pieces_revenue = OrderItem.revenue_by_category('pieces')
      @clocks_revenue = OrderItem.revenue_by_category('clocks')
      @supplies_revenue = OrderItem.revenue_by_category('supplies')
      @best_customers = User.all.sort_by { |u| u.money_spent }.reverse.first(3)
      @last_6_months = []
      for n in 0..5
        @last_6_months.push("#{n.months.ago.to_date.strftime('%b')} #{n.months.ago.to_date.year}")
      end
      @last_6_months.reverse!.to_a
      @revenue_from_last_6_months = Order.revenue_from_last_6_months.to_a
      @total_customers = User.all.customers.count
      @orders_placed_today = Order.all.select{ |o| o.date == Date.current }.count
      @items_need_reorder = Item.all.active.need_reorder.count
      @orders_need_shipped = Order.all.not_shipped.count
    elsif current_user.role?(:manager)
      @items_need_reorder = Item.all.active.need_reorder.alphabetical.to_a
      @admins = User.active.for_role("admin").alphabetical.to_a
      @managers = User.active.for_role("manager").alphabetical.to_a - [current_user]
      @shippers = User.active.for_role("shipper").alphabetical.to_a
    elsif current_user.role?(:shipper)
      @pending_orders = Order.not_shipped.chronological.to_a
    elsif current_user.role?(:customer)
      @pending_orders = current_user.orders.not_shipped.chronological.paginate(:page => params[:pending_page]).per_page(10)
      @last_3_orders = current_user.orders.shipped.chronological.first(3).to_a
    end
    @title = "DASHBOARD"
    @path_name = "/dashboard"
  end

  def choose
    @schools = School.all.active.alphabetical.to_a
    @school = School.new
    @title = "REGISTER"
    @path_name = "/users/new"
  end

  private
  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :username, :email, :phone, :role, :password, :password_confirmation, :active)
  end

  def set_heading
    @title = "USERS"
    @path_name = "/users"
  end

end
