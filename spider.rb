require 'open-uri'

WIKIPEDIA_DOMAIN = 'http://en.wikipedia.org'

resource = ARGV[0]

if resource.nil?
  puts %Q(Please provide resource name, i.e.: "Spacex", "V_for_vendetta")
  exit
end

url = "#{WIKIPEDIA_DOMAIN}/wiki/#{resource}"
source = open(url).read
puts source
