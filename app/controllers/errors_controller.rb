class ErrorsController < ApplicationController
  # Code written in reference to https://mattbrictson.com/dynamic-rails-error-pages#1-generate-an-errors-controller-and-views
  before_action :set_heading

  def not_found
    render(:status => 404)
  end

  def internal_server_error
    render(:status => 500)
  end

  private
  def set_heading
    @title = "Go Back to Dashboard"
    @path_name = "/dashboard"
  end
end
