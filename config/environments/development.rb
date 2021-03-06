ProjectLectito::Application.configure do

  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  config.eager_load = false

  #To Avoid Circular dependency error
  config.middleware.delete Rack::Lock

  # Config to handle multiple SSE Requests
  config.preload_frameworks = true
  config.allow_concurrency = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  #SSE 
  config.preload_frameworks = true
  config.allow_concurrency = true

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = true

  # Expands the lines which load the assets
  config.assets.debug = false

  # Firebase Config
  ENV['firebase_url'] = 'https://devprojectlectito.firebaseio.com/'

  # MSG91 URL
  ENV['msg91_url'] = 'https://control.msg91.com/api/sendhttp.php?authkey=64435AVXoM3F6kL4532011ef'

  #Default Url
  config.action_mailer.default_url_options = { :host => 'localhost:3006' }

  config.action_mailer.delivery_method = :smtp


  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.raise_delivery_errors = true
  ActionMailer::Base.smtp_settings = {
    :enable_starttls_auto => true,  
    :address            => 'smtp.gmail.com',
    :port               => 587,
    :domain             => 'gmail.com', #you can also use google.com
    :authentication     => :plain,
    :user_name          => 'sidunderscoresss@gmail.com',
    :password           => 'Mangalia0!'
  }

end
