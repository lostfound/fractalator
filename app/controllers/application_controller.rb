class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  rescue_from CanCan::AccessDenied do |e| 
    if user_signed_in?
      begin
        redirect_to :back
      rescue ActionController::RedirectBackError
        redirect_to main_app.root_path, alert: e.message
      end
    else
      redirect_to main_app.root_path, alert: e.message
    end
  end
end
