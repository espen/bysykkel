#:encoding:utf-8

require File.dirname(__FILE__) + '/../../lib/bysykkel_travel'
require File.dirname(__FILE__) + '/../../lib/bysykkel_travel/rack'

describe BysykkelTravel::Rack do  
  context 'view' do    
    it 'view by id and returns Rack' do
      racks = BysykkelTravel::Rack.find_by_id(1)
      racks.size.should == 1

      # Test first
      rack = racks[0]
      rack.name.should == "01-Middelthunsgate (vis-a-vis nr. 21, retning Kirkeveien)"
      rack.id.should == 1
      
    end
    
    it 'returns an empty array when searching for racks and did not find any' do
      racks = BysykkelTravel::Rack.find_by_name(289282)
      racks.should == []
    end
    
  end
  
  context 'geodata' do
    it 'has latitude and longitude' do
      racks = BysykkelTravel::Rack.find_by_id(1)
      
      # Test first
      rack = racks.first
      rack.name.should == "01-Middelthunsgate (vis-a-vis nr. 21, retning Kirkeveien)"
      rack.lat.should == '59.92786125852981'
      rack.lng.should == '10.709009170532226'
    end
  end
  
end
