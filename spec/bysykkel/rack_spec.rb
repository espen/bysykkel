#:encoding:utf-8

require File.dirname(__FILE__) + '/../../lib/bysykkel'

describe Bysykkel::Rack do  
  context 'view' do    
    it 'view by id and returns rack' do
      racks = Bysykkel::Rack.find(1)
      racks.size.should == 1

      # Test first
      rack = racks[0]
      rack.name.should == "Middelthunsgate (vis-a-vis nr. 21, retning Kirkeveien)"
      rack.id.should == 1
      
    end
    
    it 'returns an empty array when searching for racks and did not find any' do
      rack = Bysykkel::Rack.find(289282)
      rack.should == []
    end
    
  end
  
  context 'all' do    
    it 'view all and returns rack' do
      racks = Bysykkel::Rack.all
      racks.size.should == 102

      # Test first
      rack = racks[0]
      rack.id.should == 1
      
    end
    
  end
  
  context 'geodata' do
    it 'has latitude and longitude' do
      racks = Bysykkel::Rack.find(1)
      
      # Test first
      rack = racks.first
      rack.name.should == "Middelthunsgate (vis-a-vis nr. 21, retning Kirkeveien)"
      rack.lat.should == 59.92786125852981
      rack.lng.should == 10.709009170532226
    end
  end
  
end
