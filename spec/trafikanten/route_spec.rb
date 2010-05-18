require File.dirname(__FILE__) + '/../../lib/trafikanten/route'

describe Trafikanten::Route do
  it 'it generates proper url queries from the stations passed in' do
    now = Time.now
    route = Trafikanten::Route.new('1000013064', '02350113')
    route.send(:query_string).should == "fra=1000013064%3A&DepType=2&date=#{now.strftime("%d.%m.%Y")}&til=02350113%3A&arrType=1&Transport=2,%207,%205,%208,%201,%206,%204&MaxRadius=700&type=1&tid=#{now.strftime("%H.%M")}"
  end
  
#   it 'parses Trafikanten HTML into data structures' do
#     doc = File.read('/Users/botti/Desktop/route.txt')
#     Trafikanten::Utils.stub(:fetch).and_return(doc)
#     
#     route = Trafikanten::Route.new(123, 123)
#     
#     parsed = route.trip
#     parsed.class.should == Hash
#     
#     # Test main trip data
#     parsed[:duration].should == 136
#     parsed[:arrive].should == "Gressholmen"
#     parsed[:depart].should == "Holmestrand [tog]"
# 
#     parsed[:steps].class.should == Array
#     
#     # Test first step
#     step = parsed[:steps].first
#     step[:duration].should == 64
#     step[:depart].should == "Holmestrand [tog]"
#     step[:arrive].should == "Oslo Sentralstasjon [tog]"
#     
#     # Test last step
#     step = parsed[:steps].last
#     step[:duration].should == 15
#     step[:depart].should =~ /Vippetangen \[b.t\]/ # Damn nordic characters and Ruby!
#     step[:arrive].should == "Gressholmen"
#     
#   end
#   
#   it 'knows about missing routes and return empty Hash' do
#     missing = <<eos
#     <!--++++++++++++-->
#     <!--  ASP code  -->
#     <!--++++++++++++-->
# 
#     <?xml version="1.0" encoding="iso-8859-1"?>
#     <html>
#     <head>
#     <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=no" />
#     <link rel="stylesheet" href="m.css" type="text/css" />
#     <title>Trafikanten - Feilmelding</title>
#     <body>
#        <p>Ingen forbindelse funnet eller ingen stoppesteder funnet</p>
#     </body>
#     </html>
# eos
# 
#     Trafikanten::Utils.stub(:fetch).and_return(missing)
#     route = Trafikanten::Route.new(123, 123)
#     route.trip.should == {}
#   end
#   
#   it 'it parses errors and raises them locally' do
#     error = <<eos
#     
#     <!--++++++++++++-->
#     <!--  ASP code  -->
#     <!--++++++++++++-->
# 
#     <?xml version="1.0" encoding="iso-8859-1"?>
#     <html>
#     <head>
#     <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=no" />
#     <link rel="stylesheet" href="m.css" type="text/css" />
#     <title>Trafikanten - Feilmelding</title>
#     <body>
#        <p>Some generic error</p>
#     </body>
#     </html>
# eos
#     Trafikanten::Utils.stub(:fetch).and_return(error)
#     lambda { Trafikanten::Route.new(123, 123) }.should raise_error(Trafikanten::Error, "Some generic error")
#     
#         error = <<eos
# 
#         <!--++++++++++++-->
#         <!--  ASP code  -->
#         <!--++++++++++++-->
# 
#         <?xml version="1.0" encoding="iso-8859-1"?>
#         <html>
#         <head>
#         <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=no" />
#         <link rel="stylesheet" href="m.css" type="text/css" />
#         <title>Trafikanten - Feilmelding</title>
#         <body>
#            <p>Some totally different error</p>
#         </body>
#         </html>
# eos
#         Trafikanten::Utils.stub(:fetch).and_return(error)
#         lambda { Trafikanten::Route.new(123, 123) }.should raise_error(Trafikanten::Error, "Some totally different error")
#   end
#   
#   it 'handles unpredicted errors as bad requests' do
#     weird_error = <<eos
#     
#     <!--++++++++++++-->
#     <!--  ASP code  -->
#     <!--++++++++++++-->
# 
#      <font face="Arial" size=2>
#     <p>Microsoft VBScript runtime </font> <font face="Arial" size=2>error '800a0005'</font>
#     <p>
#     <font face="Arial" size=2>Invalid procedure call or argument: 'left'</font>
#     <p>
#     <font face="Arial" size=2>/BetRes.asp</font><font face="Arial" size=2>, line 71</font>
# eos
#     Trafikanten::Utils.stub(:fetch).and_return(weird_error)
#     lambda { Trafikanten::Route.new(123, 123) }.should raise_error(Trafikanten::BadRequest)
#   end
#     
end
