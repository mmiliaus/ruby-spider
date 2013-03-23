require 'open-uri'

WIKIPEDIA_DOMAIN = 'http://en.wikipedia.org'

class Page

  attr_accessor :heading, :abstract, :links

  def initialize resource
    @resource = resource
  end

  def download
    url = "#{WIKIPEDIA_DOMAIN}/wiki/#{@resource}"
    @source = open(url).read
    self
  end

  def get_data
    @heading = get_heading(@source)
    @abstract = get_abstract(@source)
    @links = get_links(@source)
  end

  def get_heading source_html
    m = source_html.match(/<h1.*>(.+?)<\/h1>/im)
    m[1].gsub(/<\/?.+>/, "")
  end

  def get_abstract source_html
    m = source_html.match /\<\/table>\s+(<p>.+)<table.+?id="toc"/im
    m[1]
  end

  def get_links source_html
    source_html.scan(/<a.+?href="(.+?)"/im).flatten
  end

end

resource = ARGV[0]
if resource.nil?
  puts %Q(Please provide resource name, i.e.: "Spacex", "V_for_vendetta")
  exit
end


wp = Page.new resource
wp.download.get_data
puts wp.heading
