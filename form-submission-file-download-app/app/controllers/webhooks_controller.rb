class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:handle]
  skip_before_action :authorize_hubspot
  skip_before_action :require_form, only: [:handle]

  def handle
    head(:unauthorized) && return unless hubspot_signature_valid?

    authorize_hubspot
    webhooks = JSON.parse(request.raw_post)
    webhooks.each { |webhook| Services::Hubspot::HandleWebhook.new(webhook: webhook).call }
    render json: {}
  end

  private

  def hubspot_signature_valid?
    source_string = ENV['HUBSPOT_CLIENT_SECRET'] + request.raw_post
    signature = request.headers['HTTP_X_HUBSPOT_SIGNATURE']
    signature == Digest::SHA256.hexdigest(source_string)
  end
end
