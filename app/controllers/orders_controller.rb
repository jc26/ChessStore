class OrdersController < ApplicationController
  include ChessStoreHelpers::Cart
  include ChessStoreHelpers::Shipping

  before_action :check_login
  before_action :set_order, only: [:show, :destroy]
  before_action :set_heading, except: [:cart, :checkout]
  before_action :set_total_cart_vars, only: [:cart, :checkout]
  authorize_resource

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

  def create
    @order = Order.new(order_params)
    @order.user = current_user
    @order.grand_total = calculate_cart_shipping + calculate_cart_items_cost
    if @order.save
      @order.pay
      @order.save
      save_each_item_in_cart(@order)
      clear_cart
      redirect_to @order, notice: "Thanks for ordering from the Chess Store! Your order will arrive very soon!"
    else
      redirect_to checkout_path, notice: "Credit card information was invalid. Please make sure your information is correct."
    end
  end

  def destroy
    if @order.destroy
      redirect_to orders_url, notice: "The order has been removed from the system."
    else
      redirect_to order_path(@order), notice: "All unshipped order-items of Order #{@order.id} have been removed from the system."
    end
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
    @schools_dropdown = @all_schools.map { |s| "#{s.name} : #{s.street_1}" }
    @title = "CHECKOUT"
    @path_name = "/checkout"
  end

  def change_quantity
    change_quantity_of_item(params[:item_id], params[:quantity])
    respond_to do |format|
      @items_in_cart = get_list_of_items_in_cart
      @total_cost = calculate_cart_items_cost
      @size_of_cart = get_size_of_cart
      @shipping_cost = calculate_cart_shipping
      @grand_total = calculate_cart_shipping + calculate_cart_items_cost
      format.js
    end
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
