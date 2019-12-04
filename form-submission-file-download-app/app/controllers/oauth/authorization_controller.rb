module Oauth
  class AuthorizationController < ApplicationController
    skip_before_action :authorize_hubspot

    def authorize
      url = ::Hubspot::OAuth.authorize_url(%w[contacts files forms forms-uploaded-files])
      redirect_to url
    end

    def callback
      tokens = Services::Authorization::Tokens::Generate.new(code: params[:code]).call
      Token.instance.update!(tokens)
      session['tokens'] = tokens
      Services::Authorization::AuthorizeHubspot.new(tokens: tokens).call
      redirect_to '/contacts'
    end
  end
end
