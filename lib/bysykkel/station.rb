module Bysykkel
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
      stations_xml = Nokogiri::XML('<stations>' + doc.children[0].children[0].text + '</stations>')
      stations = stations_xml.xpath('//station').children.inject([]) do |ary, station|
            ary << Station.new({
              :id => station.text.to_i
            }) unless station.text.to_i >= 500
            ary
      end
      
      
      hydra = Typhoeus::Hydra.new( :max_concurrency => 6, :initial_pool_size => 5 )
      stations_all = Array.new
      stations.each do |station|
        req = Typhoeus::Request.new( STATION_URL % station.id )
        req.on_complete do |response|
          doc = Nokogiri::XML.parse response.body
          xml_station = Nokogiri::XML(doc.children[0].children[0].text).children[0]
          parsed_station = self.parse_station(station.id, xml_station)
          stations_all << parsed_station unless parsed_station == {}
        end
        hydra.queue req
      end
      hydra.run
      stations_all
    end
    
    # Query the Bysykkel XML API @ clearchannel.no for a station.
    def self.find(id)
      raw = open(STATION_URL % id )
      doc = Nokogiri::XML.parse raw
      xml_station = Nokogiri::XML(doc.children[0].children[0].text).children[0]
      parsed_station = self.parse_station(id, xml_station)
      parsed_station unless parsed_station == {}
    end
    
    private
    def self.parse_station(id, station)
      return {} if station.xpath('online').text == ''
      Station.new( {
          :id => id.to_i, 
          :name => station.xpath('description').text.strip.gsub(/[0-9]+-/, ""),
          :empty_locks => station.xpath('empty_locks').text.to_i,
          :ready_bikes => station.xpath('ready_bikes').text.to_i,
          :online => station.xpath('online').text == '1' ? true : false,
          :lat => station.xpath('latitude').text.to_f,
          :lng => station.xpath('longitute').text.to_f
        } )
    end
    
  end
end
