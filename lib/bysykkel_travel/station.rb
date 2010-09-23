module BysykkelTravel
  class Station
    STATIONS_URL = 'http://smartbikeportal.clearchannel.no/public/mobapp/maq.asmx/getRacks'
    STATION_URL = 'http://smartbikeportal.clearchannel.no/public/mobapp/maq.asmx/getRack?id=%s'
    
    attr_accessor :id, :name, :empty_locks, :ready_bikes, :online, :lat, :lng
    
    def initialize(attrs = {})
      attrs.each do |k,v|
        self.__send__("#{k}=", v)
      end
    end
    
    # Query the Bysykkel XML API @ clearchannel.no for stations.
    def self.all()
      raw = open(STATIONS_URL)
      doc = Nokogiri::XML.parse raw
      stations = Nokogiri::XML('<stations>' + doc.children[0].children[0].text + '</stations>')
      hits = stations.xpath('//station').children.inject([]) do |ary, station|
            ary << Station.new({
              :id => station.text.to_i
            }) unless station.text.to_i >= 500
            ary
      end
    end
    
    # Query the Bysykkel XML API @ clearchannel.no for a station.
    def self.find(id)
      raw = open(STATION_URL % id )
      doc = Nokogiri::XML.parse raw
      station = Nokogiri::XML(doc.children[0].children[0].text).children[0]
      return {} if station.xpath('online').text == ''
      return Station.new( {
          :id => id.to_i, 
          :name => station.xpath('description').text.strip,
          :empty_locks => station.xpath('empty_locks').text.to_i,
          :ready_bikes => station.xpath('ready_bikes').text.to_i,
          :online => station.xpath('online').text == '1' ? true : false,
          :lat => station.xpath('latitude').text.to_f,
          :lng => station.xpath('longitute').text.to_f
        } )
    end
    
  end
end
