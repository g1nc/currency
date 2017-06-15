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

  it 'convert ruble value to currency without nominal' do
    ex = Currency::Exchange.new('USD')
    Net::HTTP.expects(:start).returns(@res)
    expect(ex.to_cur(57.0241)).to eq(1)
  end

  it 'convert currency value to ruble without nominal' do
    ex = Currency::Exchange.new('USD')
    Net::HTTP.expects(:start).returns(@res)
    expect(ex.to_rub(1)).to eq(57.0241)
  end

  it 'convert ruble value to currency with nominal' do
    ex = Currency::Exchange.new('AMD')
    Net::HTTP.expects(:start).returns(@res)
    expect(ex.to_cur(11.7940)).to eq(100)
  end

  it 'convert currency value to ruble with nominal' do
    ex = Currency::Exchange.new('AMD')
    Net::HTTP.expects(:start).returns(@res)
    expect(ex.to_rub(100)).to eq(11.7940)
  end
end
