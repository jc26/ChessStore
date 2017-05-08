class OrdersController < ApplicationController
  include ChessStoreHelpers::Cart
  include ChessStoreHelpers::Shipping

  before_action :check_login
  before_action :set_order, only: [:show, :update, :destroy]
  before_action :set_heading, except: [:cart, :checkout]
  before_action :set_total_cart_vars, only: [:cart, :checkout]

  def index
    if params[:search]
      @pending_orders = Order.search(params[:search]).not_shipped.chronological.paginate(:page => params[:pending_page]).per_page(10)
      @completed_orders = Order.search(params[:search]).shipped.chronological.paginate(:page => params[:completed_page]).per_page(10)
      if @pending_orders.empty? && @completed_orders.empty?
        redirect_to orders_path, notice: "Sorry, there were no orders with id '#{params[:search]}.'"
      end
    else
      @pending_orders = Order.not_shipped.chronological.paginate(:page => params[:pending_page]).per_page(10)
      @completed_orders = Order.shipped.chronological.paginate(:page => params[:completed_page]).per_page(10)
    end
  end

  def show
  end

  def new
  end

  def create
    @order = Order.new(order_params)
    @order.grand_total = calculate_cart_shipping + calculate_cart_items_cost
    if @order.save
      @order.pay
      @order.save
      save_each_item_in_cart(@order)
      clear_cart
      redirect_to @order, notice: "Thanks for ordering from the Chess Store! Your order will arrive very soon!"
    else
      redirect_to checkout_path
    end
  end

  def edit
  end

  def update
  end

  def destroy
    @order.destroy
    redirect_to orders_url, notice: "The order has been removed from the system."
  end

  def cart
    @title = "CART"
    @path_name = "/cart"
  end

  def empty_cart
    clear_cart
    redirect_to cart_path, notice: "Your cart was emptied."
  end

  def checkout
    @order = Order.new
    @user_orders = current_user.orders
    @all_schools = School.all.active.alphabetical
    unless @user_orders.blank?
      @most_recent_school = @user_orders.chronological.first.school
      @schools_dropdown = @most_recent_school + (@schools_dropdown - @most_recent_school)
    else
      @schools_dropdown = School.all.active.alphabetical.map { |s| "#{s.name} : #{s.street_1}" }
    end
    @title = "CHECKOUT"
    @path_name = "/checkout"
  end

  private
  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:school_id, :user_id, :date, :credit_card_number, :expiration_year, :expiration_month)
  end

  def set_heading
    @title = "ORDERS"
    @path_name = "/orders"
  end

  def set_total_cart_vars
    @shipping_cost = calculate_cart_shipping
    @grand_total = calculate_cart_shipping + calculate_cart_items_cost
  end
end
