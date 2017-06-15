require 'currency/version'
require 'net/http'
require 'ox'
require 'byebug'

module Currency
  DATA_URL = 'http://www.cbr.ru/scripts/xml_daily.asp?date_req=%{date}'

  class Exchange
    def initialize(code:, amount:)
      @code   = code
      @amount = amount
    end

    def convert_to(code, scale = nil)
      return @amount if @code == code

      @data = data
      if code.is_a? Array
        result = multiple_value(code, scale)
      else
        result = single_value(code, scale)
      end
      result
    end

    private

    def multiple_value(code, scale)
      result = {}
      code.each { |c| result[c] = single_value(c, scale) }
      result
    end

    def single_value(code, scale)
      result = @amount
      result *= value(@code) / nominal(@code) if @code != 'RUB'
      result /= value(code) * nominal(code)   if code  != 'RUB'
      return result.round(scale) unless scale.nil?
      result
    end

    def value(code)
      currency_value(code, 'Value').sub(',', '.').to_f
    end

    def nominal(code)
      currency_value(code, 'Nominal').to_i
    end

    def currency_value(code, field)
      doc = Ox.parse(@data)
      currency = doc.ValCurs.nodes.find do |node|
        node.locate('CharCode').first.text == code
      end
      currency.locate(field).first.text
    end

    def data
      url = URI.parse(DATA_URL % { date: Time.now.strftime('%d.%m.%Y') })
      req = Net::HTTP::Get.new(url.to_s)
      res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
      res.body
    end
  end
end
