class SchoolsController < ApplicationController
  before_action :check_login
  before_action :set_school, only: [:show, :update, :destroy]
  before_action :set_heading

  def index
    @active_schools = School.active.alphabetical.paginate(:page => params[:page]).per_page(10)
    @inactive_schools = School.inactive.alphabetical.paginate(:page => params[:page]).per_page(10)
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

  private
  def set_school
    @school = School.find(params[:id])
  end

  def school_params
    params.require(:school).permit(:name, :street_1, :street_2, :state, :zip, :min_grade, :max_grade, :active)
  end

  def set_heading
    @title = "SCHOOLS"
    @path_name = "/schools"
  end
end
