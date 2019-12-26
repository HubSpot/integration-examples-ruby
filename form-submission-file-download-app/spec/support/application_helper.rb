module ApplicationHelper
  def fake_hubspot_webhook(fixture, vid)
    FakeHubspotWebhook.new(
      fixture: "#{fixture}.json",
      host: Capybara.current_session.server.host,
      path: "/webhooks/callback",
      port: Capybara.current_session.server.port,
      vid: vid
    )
  end

  def clear_hubspot_data(contact_id: nil, form_id: nil)
    ::Hubspot::Contact.new('vid' => contact_id, properties: { sample: 'sample' }).destroy! if contact_id.present?
    ::Hubspot::Form.find(form_id).destroy! if form_id.present?
  end
end