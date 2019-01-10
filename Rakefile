# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
begin
  require 'single_test/tasks'
rescue LoadError => e
  raise e unless ENV['RAILS_ENV'] == "production"
end
Rails.application.load_tasks
