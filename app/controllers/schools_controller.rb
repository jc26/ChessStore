class SchoolsController < ApplicationController
  before_action :check_login
  before_action :set_school, only: [:show, :update, :destroy]
  before_action :set_heading

  def index
    if params[:search]
      @active_schools = School.active.search(params[:search]).alphabetical.paginate(:page => params[:page]).per_page(10)
      @inactive_schools = School.inactive.search(params[:search]).alphabetical.paginate(:page => params[:page]).per_page(10)
      if @active_schools.empty? && @inactive_schools.empty?
        redirect_to schools_path, notice: "Sorry, there are no schools with name similar to '#{params[:search]}.'"
      end
    else
      @active_schools = School.active.alphabetical.paginate(:page => params[:page]).per_page(10)
      @inactive_schools = School.inactive.alphabetical.paginate(:page => params[:page]).per_page(10)
    end
  end

  def show
  end

  def new
    @school = School.new
  end

  def create
    @school = School.new(school_params)
    if @school.save
      redirect_to school_path, notice: "#{@school.name} has been saved!"
    else
      flash[:error] = "The school could not be created."
      render "new"
    end
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
