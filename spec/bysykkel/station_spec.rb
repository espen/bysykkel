#:encoding:utf-8

require File.dirname(__FILE__) + '/../../lib/bysykkel/station'

describe BysykkelTravel::Stations do  
  context 'view' do    
    it 'view by id and returns station' do
      stations = Bysykkel::Station.find(1)
      stations.size.should == 1

      # Test first
      station = stations[0]
      station.name.should == "01-Middelthunsgate (vis-a-vis nr. 21, retning Kirkeveien)"
      station.id.should == 1
      
    end
    
    it 'returns an empty array when searching for stations and did not find any' do
      station = Bysykkel::Station.find(289282)
      station.should == []
    end
    
  end
  
  context 'all' do    
    it 'view all and returns station' do
      stations = Bysykkel::Station.all
      stations.size.should == 100

      # Test first
      station = stations[0]
      station.id.should == 1
      
    end
    
    it 'returns an empty array when searching for stations and did not find any' do
      station = Bysykkel::Station.find(289282)
      station.should == []
    end
    
  end
  
  context 'geodata' do
    it 'has latitude and longitude' do
      stations = Bysykkel::Station.find(1)
      
      # Test first
      station = stations.first
      station.name.should == "01-Middelthunsgate (vis-a-vis nr. 21, retning Kirkeveien)"
      station.lat.should == '59.92786125852981'
      station.lng.should == '10.709009170532226'
    end
  end
  
end
