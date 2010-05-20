require 'open-uri'
require 'iconv'
require 'cgi'

module Trafikanten
  class Station
    URL = "http://m.trafikanten.no/BetLink.asp?fra=%s&DStoppAddress=1"

    STATION_REGEX = /<a.+fra=(\d+).*deptype=(\d)".+>(.+)<\/a><br\/>/
    ONE_STATION = /<a.+fra=(\d+).*deptype=(\d)"\/>Neste<\/a>/
    
    attr_accessor :name, :id, :type
    
    def initialize(attrs = {})
      attrs.each do |k,v|
        self.__send__("#{k}=", v)
      end
    end
    
    def self.find_all_by_name(name)
      doc = search(name)

      doc.scan(STATION_REGEX).map do |station|
        s = Station.new
        s.id    = station[0]
        s.type  = station[1]
        s.name  = CGI.unescape(station[2])
        s
      end
    end
    
    def self.find_by_name(name)
      doc = search(name)
      station = doc.scan(ONE_STATION).first
      
      if station
        s = Station.new
        name = doc.scan(STATION_REGEX).first[2]
        s.name = CGI.unescape(name)
        s.id = station[0]
        s.type
        return s
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
    
    private
    def self.search(name)
      Trafikanten::Utils.fetch(URL % CGI.escape(name))
    end
    
  end
end
