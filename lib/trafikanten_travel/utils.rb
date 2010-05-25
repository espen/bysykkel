require 'iconv'

module TrafikantenTravel
  module Utils
    def self.fetch(url)
      Iconv.new('UTF-8', 'LATIN1').iconv(open(url).read)
    end
        
    def self.time_class
      Time.respond_to?(:zone) ? Time.zone : Time
    end
  end
end
