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

def get_heading source_html
  m = source_html.match(/<h1.*>(.+?)<\/h1>/im)
  m[1].gsub(/<\/?.+>/, "")
end

def get_links source_html
  source_html.scan(/<a.+?href="(.+?)"/im).flatten
end

url = "#{WIKIPEDIA_DOMAIN}/wiki/#{resource}"
source = open(url).read

puts get_heading(source)
