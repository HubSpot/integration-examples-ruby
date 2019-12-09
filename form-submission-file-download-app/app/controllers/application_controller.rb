class ApplicationController < ActionController::Base
  include ExceptionHandler

  before_action :configure_hubspot
  before_action :check_env_variables
  before_action :authorize_hubspot
  before_action :require_form, if: :authorized?

  helper_method :authorized?

  private

  def require_form
    redirect_to new_form_path if session['form'].blank?
  end

  def authorized?
    session['tokens'].present?
  end

  def check_env_variables
    %w[PROTECTED_FILE_LINK_PROPERTY PUBLIC_FILE_LINK_PROPERTY].each do |variable|
      raise(ExceptionHandler::HubspotError.new, "Please specify #{variable} in .env") if ENV[variable].blank?
    end
  end

  def configure_hubspot
    Services::Authorization::ConfigureHubspot.new(request: request).call
  end

  def authorize_hubspot
    unless authorized?
      raise(ExceptionHandler::HubspotError.new, 'Please authorize via OAuth2') unless Token.any?

      session['tokens'] = Token.instance.attributes
    end

    session['tokens'] = Services::Authorization::Tokens::Refresh.new(tokens: session['tokens']).call
    Services::Authorization::AuthorizeHubspot.new(tokens: session['tokens']).call
  end
end
