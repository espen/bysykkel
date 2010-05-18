module Trafikanten
  class Route
    def initialize(from_id, to_id, time = Time.now)
      @from = Station.new
      @from.id = from_id
      
      @to = Station.new
      @to.id = to_id
      
      @time = time
    end
    
    private
    def query_string
      "fra=#{@from.id}%3A&DepType=#{@from.type}&date=#{@time.strftime("%d.%m.%Y")}&til=#{@to.id}%3A&arrType=#{@to.type}&Transport=2,%207,%205,%208,%201,%206,%204&MaxRadius=700&type=1&tid=#{@time.strftime("%H.%M")}"
    end
  end
end
