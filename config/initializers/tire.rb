if(ENV['ES_SERVER_URL'])
  Tire::Configuration.url "#{ENV['ES_SERVER_URL']}"
end