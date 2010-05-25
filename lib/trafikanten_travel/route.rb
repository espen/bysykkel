# encoding: utf-8

module TrafikantenTravel
  class Error < StandardError;end
  class BadRequest < Error;end
  
  class Route
    include TrafikantenTravel::Utils
    attr_accessor :duration, :steps
    BASE_URL = 'http://m.trafikanten.no/BetRes.asp?'
    
    # Searches and returns a Route object for the found trip
    def self.find(from, to, time = TrafikantenTravel::Utils.time_class.now)
      route = Route.new(from, to, time)
      route.parse
      route
    end
    
    def initialize(from, to, time = TrafikantenTravel::Utils.time_class.now)
      @from = from
      @to = to
      @time = time
      @steps = []
    end

    # Parse the received HTML. First try some error-checking.
    def parse
      doc = TrafikantenTravel::Utils.fetch(BASE_URL + query_string)
      
      if doc =~ /Ingen forbindelse funnet eller ingen stoppesteder funnet/
        return {}
      end
      
      if doc =~ /Trafikanten - Feilmelding/
        doc =~ /<p>(.+)<\/p>/
        raise Error.new($1)
      end
      
      if doc =~ /Microsoft VBScript runtime/
        raise BadRequest
      end
      
      do_parse(doc)
    end
    
    private
    
    # Do the actual parsing
    def do_parse(raw)
      doc = Nokogiri::HTML.parse(raw)
      
      self.steps = doc.css('p')[1..-1].inject([]) do |ary, step|
        # Clean the text
        step = step.text.strip.gsub(/\s/, ' ')
        
        # Fix for broken formatting
        # All steps but this one are in their own paragraph-tag
        # Need to split them and parse each
        if step =~ /^(Vent .+ minutter|minutt)(.+)/
          ary << Step.from_html(@time, $1)
          ary << Step.from_html(@time, $2)
        else
          ary << Step.from_html(@time, step)
        end
      end
      
      # Duration is the sum of all steps
      self.duration = self.steps.inject(0) do |i, step|
        i += step.duration if step.duration
      end
    end
    
    # The crucial part of the URL we need to fetch to find the route
    def query_string
      "fra=#{@from.id}%3A&DepType=#{@from.type}&date=#{@time.strftime("%d.%m.%Y")}&til=#{@to.id}%3A&arrType=#{@to.type}&Transport=2,%207,%205,%208,%201,%206,%204&MaxRadius=700&type=1&tid=#{@time.strftime("%H.%M")}"
    end
    
    class Step
      attr_accessor :type, :line, :duration, :arrive, :depart
      
      # Regexes for matching steps in the HTML
      WALK    = /Gå\s+fra (.+) til (.+) ca. (\d) minutt/u
      WAIT    = /Vent\s+(\d+) minutt/
      TRANSPORT = /(\S+) (.+).+Avg: (.+) (\d{2}.\d{2}).+Ank:(.+) (\d{2}.\d{2})/u

      TYPE_MAP = {
        'Tog' => :train,
        'T-bane' => :subway,
        'Sporvogn' => :tram,
        'Båt' => :boat,
        'Buss' => :bus
      }
      
      def self.from_html(time, html)
        step = new
        case html
        when WAIT
          step.type     = :wait
          step.duration = $1.to_i
        when WALK
          step.type     = :walk
          step.duration = $3.to_i
          step.depart   = {
            :station => $1
          }
          step.arrive   = {
            :station => $2
          }
        when TRANSPORT
          step.type     = TYPE_MAP[$1]
          step.line     = $2.strip
          step.duration = duration_between(time, $4, $6)
          step.depart   = {
            :station => $3,
            :time => timestr_to_time(time, $4, $4)
          }
          step.arrive   = {
            :station => $5,
            :time => timestr_to_time(time, $4, $6)
          }
        end
        step
      end
      
      # Accepts two HH.MM and will calculate and return the difference in minutes based on the @time date
      # FIXME: This is baaad
      def self.duration_between(date, from, to)
        from  = from.gsub('.', ':')
        to    = to.gsub('.', ':')

        from_time = TrafikantenTravel::Utils.time_class.parse(date.strftime('%Y-%m-%d') + ' ' + from)
        to_time   = TrafikantenTravel::Utils.time_class.parse(date.strftime('%Y-%m-%d') + ' ' + to)

        if(to.to_f < from.to_f)
          to_time = to_time + (60 * 60 * 24)
        end

        ((to_time - from_time) / 60).to_i
      end

      # FIXME: Also baaad
      def self.timestr_to_time(date, from_timestr, to_timestr)
        time = TrafikantenTravel::Utils.time_class.parse(date.strftime('%Y-%m-%d') + ' ' + to_timestr.gsub('.', ':'))

        if(to_timestr.to_f < from_timestr.to_f)
          time = time + (60 * 60 * 24)
        end
        time
      end
      
      
    end

  end
end
