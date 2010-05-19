require 'iconv'

module Trafikanten
  module Utils
    def self.fetch(url)
      Iconv.new('UTF-8', 'LATIN1').iconv(open(url).read)
    end
  end
end
