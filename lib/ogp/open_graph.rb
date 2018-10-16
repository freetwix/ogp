require 'oga'
require 'ostruct'

REQUIRED_ATTRIBUTES = %w(title type image url).freeze

module OGP
  class OpenGraph
    # Required Accessors
    attr_reader :title, :type, :url
    attr_reader :images

    # Optional Accessors
    attr_reader :description, :determiner, :site_name
    attr_reader :audios
    attr_reader :locales
    attr_reader :videos

    attr_reader :errors

    def initialize(source)
      if source.nil? || source.empty?
        raise ArgumentError, '`source` cannot be nil or empty.'
      end

      raise MalformedSourceError unless source.include?('</html>')

      @images = []
      @audios = []
      @locales = []
      @videos = []

      @document = Oga.parse_html(source)
      parse_attributes(@document)
    end

    def image
      return if @images.nil?
      @images.first
    end

    def valid?
      @errors = []
      REQUIRED_ATTRIBUTES.each do |attribute_name|
        unless attribute_exists(@document, attribute_name)
          @errors << { :"#{attribute_name}" => 'attribute is missing' }
        end
      end
      @errors.empty?
    end

  private

    def parse_attributes(document)
      document.xpath('//head/meta[starts-with(@property, \'og:\')]').each do |attribute|
        attribute_name = attribute.get('property').downcase.gsub('og:', '')
        case attribute_name
          when /^image$/i
            @images << OpenStruct.new(url: attribute.get('content').to_s)
          when /^image:(.+)/i
            @images.last[Regexp.last_match[1].gsub('-', '_')] = attribute.get('content').to_s
          when /^audio$/i
            @audios << OpenStruct.new(url: attribute.get('content').to_s)
          when /^audio:(.+)/i
            @audios.last[Regexp.last_match[1].gsub('-', '_')] = attribute.get('content').to_s
          when /^locale/i
            @locales << attribute.get('content').to_s
          when /^video$/i
            @videos << OpenStruct.new(url: attribute.get('content').to_s)
          when /^video:(.+)/i
            @videos.last[Regexp.last_match[1].gsub('-', '_')] = attribute.get('content').to_s
          else
            instance_variable_set("@#{attribute_name}", attribute.get('content'))
        end
      end
    end

    def attribute_exists(document, name)
      document.at_xpath("boolean(//head/meta[@property='og:#{name}'])")
    end
  end

  class MalformedSourceError < StandardError
  end
end
