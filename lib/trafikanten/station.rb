require 'open-uri'
require 'iconv'
require 'cgi'

module Trafikanten
  class Station
    BASE_URL = 'http://www5.trafikanten.no/txml/?type=1&stopname=%s'
    
    attr_accessor :name, :id, :type, :coordinates
    
    def initialize(attrs = {})
      attrs.each do |k,v|
        self.__send__("#{k}=", v)
      end
    end
    
    def self.find_by_name(name)
      raw = open(BASE_URL % CGI.escape(name))
      doc = Nokogiri::XML.parse raw
      hits = doc.css('StopMatch').inject([]) do |ary, stop|
        ary << Station.new({
          :id => stop.css('fromid').text, 
          :name => stop.css('StopName').text,
          :coordinates => [stop.css('XCoordinate').text, stop.css('YCoordinate').text]
        })
      end
    end
    
    # Internal type @ Trafikanten. Used with GET requests for routes in depType and arrType.
    # We guess these
    def type
      return @type if @type
      
      case @id.length
      when 8
        '1'
      when 10
        '2'
      when 9
        '4'
      else
        nil
      end
    end
    
  end
end
