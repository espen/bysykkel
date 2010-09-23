module BysykkelTravel
  class Rack
    BASE_URL = 'http://smartbikeportal.clearchannel.no/public/mobapp/maq.asmx/getRack?id=%s'
    
    attr_accessor :description, :id, :type, :lat, :lng, :empty_locks, :ready_bikes, :online
    
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
    def self.find_by_id(id)
      raw = open(BASE_URL % CGI.escape(id))
      doc = Nokogiri::XML.parse raw
      hits = doc.css('StopMatch').inject([]) do |ary, stop|
        
        x_coord = stop.css('XCoordinate').text
        y_coord = stop.css('YCoordinate').text
        
        if x_coord != '0' && y_coord != '0'
          lat_lng = GeoUtm::UTM.new('32V', x_coord.to_i, y_coord.to_i).to_lat_lon
        end

        ary << Rack.new({
          :id => id, 
          :lat => lat_lng ? lat_lng.lat.to_s : nil,
          :lng => lat_lng ? lat_lng.lon.to_s : nil
        })
      end
    end
    
  end
end
