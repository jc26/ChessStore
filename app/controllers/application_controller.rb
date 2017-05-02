class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  include ChessStoreHelpers::Cart

  before_action :set_cart_vars

  private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def logged_in?
    current_user
  end
  helper_method :logged_in?

  def check_login
    redirect_to login_url, alert: "You need to log in to view this page." if current_user.nil?
  end

  def set_cart_vars
    if logged_in?
      @items_in_cart = get_list_of_items_in_cart
      @total_cost = calculate_cart_items_cost
      @size_of_cart = get_size_of_cart
    end
  end
end
