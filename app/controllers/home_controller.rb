class HomeController < ApplicationController
  layout 'login', :only => [:home]

  def home
    if logged_in?
      redirect_to dashboard_path
    end
  end

  def about
    @title = "ABOUT"
    @path_name = "/about"
  end

  def contact
    @title = "CONTACT"
    @path_name = "/contact"
  end

  def privacy
    @title = "PRIVACY"
    @path_name = "/privacy"
  end

end
