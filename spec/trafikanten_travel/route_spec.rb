# encoding: utf-8
require File.dirname(__FILE__) + '/../../lib/trafikanten_travel'

describe TrafikantenTravel::Route do

  before(:all) do
    @from = TrafikantenTravel::Station.new({:id => '1000013064'})
    @to = TrafikantenTravel::Station.new({:id => '02350113'})
  end
  
  context 'searching' do
    
    it 'takes two stations and a Time and returns the Route found' do
      doc = File.read(File.dirname(__FILE__) + '/../fixtures/route.html')
      TrafikantenTravel::Utils.stub(:fetch).and_return(doc)
      from = TrafikantenTravel::Station.new({:id => '07025050'})
      to = TrafikantenTravel::Station.new({:id => '03010175'})
      route = TrafikantenTravel::Route.find(from, to, Time.parse('2010-05-19 12:24 +0200'))
      
      route.duration.should == 60 + 56
      
      route.steps.class.should == Array

      # Test first step
      step = route.steps.first
      step.class.should == TrafikantenTravel::Route::Step
      step.duration.should == 64
      
      step.depart.should == {
        :station => "Holmestrand [tog]",
        :time => Time.parse('2010-05-19 12:24 +0200')
      }
      
      step.arrive.should == {
        :station => "Oslo Sentralstasjon [tog]",
        :time => Time.parse('2010-05-19 13:28 +0200')
      }
      
      # Test last step
      step = route.steps.last
      step.duration.should == 15
      step.depart.should == {
        :station => 'Vippetangen [båt]',
        :time => Time.parse('2010-05-19 14:05 +0200')
      }
      step.arrive.should == {
        :station => 'Gressholmen',
        :time => Time.parse('2010-05-19 14:20 +0200')
      }
    end
    
    it 'knows about the Airport Express train' do
      str = "Flytog FT Drammen    Avg: Gardermoen flyplass [tog] 11.36  Ank:Oslo Sentralstasjon [tog] 11.58"
      result = TrafikantenTravel::Route::Step.from_html(Time.now, str)
      result.type.should == :airport_express_train
    end
    
    context 'url generation' do
      # Test the whole thing
      it 'generates exactly this' do
        route = TrafikantenTravel::Route.new(@from, @to)
        query = route.send(:query_string)
        query.should == "fra=1000013064%3A&DepType=2&date=#{Time.now.strftime("%d.%m.%Y")}&til=02350113%3A&arrType=1&Transport=2,%207,%205,%208,%201,%206,%204&MaxRadius=700&type=1&tid=#{Time.now.strftime("%H.%M")}"
      end

      # Test the parts in isolation
      it 'takles stations and their types' do
        route = TrafikantenTravel::Route.new(@from, @to)
        query = route.send(:query_string)
        query.should =~ /fra=1000013064%3A&DepType=2/
        query.should =~ /til=02350113%3A&arrType=1/
      end

      it 'defaults to Time.now' do
        route = TrafikantenTravel::Route.new(@from, @to)
        query = route.send(:query_string)
        query.should =~ /date=#{Time.now.strftime("%d.%m.%Y")}/
        query.should =~ /tid=#{Time.now.strftime("%H.%M")}/
      end

      it 'uses the time passed in' do
        route = TrafikantenTravel::Route.new(@from, @to, Time.parse('2010-04-29 13:29'))
        query = route.send(:query_string)
        query.should =~ /&date=29.04.2010/
        query.should =~ /&tid=13.29/
      end      
    end
  end
  
  context 'steps' do
    it 'can tell the duration in minutes, from messed up time information' do
      TrafikantenTravel::Route::Step.send(:duration_between, Time.now, '12.00', '13.45').should == 60 + 45
      TrafikantenTravel::Route::Step.send(:duration_between, Time.now, '23.30', '00.05').should == 30 + 5
      TrafikantenTravel::Route::Step.send(:duration_between, Time.now, '00.00', '00.00').should == 0
    end    
  end

  context 'error handling' do
      it 'knows about missing routes and return empty array for steps' do
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
           <p>%s</p>
        </body>
        </html>
eos

        [
          'Ingen turer ankommer ankomststed', 
          'Ingen forbindelse funnet eller ingen stoppesteder funnet',
          'Ingen turer utgår fra avgangsted'
          ].each do |notfound|
            TrafikantenTravel::Utils.stub(:fetch).and_return(missing % notfound)
            route = TrafikantenTravel::Route.find(@from, @to)
            route.steps.should == []
          end
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
        lambda { TrafikantenTravel::Route.find(@from, @to) }.should raise_error(TrafikantenTravel::Error, "Some generic error")

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
            lambda { TrafikantenTravel::Route.find(@from, @to) }.should raise_error(TrafikantenTravel::Error, "Some totally different error")
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
        lambda { TrafikantenTravel::Route.find(@from, @to) }.should raise_error(TrafikantenTravel::BadRequest)
      end
  end
end
