class ContactsController < ApplicationController
  def index
    properties = ['email', ENV['PROTECTED_FILE_LINK_PROPERTY'], ENV['PUBLIC_FILE_LINK_PROPERTY']]
    @contacts = if params[:search].present?
      @search_q = params[:search]
      ::Hubspot::Contact.search(params[:search], property: properties)['contacts']
    else
      # https://developers.hubspot.com/docs/methods/contacts/get_contacts
      ::Hubspot::Contact.all(recent: true, property: properties)
    end
  end
end
