require 'open-uri'

WIKIPEDIA_DOMAIN = 'http://en.wikipedia.org'

resource = ARGV[0]

url = "#{WIKIPEDIA_DOMAIN}/wiki/#{resource}"

response = open(url).read
puts response
