Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '724418340902359', 'ef1464092b06767529fc8233acfb33ae'
  provider :google_oauth2, '777776367257-2dkiat5cadolph7nta14csig4son3kbs.apps.googleusercontent.com', 'x9qipcGKlGDlcZ0k0vD3k8sz'

end

OmniAuth.config.on_failure = UsersController.action(:oauth_failure)

module OmniAuth
  module Strategy

    def call_with_error_handling(env)
      begin
        call_without_error_handling(env)
      rescue OmniAuth::Strategies::Facebook::NoAuthorizationCodeError => error
        Rails.logger.error error
        OmniAuth::FailureEndpoint.new(env).redirect_to_failure
      end
    end

    alias_method_chain :call, :error_handling

  end
end
