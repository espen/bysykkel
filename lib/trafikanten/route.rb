# encoding: utf-8

module Trafikanten
  class Error < StandardError;end
  class BadRequest < Error;end
  
  class Route
    attr_accessor :trip
    BASE_URL = 'http://m.trafikanten.no/BetRes.asp?'

    
    NEXT_TRIP = /title="Neste avgang".+date=(\d{2}).(\d{2}).(\d{4}).+tid=(\d{2}).(\d{2})/
    PREV_TRIP = //
    
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
    
    def initialize(from_id, to_id, time = time_class.now)
      @from = Station.new({:id => from_id.to_s})      
      @to = Station.new({:id => to_id.to_s})

      @time = time
      @trip = {}
    end

    def parse
      # This is pretty brittle error-checking...
      begin
        doc = Trafikanten::Utils.fetch(BASE_URL + query_string)

        if doc =~ /Microsoft VBScript runtime/
          raise BadRequest
        end

        @trip = do_parse(doc)
      rescue => e
        if doc =~ /Ingen forbindelse funnet eller ingen stoppesteder funnet/
          return {}
        end

        if doc =~ /Trafikanten - Feilmelding/
          doc =~ /<p>(.+)<\/p>/
          raise Error.new($1)
        end

        # Oops.
        raise e
      end
    end
    
    private
    
    def do_parse(raw)
      trip = {}
      doc = Nokogiri::HTML.parse(raw)
      
      trip[:steps] = doc.css('p')[1..-1].inject([]) do |ary, step|
        # Clean the text
        step = step.text.strip.gsub(/\s/, ' ')
        
        # Fix for broken formatting
        # All steps but this one is in its own paragraph-tag
        # Need to split them and parse both
        if step =~ /^(Vent .+ minutter|minutt)(.+)/
          ary << parse_step($1)
          ary << parse_step($2)
        else
          ary << parse_step(step)
        end
      end
      
      # Duration is the sum of all steps
      trip[:duration] = trip[:steps].inject(0) do |i, step|
        i += step[:duration] if step[:duration]
      end
      
      # Next trip
      # trip[:next] = parse_next(raw)
      # Previous trip
      # trip[:prev] = parse_prev(raw)
      trip
    end
    
    def parse_next(doc)
      Time.parse("#{$3}-#{$2}-#{$1} #{$4}:#{$5}") if doc =~ NEXT_TRIP
    end
    
    def parse_prev(doc)
    end
    
    def parse_step(step)
      parsed = {}
      case step
      when WAIT
        parsed[:type]     = :wait
        parsed[:duration] = $1.to_i
      when WALK
        parsed[:type]     = :walk
        parsed[:duration] = $3.to_i
        parsed[:depart]   = {
          :station => $1
        }
        parsed[:arrive]   = {
          :station => $2
        }
      when TRANSPORT
        parsed[:type]     = TYPE_MAP[$1]
        parsed[:line]     = $2.strip
        parsed[:duration] = duration($4, $6)
        parsed[:depart]   = {
          :station => $3,
          :time => timestr_to_time($4, $4)
        }
        parsed[:arrive]   = {
          :station => $5,
          :time => timestr_to_time($4, $6)
        }
      end
      parsed
    end
    
    private
    def query_string
      "fra=#{@from.id}%3A&DepType=#{@from.type}&date=#{@time.strftime("%d.%m.%Y")}&til=#{@to.id}%3A&arrType=#{@to.type}&Transport=2,%207,%205,%208,%201,%206,%204&MaxRadius=700&type=1&tid=#{@time.strftime("%H.%M")}"
    end
    
    # Accepts two HH.MM and will calculate and return the difference in minutes based on the @time date
    def duration(from, to)
      from  = from.gsub('.', ':')
      to    = to.gsub('.', ':')
      
      from_time = time_class.parse(@time.strftime('%Y-%m-%d') + ' ' + from)
      to_time   = time_class.parse(@time.strftime('%Y-%m-%d') + ' ' + to)
      
      if(to.to_f < from.to_f)
        to_time = to_time + (60 * 60 * 24)
      end
      
      ((to_time - from_time) / 60).to_i
    end
    
    def timestr_to_time(from_timestr, to_timestr)
      time = time_class.parse(@time.strftime('%Y-%m-%d') + ' ' + to_timestr.gsub('.', ':'))
      
      if(to_timestr.to_f < from_timestr.to_f)
        time = time + (60 * 60 * 24)
      end
      time
    end
    
    def time_class
      Time.respond_to?(:zone) ? Time.zone : Time
    end
  end
end
