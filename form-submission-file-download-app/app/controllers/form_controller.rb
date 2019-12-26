class FormController < ApplicationController
  skip_before_action :require_form

  def show
    @portal_id = session[:form][:portal_id]
    @form_id = session[:form][:form_id]
  end

  def new
    @form_name = "HubSpot Ruby Sample Form Submission and File Download App #{SecureRandom.hex(7)}"
  end

  def create
    find_or_create_properties
    form = Services::Hubspot::CreateForm.new(form_name: params[:form_name], request: request).call
    session[:form] = {
      form_id: form.properties['guid'],
      portal_id: form.properties['portalId']
    }
    redirect_to action: :show
  end

  private

  def find_or_create_properties
    %w[PROTECTED_FILE_LINK_PROPERTY PUBLIC_FILE_LINK_PROPERTY].each do |variable|
      property_name = ENV[variable]
      property = Services::Hubspot::GetContactProperty.new(name: property_name).call
      hubspot_property =
        if property.present?
          property
        else
          params = {
            name: property_name,
            label: property_name,
            description: "HubSpot Ruby sample Form Submission and File Download \
                          app use this field for uploading picture",
            groupName: 'contactinformation',
            type: 'string',
            formField: true,
            fieldType: 'file'
          }.stringify_keys

          ::Hubspot::ContactProperties.create!(params)
        end

      if hubspot_property['fieldType'].blank?
        raise(ExceptionHandler::HubspotError.new, "Property #{property_name} already exists and it is not file")
      end
    end
  end
end
