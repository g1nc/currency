require 'currency/version'
require 'net/http'
require 'byebug'
require 'ox'

module Currency
  DATA_URL = 'http://www.cbr.ru/scripts/xml_daily.asp?date_req=%{date}'

  class Exchange
    def initialize(code)
      @code = code
    end

    def to_rub(amount)
      amount * value / nominal
    end

    def to_cur(amount)
      amount / value * nominal
    end

    private

    def value
      @currency ||= currency
      @currency.locate('Value').first.text.sub(',', '.').to_f
    end

    def nominal
      @currency ||= currency
      @currency.locate('Nominal').first.text.to_i
    end

    def currency
      doc = Ox.parse(data)
      doc.ValCurs.nodes.find do |node|
        node.locate('CharCode').first.text == @code
      end
    end

    def data
      url = URI.parse(DATA_URL % { date: Time.now.strftime('%d.%m.%Y') })
      req = Net::HTTP::Get.new(url.to_s)
      res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
      res.body
    end
  end
end
