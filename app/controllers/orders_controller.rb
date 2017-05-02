class OrdersController < ApplicationController
  include ChessStoreHelpers::Cart
  include ChessStoreHelpers::Shipping

  before_action :check_login
  before_action :set_order, only: [:show, :update, :destroy]

  def index
  end

  def show
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def cart
    @items_in_cart = get_list_of_items_in_cart
    @shipping_cost = calculate_cart_shipping
    @total_cost = calculate_cart_items_cost
    @grand_total = calculate_cart_shipping + calculate_cart_items_cost
  end

  def checkout

  end

  private
  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:school_id, :user_id, :date, :credit_card_number, :expiration_year, :expiration_month)
  end
end
