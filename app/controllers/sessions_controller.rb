class SessionsController < ApplicationController
  include ChessStoreHelpers::Cart

  def new
    @title = "LOGIN"
    @path_name = "/login"
  end

  def create
    user = User.find_by_username(params[:username])
    @title = "LOGIN"
    @path_name = "/login"
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      create_cart
      redirect_to dashboard_path, notice: "Welcome #{user.first_name}."
    else
      flash.now.alert = "Email or password is invalid"
      render "new"
    end
  end

  def destroy
    session[:user_id] = nil
    destroy_cart
    redirect_to home_path, notice: "Logged out!"
  end
end
