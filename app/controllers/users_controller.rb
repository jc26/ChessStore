class UsersController < ApplicationController
  layout 'login', :only => [:new]

  before_action :check_login, except: [:new, :create]
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :set_heading, except: [:dashboard]

  def index
    @users = User.all.alphabetical
    @customers = @users.customers.paginate(:page => params[:page]).per_page(10)
    @employees = @users.employees.paginate(:page => params[:page]).per_page(10)
  end

  def show
    @user = current_user
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
