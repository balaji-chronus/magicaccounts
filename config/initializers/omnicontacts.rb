Rails.application.middleware.use OmniContacts::Builder do
  importer :gmail, '777776367257-2dkiat5cadolph7nta14csig4son3kbs.apps.googleusercontent.com', 'x9qipcGKlGDlcZ0k0vD3k8sz',:max_results => 1000
end