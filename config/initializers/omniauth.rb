Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, 'QRsK3wCwyrmwVOpBAFuRg', 'bDYY9LCOYzMvc0MyoorX45HCbliv8km9EDhIyLfDDOM'
  provider :facebook, '724418340902359', 'ef1464092b06767529fc8233acfb33ae'
  provider :google_oauth2, '777776367257-2dkiat5cadolph7nta14csig4son3kbs.apps.googleusercontent.com', 'x9qipcGKlGDlcZ0k0vD3k8sz'
end

OmniAuth.config.on_failure = UsersController.action(:oauth_failure)