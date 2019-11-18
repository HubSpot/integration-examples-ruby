class ContactsController < ApplicationController
  before_action :authorize

  def index
    @contacts = Hubspot::Contact.all(count: 10)
  end

  private

  def authorize
    raise(ExceptionHandler::HubspotError.new, 'Please authorize via OAuth2') if session['tokens'].blank?

    session['tokens'] = Services::Authorization::Tokens::Refresh.new(tokens: session['tokens']).call
    Services::Authorization::AuthorizeHubspot.new(tokens: session['tokens']).call
  end
end
