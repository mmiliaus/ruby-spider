require 'open-uri'

WIKIPEDIA_DOMAIN = 'http://en.wikipedia.org'

resource = ARGV[0]
if resource.nil?
  puts %Q(Please provide resource name, i.e.: "Spacex", "V_for_vendetta")
  exit
end

# get "abstract" part of the Wikipedia page
def get_abstract source_html
  m = source_html.match /\<\/table>\s+(<p>.+)<table.+?id="toc"/im
  m[1]
end

url = "#{WIKIPEDIA_DOMAIN}/wiki/#{resource}"
source = open(url).read

puts get_abstract(source)
