class HomeController < ApplicationController
  layout 'login', :only => [:home]

  def home
    if logged_in?
      redirect_to dashboard_path
    end
  end

  def about
  end

  def contact
  end

  def privacy
  end

end
