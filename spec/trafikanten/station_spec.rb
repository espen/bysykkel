#:encoding:utf-8

require File.dirname(__FILE__) + '/../../lib/trafikanten/station'

describe Trafikanten::Station do
  
  context 'search' do
    it 'can search for funky characters' do
      stations = Trafikanten::Station.find_all_by_name('Ullevåll')
      stations.size.should == 10

      # Test first
      station = stations[0]
      station.name.should == "Ullev&#229;l hageby # (Oslo)"
      station.id.should == '1000013064'
      station.type.should == '2'
    end
    
    it 'can search for multiple stations by name' do
      stations = Trafikanten::Station.find_all_by_name('Hels')
      stations.size.should == 20

      # Test first
      station = stations[0]
      station.name.should == "Helseheimen (Ullensaker)"
      station.id.should == '02350113'
      station.type.should == '1'

      # Test middle
      station = stations[9]
      station.name.should == "Helsfyr # (Oslo)"
      station.id.should == '1000021179'
      station.type.should == '2'
    end
    
    it 'returns an empty array when searching for multiple stations and did not find any' do
      stations = Trafikanten::Station.find_all_by_name('XXX')
      stations.should == []
    end
    
    it 'can search for a specific station by name' do
      station = Trafikanten::Station.find_by_name('Helsfyr [T-bane]')
      station.class.should == Trafikanten::Station
      station.name.should == 'Helsfyr [T-bane] (Oslo)'
      station.id.should == "03011440"
      station.type.should == "1"

      station = Trafikanten::Station.find_by_name('Helsfyr [T-bane] (Oslo)')
      station.class.should == Trafikanten::Station
      station.name.should == 'Helsfyr [T-bane] (Oslo)'
      station.id.should == "03011440"
      station.type.should == "1"
    end
    
    it 'returns nil when searching for a specific station and did not find any' do
      station = Trafikanten::Station.find_by_name('8742374892374923')
      station.should be_nil
    end
    
  end  
  
  context 'type' do
    it 'is guessed based on ID length when not known' do
      s = Trafikanten::Station.new

      s.id = '1000020910'
      s.type.should == "2"

      s.id = '05440105'
      s.type.should == "1"

      s.id = '030117972'
      s.type.should == "4"    
    end

    it 'is not guessed when known' do
      s = Trafikanten::Station.new
      s.id = '1000020910'
      s.type = "29"
      s.type.should == "29"
    end    
  end

end
