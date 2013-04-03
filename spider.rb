require 'open-uri'

WIKIPEDIA_DOMAIN = 'http://en.wikipedia.org'

module Wikipedia
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

    def self.take_links filters, links
      filtered_links = links
      if filters.include? :without_hash_tag
        filtered_links = self.filter_without_hash_tags filtered_links
      end

      if filters.include? :relative
        filtered_links = self.filter_relative filtered_links
      end

      if block_given?
        acc = []
        filtered_links.each do |url|
          if yield(url)
            acc << url
          end
        end
        filtered_links = acc
      end

      filtered_links
    end
    
    def self.filter_without_hash_tags links
      links.select{|url| not url.match(/\A#/)}
    end

    def self.filter_relative links
      links.select{|url| not url.match(/\/\//)}
    end

  end
end

args = ARGV.clone
params = {}
while !args.empty?
  flag = args.shift.gsub(/\A-/,'').to_sym
  flag_val = args.shift
  params[flag] = flag_val
end

if !params.include?(:r)
  puts %Q(Please provide resource name, i.e.: "Spacex", "V_for_vendetta")
  exit
end

wp = Wikipedia::Page.new params[:r]
wp.download.get_data
f_links = Wikipedia::Page.take_links(
                [:without_hash_tag, :relative],
                wp.links
          ) { |url| not url.match(/(wiki|w)\/.+:.+/) }
puts f_links
