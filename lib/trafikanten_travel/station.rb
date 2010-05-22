module TrafikantenTravel
  class Station
    BASE_URL = 'http://www5.trafikanten.no/txml/?type=1&stopname=%s'
    
    attr_accessor :name, :id, :type, :lat, :lng
    
    def initialize(attrs = {})
      attrs.each do |k,v|
        self.__send__("#{k}=", v)
      end
    end
    
    # Query the Travel XML API @ trafikanten.no for Stations. This will only
    # include actual stations, not regions (type 2) We'll have to parse
    # m.trafikanten.no to receive those, but that will not give us coordinates
    # for the actual stations. See git history for an implementation that did
    # this.
    def self.find_by_name(name)
      raw = open(BASE_URL % CGI.escape(name))
      doc = Nokogiri::XML.parse raw
      hits = doc.css('StopMatch').inject([]) do |ary, stop|
        
        x_coord = stop.css('XCoordinate').text
        y_coord = stop.css('YCoordinate').text
        
        if x_coord != '0' && y_coord != '0'
          lat_lng = GeoUtm::UTM.new('32V', x_coord.to_i, y_coord.to_i).to_lat_lon
        end

        ary << Station.new({
          :id => stop.css('fromid').text, 
          :name => stop.css('StopName').text,
          :lat => lat_lng ? lat_lng.lat.to_s : nil,
          :lng => lat_lng ? lat_lng.lon.to_s : nil
        })
      end
    end
    
    # Internal type @ Trafikanten. Used with GET requests for routes in
    # depType and arrType. We guess these unless set.
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
