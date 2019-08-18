require 'spec_helper'
require 'dotenv'
Dotenv.load
require_relative "../../robot_api_client.rb"

RSpec.describe RobotApiClient do
  let(:robot_api_client) {described_class.new}
  
  id = ENV['ID']
  pass = ENV['PASS']
  
  def connection_mock
    connection_mock = Faraday.new do |connection|
      connection.adapter :test, Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get("/programLanguages") do
          [
            200, 
            {},
            JSON.generate(
              [
                {"code":"ruby","displayName":"Ruby"},
                {"code":"python","displayName":"Python"},
                {"code":"java","displayName":"Java"}
              ]
            )
          ]
        end
      end
    end
  end

  def hash(connection_mock)
    response = connection_mock.get("/programLanguages")
    return JSON.parse(response.body)
  end

  def json_str
    hash = hash(connection_mock)
    return JSON.pretty_generate(hash)
  end

  def csv_str
    hash = hash(connection_mock)
    csv_str = CSV.generate do |csv|
      csv << hash[0].keys
      hash.each { |hash| csv << hash.values}
    end
    return csv_str
  end
  
  before :each do
    allow(robot_api_client).to receive(:get_language).with("json", id, pass).and_return(json_str)
    allow(robot_api_client).to receive(:get_language).with("csv", id, pass).and_return(csv_str)
  end

  describe "言語一覧取得(GET)" do
    context "正常系" do
      it "エラーなく言語一覧を取得する(JSON)" do
        expect(robot_api_client.get_language("json", id, pass)).to eq(json_str)
      end

      it "エラーなく言語一覧を取得する(CSV)" do
        expect(robot_api_client.get_language("csv", id, pass)).to eq(csv_str)
      end
    end

    context "異常系" do
      it "IDとパスワードが不適切なら言語一覧を取得できない" do
        allow(robot_api_client).to receive(:get_language).with("json", "other_than_id", pass).and_raise(Unauthorized)
        allow(robot_api_client).to receive(:get_language).with("json", id, "other_than_pass").and_raise(Unauthorized)
        allow(robot_api_client).to receive(:get_language).with("json", "other_than_id", "other_than_pass").and_raise(Unauthorized)

        allow(robot_api_client).to receive(:get_language).with("csv", "other_than_id", pass).and_raise(Unauthorized)
        allow(robot_api_client).to receive(:get_language).with("csv", id, "other_than_pass").and_raise(Unauthorized)
        allow(robot_api_client).to receive(:get_language).with("csv", "other_than_id", "other_than_pass").and_raise(Unauthorized)

        expect{ robot_api_client.get_language("json", "other_than_id", pass) }.to raise_error(Unauthorized)
        expect{ robot_api_client.get_language("json", id, "other_than_pass") }.to raise_error(Unauthorized)
        expect{ robot_api_client.get_language("json", "other_than_id", "other_than_pass") }.to raise_error(Unauthorized)

        expect{ robot_api_client.get_language("csv", "other_than_id", pass) }.to raise_error(Unauthorized)
        expect{ robot_api_client.get_language("csv", id, "other_than_pass") }.to raise_error(Unauthorized)
        expect{ robot_api_client.get_language("csv", "other_than_id", "other_than_pass") }.to raise_error(Unauthorized)
      end

      it "JSONとCSV以外のデータ形式を指定すると言語一覧を取得できない" do
        allow(robot_api_client).to receive(:get_language).with("unwanted_data_format", id, pass).and_raise(DataFormatError)

        expect{ robot_api_client.get_language("unwanted_data_format", id, pass) }.to raise_error(DataFormatError)
      end
    end
    
  end
end