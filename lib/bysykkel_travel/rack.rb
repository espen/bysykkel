module BysykkelTravel
  class Rack
    BASE_URL = 'http://smartbikeportal.clearchannel.no/public/mobapp/maq.asmx/getRack?id=%s'
    
    attr_accessor :description, :id, :type, :lat, :lng, :empty_locks, :ready_bikes, :online
    
    def initialize(attrs = {})
      attrs.each do |k,v|
        self.__send__("#{k}=", v)
      end
    end
    
    # Query the Travel XML API @ clearchannel.no for Racks.
    def self.find_by_id(id)
      raw = open(BASE_URL % CGI.escape(id))
      doc = Nokogiri::XML.parse raw
      hits = doc.xpath('string').inject([]) do |ary, stop|

        ary << Rack.new({
          :id => id, 
          :description => stop.xpath('description').text,
          :lat => stop.xpath('latitude').text,
          :lng => stop.xpath('longitute').text
        })
      end
    end
    
  end
end
