class UsersController < ApplicationController
  layout 'login', :only => [:new]

  before_action :check_login, except: [:new, :create]
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :set_heading, except: [:dashboard]

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
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to login_path, notice: "Thank you for signing up!"
    else
      flash[:error] = "This user could not be created."
      render "new"
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_attributes(user_params)
      flash[:notice] = "#{@user.name} is updated."
      redirect_to @user
    else
      render :action => 'edit'
    end
  end

  def dashboard
    @boards_revenue = OrderItem.all.select { |oi| oi.item.category == 'boards' }.map { |oi| oi.subtotal }.inject(0){|sum, n| sum + n }.round(2)
    @pieces_revenue = OrderItem.all.select { |oi| oi.item.category == 'pieces' }.map { |oi| oi.subtotal }.inject(0){|sum, n| sum + n }.round(2)
    @clocks_revenue = OrderItem.all.select { |oi| oi.item.category == 'clocks' }.map { |oi| oi.subtotal }.inject(0){|sum, n| sum + n }.round(2)
    @supplies_revenue = OrderItem.all.select { |oi| oi.item.category == 'supplies' }.map { |oi| oi.subtotal }.inject(0){|sum, n| sum + n }.round(2)
    @best_customers = User.all.sort_by { |u| u.money_spent }.reverse.first(3)
    @last_6_months = []
    for n in 0..5
      @last_6_months.push("#{n.months.ago.to_date.strftime('%b')} #{n.months.ago.to_date.year}")
    end
    @last_6_months.reverse!.to_a
    @revenue_from_last_6_months = Order.revenue_from_last_6_months.to_a
    @total_customers = User.all.customers.count
    @orders_placed_today = Order.all.select{ |o| o.date == Date.current }.count
    @items_need_reorders = Item.all.need_reorder.count
    @orders_need_shipped = Order.all.not_shipped.count
    @title = "DASHBOARD"
    @path_name = "/dashboard"
  end

  private
  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :email, :phone, :role, :password, :password_confirmation, :active)
  end

  def set_heading
    @title = "USERS"
    @path_name = "/users"
  end

end
