module Bysykkel

  class Error < StandardError;end
  class BadRequest < Error;end

  class Rack
    RACKS_URL = 'http://smartbikeportal.clearchannel.no/public/mobapp/maq.asmx/getRacks'
    RACK_URL = 'http://smartbikeportal.clearchannel.no/public/mobapp/maq.asmx/getRack?id=%s'
    
    attr_accessor :id, :name, :empty_locks, :ready_bikes, :online, :lat, :lng
    
    def initialize(attrs = {})
      attrs.each do |k,v|
        self.__send__("#{k}=", v)
      end
    end
    
    # Query the Bysykkel XML API @ clearchannel.no for racks.
    def self.all()
      raw = open(RACKS_URL)
      doc = Nokogiri::XML.parse raw
      racks_xml = Nokogiri::XML('<stations>' + doc.children[0].children[0].text + '</stations>')
      racks = racks_xml.xpath('//station').children.inject([]) do |ary, rack|
            ary << Rack.new({
              :id => rack.text.to_i
            }) unless rack.text.to_i >= 500
            ary
      end
      
      
      hydra = Typhoeus::Hydra.new( :max_concurrency => 6, :initial_pool_size => 5 )
      racks_all = []
      racks.each do |rack|
        req = Typhoeus::Request.new( RACK_URL % rack.id )
        req.on_complete do |response|
          doc = Nokogiri::XML.parse response.body
          parsed_rack = self.parse_rack(rack.id, Nokogiri::XML(doc.children[0].children[0].text).children[0])
          racks_all << parsed_rack unless parsed_rack.nil?
        end
        hydra.queue req
      end
      hydra.run
      racks_all
    end
    
    # Query the Bysykkel XML API @ clearchannel.no for a rack.
    def self.find(id)
      raw = open(RACK_URL % id )
      doc = Nokogiri::XML.parse raw
      parsed_rack = self.parse_rack(id, Nokogiri::XML(doc.children[0].children[0].text).children[0])
      return parsed_rack ? [parsed_rack] : []
    end
    
    private
    def self.parse_rack(id, rack)
      return if !rack
      return if rack.xpath('online').text == ''
      Rack.new( {
          :id => id.to_i, 
          :name => rack.xpath('description').text.strip.gsub(/[0-9]+-/, ""),
          :empty_locks => rack.xpath('empty_locks').text.to_i,
          :ready_bikes => rack.xpath('ready_bikes').text.to_i,
          :online => rack.xpath('online').text == '1' ? true : false,
          :lat => rack.xpath('latitude').text.to_f,
          :lng => rack.xpath('longitute').text.to_f
        } )
    end
    
  end
end
