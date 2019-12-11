# HubSpot-ruby sample app

This is a sample app for the [hubspot-ruby SDK](https://github.com/adimichele/hubspot-ruby).

Please see the documentation on [How do I create an app in HubSpot?](https://developers.hubspot.com/docs/faq/how-do-i-create-an-app-in-hubspot)

This Application demonstrates the recommended approach to working with file uploads via HubSpot form submission. For security reasons HubSpot makes uploaded files available to the Users only if they are logged in. If you want not logged in
This design is implemented in this Application

1. There is an initialization page [new.html.erb](https://github.com/HubSpot/integration-examples-ruby/tree/master/form-submission-file-download-app/app/views/form/new.html.erb) invoked by the user on the initial Application page. It is designed to create a form for file upload and custom properties specified by environment variables PUBLIC_FILE_LINK_PROPERTY and PROTECTED_FILE_LINK_PROPERTY for uploaded protected file link and public file link storage
2. After the initialization is done the form is created using JavaScript script provided by HubSpot to embed forms on your website. (src="//js.hsforms.net/forms/shell.js) - this is done in [show.html.erb](https://github.com/HubSpot/integration-examples-ruby/tree/master/form-submission-file-download-app/app/views/form/show.html.erb)
3. When User uploads the file via the form webhook event is posted to [webhooks_controller.rb](https://github.com/HubSpot/integration-examples-ruby/tree/master/form-submission-file-download-app/app/controllers/webhooks_controller.rb) that does two things:
   - calls method to get the file from Protected Property https://github.com/HubSpot/hubspot-integration-samples-ruby/blob/master/form-submission-file-download-app/app/lib/services/hubspot/get_uploaded_file_by_url.rb#L11
   - calls method to update Public Property with publicly viewable location of the file https://github.com/HubSpot/hubspot-integration-samples-ruby/blob/master/form-submission-file-download-app/app/lib/services/hubspot/handle_webhook.rb#L34
4. [index.html.erb](https://github.com/HubSpot/integration-examples-ruby/tree/master/form-submission-file-download-app/app/views/contacts/index.html.erb)) displays the list of contacts with PROTECTED_FILE_LINK_PROPERTY and PUBLIC_FILE_LINK_PROPERTY

### Setup App

Make sure you have [Docker Compose](https://docs.docker.com/compose/) installed.

### Configure

1. Copy .env.template to .env
2. Specify authorization data in .env:
   - Paste HUBSPOT_CLIENT_ID and HUBSPOT_CLIENT_SECRET for OAuth
   - Paste PUBLIC_FILE_LINK_PROPERTY and PROTECTED_FILE_LINK_PROPERTY

### Running

The best way to run this project (with the least configuration), is using docker compose. Change to the webroot and start it

```bash
docker-compose up --build
```

Copy Ngrok url from console. Now you should now be able to navigate to that url and use the application.

### NOTE about Ngrok Too Many Connections error

If you are using Ngrok free plan and testing the application with large amount of import/deletions of Contacts you are likely to see Ngrok "Too Many Connections" error.
This is caused by a large amount of weebhooks events being sent to Ngrok tunnel. To avoid it you can deploy sample applications on your server w/o Ngrok or upgrade to Ngrok Enterprise version

### Configure webhooks

Required webhooks url should look like https://***.ngrok.io/webhooks/callback

Following [Webhooks Setup](https://developers.hubspot.com/docs/methods/webhooks/webhooks-overview) guide please note:

- Every time the app is restarted you should update the webhooks url
- The app requires `contact.propertyChange` subscription type
- Subscription is paused by default. You need to activate it manually after creating
