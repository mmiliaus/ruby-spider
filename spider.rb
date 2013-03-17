require 'open-uri'

url = 'http://en.wikipedia.org/wiki/V_for_vendetta'
source = open(url).read
puts source
