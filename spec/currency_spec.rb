require 'spec_helper'

RSpec.describe Currency do
  it 'has a version number' do
    expect(Currency::VERSION).not_to be nil
  end

  before(:each) do
    content = File.open("#{Dir.pwd}/spec/response.xml").read
    @res    = mock
    @res.stubs(:body).returns(content)
  end

  it 'convert same currency' do
    ex = Currency::Exchange.new(code: 'USD', amount: 1)
    Net::HTTP.expects(:start).returns(@res).never
    expect(ex.convert_to('USD')).to eq(1)
  end

  it 'convert USD value to RUB' do
    ex = Currency::Exchange.new(code: 'USD', amount: 1)
    Net::HTTP.expects(:start).returns(@res)
    expect(ex.convert_to('RUB')).to eq(57.0241)
  end

  it 'convert RUB value to USD' do
    ex = Currency::Exchange.new(code: 'RUB', amount: 57.0241)
    Net::HTTP.expects(:start).returns(@res)
    expect(ex.convert_to('USD')).to eq(1)
  end

  it 'convert USD value to GBP' do
    ex = Currency::Exchange.new(code: 'USD', amount: 1)
    Net::HTTP.expects(:start).returns(@res)
    expect(ex.convert_to('GBP')).to eq(0.805347791455058)
  end

  it 'convert USD value to GBP and RUB with scale' do
    ex = Currency::Exchange.new(code: 'USD', amount: 1)
    Net::HTTP.expects(:start).returns(@res)
    expect(ex.convert_to(%w[GBP RUB], 2)).to eq({
      'GBP' => 0.81,
      'RUB' => 57.02
    })
  end
end
