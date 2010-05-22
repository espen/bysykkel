#:encoding:utf-8

require File.dirname(__FILE__) + '/../../lib/trafikanten_travel/station'

describe TrafikantenTravel::Station do  
  context 'search' do    
    it 'searches by name and returns Stations array' do
      stations = TrafikantenTravel::Station.find_by_name('Ullevåll')
      stations.size.should == 6

      # Test first
      station = stations[0]
      station.name.should == "Ullevål stadion (i Sognsveien)"
      station.id.should == '03012211'
      station.type.should == '1'
      
    end
    
    it 'returns an empty array when searching for stations and did not find any' do
      stations = TrafikantenTravel::Station.find_by_name('XXX')
      stations.should == []
    end
    
  end
  
  context 'geodata' do
    it 'has latitude and longitude' do
      stations = TrafikantenTravel::Station.find_by_name('Sthanshaugen')
      
      # Test first
      station = stations.first
      station.name.should == "St. Hanshaugen (v/ Markus krk)"
      station.lat.should == '59.9239720442894'
      station.lng.should == '10.7397078950283'
    end
  end
  
  context 'type' do
    it 'is guessed based on ID length when not known' do
      s = TrafikantenTravel::Station.new

      s.id = '1000020910'
      s.type.should == "2"

      s.id = '05440105'
      s.type.should == "1"

      s.id = '030117972'
      s.type.should == "4"    
    end

    it 'is not guessed when known' do
      s = TrafikantenTravel::Station.new
      s.id = '1000020910'
      s.type = "29"
      s.type.should == "29"
    end    
  end

end
