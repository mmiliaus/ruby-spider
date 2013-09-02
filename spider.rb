# This script scrapes requested information from a Wikipedia page
#
# Data that can be scraped:
# * Article heading;
# * Abstract;
# * Links.
#
# Example script usage:
# ruby spider.rb -r Niels_Bohr


require 'open-uri'

WIKIPEDIA_DOMAIN = 'http://en.wikipedia.org'

module Wikipedia

  # A mixin of methods used for filtering URLs, based on regex patterns
  module Filters
    def take_links filters, links
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
    
    def filter_without_hash_tags links
      links.select{|url| not url.match(/\A#/)}
    end

    def filter_relative links
      links.select{|url| not url.match(/\/\//)}
    end
  end

  # Represents Wikipedia page
  class Page

    attr_accessor :heading, :abstract, :links
    extend Filters

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
      m = source_html.match(/\<table.+?infobox.+?>.+<\/table>\s+(.+)<div.+?id="toc".*?>/im)
      m[1]
    end

    def get_links source_html
      source_html.scan(/<a.+?href="(.+?)"/im).flatten
    end


  end
end

# parse CLI parameters
args = ARGV.clone
params = {}
while !args.empty?
  flag = args.shift.gsub(/\A-/,'').to_sym
  flag_val = args.shift
  params[flag] = flag_val
end

# resource parameter is mandatory
if !params.include?(:r)
  puts %Q(Please provide resource name, i.e.: "Spacex", "V_for_vendetta")
  exit
end

# fetch data from a Wikipedia page
wp = Wikipedia::Page.new params[:r]
wp.download.get_data
f_links = Wikipedia::Page.take_links(
                [:without_hash_tag, :relative],
                wp.links
          ) { |url| not url.match(/(wiki|w)\/.+:.+/) }

# output filtered links
puts f_links
