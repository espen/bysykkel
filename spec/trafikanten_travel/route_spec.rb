# encoding: utf-8
require File.dirname(__FILE__) + '/../../lib/trafikanten_travel'

describe TrafikantenTravel::Route do
  
  it 'converts station ids to strings' do
    route = TrafikantenTravel::Route.new(1, 2)
    route.instance_variable_get('@from').id.should == '1'
    route.instance_variable_get('@to').id.should == '2'
  end
  
  context 'url generation' do
    # Test the whole thing
    it 'generates exactly this' do
      route = TrafikantenTravel::Route.new('1000013064', '02350113')
      query = route.send(:query_string)
      query.should == "fra=1000013064%3A&DepType=2&date=#{Time.now.strftime("%d.%m.%Y")}&til=02350113%3A&arrType=1&Transport=2,%207,%205,%208,%201,%206,%204&MaxRadius=700&type=1&tid=#{Time.now.strftime("%H.%M")}"
    end
    
    # Test the parts in isolation
    it 'takles stations and their types' do
      route = TrafikantenTravel::Route.new('1000013064', '02350113')
      query = route.send(:query_string)
      query.should =~ /fra=1000013064%3A&DepType=2/
      query.should =~ /til=02350113%3A&arrType=1/
    end
    
    it 'defaults to Time.now' do
      route = TrafikantenTravel::Route.new('1000013064', '02350113')
      query = route.send(:query_string)
      query.should =~ /date=#{Time.now.strftime("%d.%m.%Y")}/
      query.should =~ /tid=#{Time.now.strftime("%H.%M")}/
    end
    
    it 'uses the time passed in' do
      route = TrafikantenTravel::Route.new('1000013064', '02350113', Time.parse('2010-04-29 13:29'))
      query = route.send(:query_string)
      query.should =~ /&date=29.04.2010/
      query.should =~ /&tid=13.29/
    end
  end
  
  context 'time awareness' do
    it 'can tell the duration in minutes, from messed up time information' do
      route = TrafikantenTravel::Route.new(1, 2)
      route.send(:duration, '12.00', '13.45').should == 60 + 45
      route.send(:duration, '23.30', '00.05').should == 30 + 5
      route.send(:duration, '00.00', '00.00').should == 0
    end
  end
  
  context 'parsing routes' do
    it 'parses Trafikanten HTML into nice data structures' do
      doc = File.read(File.dirname(__FILE__) + '/../fixtures/route.html')
      TrafikantenTravel::Utils.stub(:fetch).and_return(doc)
      route = TrafikantenTravel::Route.new('07025050', '03010175', Time.parse('2010-05-19 12:24 +0200'))
      route.parse

      parsed = route.trip
      parsed.class.should == Hash

      parsed[:steps].class.should == Array

      # Test first step
      step = parsed[:steps].first
      step[:duration].should == 64
      step[:depart].should == {
        :station => "Holmestrand [tog]",
        :time => Time.parse('2010-05-19 12:24 +0200')
      }
      
      step[:arrive].should == {
        :station => "Oslo Sentralstasjon [tog]",
        :time => Time.parse('2010-05-19 13:28 +0200')
      }

      # Test last step
      step = parsed[:steps].last
      step[:duration].should == 15
      step[:depart].should == {
        :station => 'Vippetangen [båt]',
        :time => Time.parse('2010-05-19 14:05 +0200')
      }
      step[:arrive].should == {
        :station => 'Gressholmen',
        :time => Time.parse('2010-05-19 14:20 +0200')
      }
    end
  end

  context 'error handling' do
      it 'knows about missing routes and return empty Hash' do
        missing = <<eos
        <!--++++++++++++-->
        <!--  ASP code  -->
        <!--++++++++++++-->

        <?xml version="1.0" encoding="iso-8859-1"?>
        <html>
        <head>
        <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=no" />
        <link rel="stylesheet" href="m.css" type="text/css" />
        <title>Trafikanten - Feilmelding</title>
        <body>
           <p>Ingen forbindelse funnet eller ingen stoppesteder funnet</p>
        </body>
        </html>
eos

        TrafikantenTravel::Utils.stub(:fetch).and_return(missing)
        route = TrafikantenTravel::Route.new(123, 123)
        route.parse
        route.trip.should == {}
      end

      it 'it parses errors and raises them locally' do
        error = <<eos

        <!--++++++++++++-->
        <!--  ASP code  -->
        <!--++++++++++++-->

        <?xml version="1.0" encoding="iso-8859-1"?>
        <html>
        <head>
        <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=no" />
        <link rel="stylesheet" href="m.css" type="text/css" />
        <title>Trafikanten - Feilmelding</title>
        <body>
           <p>Some generic error</p>
        </body>
        </html>
eos
        TrafikantenTravel::Utils.stub(:fetch).and_return(error)
        lambda { TrafikantenTravel::Route.new(123, 123).parse }.should raise_error(TrafikantenTravel::Error, "Some generic error")

            error = <<eos

            <!--++++++++++++-->
            <!--  ASP code  -->
            <!--++++++++++++-->

            <?xml version="1.0" encoding="iso-8859-1"?>
            <html>
            <head>
            <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=no" />
            <link rel="stylesheet" href="m.css" type="text/css" />
            <title>Trafikanten - Feilmelding</title>
            <body>
               <p>Some totally different error</p>
            </body>
            </html>
eos
            TrafikantenTravel::Utils.stub(:fetch).and_return(error)
            lambda { TrafikantenTravel::Route.new(123, 123).parse }.should raise_error(TrafikantenTravel::Error, "Some totally different error")
      end

      it 'handles unpredicted errors as bad requests' do
        weird_error = <<eos

        <!--++++++++++++-->
        <!--  ASP code  -->
        <!--++++++++++++-->

         <font face="Arial" size=2>
        <p>Microsoft VBScript runtime </font> <font face="Arial" size=2>error '800a0005'</font>
        <p>
        <font face="Arial" size=2>Invalid procedure call or argument: 'left'</font>
        <p>
        <font face="Arial" size=2>/BetRes.asp</font><font face="Arial" size=2>, line 71</font>
eos
        TrafikantenTravel::Utils.stub(:fetch).and_return(weird_error)
        lambda { TrafikantenTravel::Route.new(123, 123).parse }.should raise_error(TrafikantenTravel::BadRequest)
      end
  end
end
