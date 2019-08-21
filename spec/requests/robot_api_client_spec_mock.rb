require 'spec_helper'
require 'dotenv'
Dotenv.load
require_relative "../../robot_api_client.rb"

RSpec.describe RobotApiClient do
  let(:robot_api_client) {described_class.new}
  
  let(:id) { ENV['ID'] }
  let(:pass) { ENV['PASS'] }

  let(:connection_mock) do
    Faraday.new do |connection|
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

  let(:hash) do
    response = connection_mock.get("/programLanguages")
    JSON.parse(response.body)
  end

  let(:json_str) { JSON.pretty_generate(hash) }

  let(:csv_str) do
    CSV.generate do |csv|
      csv << hash[0].keys
      hash.each { |hash| csv << hash.values}
    end
  end

  before :each do
    response = connection_mock.get("/programLanguages")
    expect(response).to be_success
    expect(response.status).to eq(200)
    
    allow(robot_api_client).to receive(:get_language).with("json", id, pass).and_return(json_str)
    allow(robot_api_client).to receive(:get_language).with("csv", id, pass).and_return(csv_str)
  end

  describe "言語一覧取得(GET)" do
    context "正常系" do
      HASH = [{"code":"ruby","displayName":"Ruby"},{"code":"python","displayName":"Python"},{"code":"java","displayName":"Java"}]
      HASH.freeze

      let(:json_str_result) { JSON.pretty_generate(HASH) }
  
      let(:csv_str_result) do
        CSV.generate do |csv|
          csv << HASH[0].keys
          HASH.each { |hash| csv << hash.values }
        end
      end

      it "エラーなく言語一覧を取得する(JSON)" do
        expect(robot_api_client.get_language("json", id, pass)).to match(json_str_result)
        
      end

      it "エラーなく言語一覧を取得する(CSV)" do
        expect(robot_api_client.get_language("csv", id, pass)).to match(csv_str_result)
      end
    end

    context "異常系" do
      it "IDとパスワードが不適切なら言語一覧を取得できない" do
        #json
        allow(robot_api_client).to receive(:get_language).with("json", "other_than_id", pass).and_raise(SystemExit)
        allow(robot_api_client).to receive(:get_language).with("json", id, "other_than_pass").and_raise(SystemExit)
        allow(robot_api_client).to receive(:get_language).with("json", "other_than_id", "other_than_pass").and_raise(SystemExit)

        expect{ robot_api_client.get_language("json", "other_than_id", pass) }.to raise_error(SystemExit)
        expect{ robot_api_client.get_language("json", id, "other_than_pass") }.to raise_error(SystemExit)
        expect{ robot_api_client.get_language("json", "other_than_id", "other_than_pass") }.to raise_error(SystemExit)

        #csv
        allow(robot_api_client).to receive(:get_language).with("csv", "other_than_id", pass).and_raise(SystemExit)
        allow(robot_api_client).to receive(:get_language).with("csv", id, "other_than_pass").and_raise(SystemExit)
        allow(robot_api_client).to receive(:get_language).with("csv", "other_than_id", "other_than_pass").and_raise(SystemExit)

        expect{ robot_api_client.get_language("csv", "other_than_id", pass) }.to raise_error(SystemExit)
        expect{ robot_api_client.get_language("csv", id, "other_than_pass") }.to raise_error(SystemExit)
        expect{ robot_api_client.get_language("csv", "other_than_id", "other_than_pass") }.to raise_error(SystemExit)
      end

      it "JSONとCSV以外のデータ形式を指定すると言語一覧を取得できない" do
        allow(robot_api_client).to receive(:get_language).with("unwanted_data_format", id, pass).and_raise(SystemExit)

        expect{ robot_api_client.get_language("unwanted_data_format", id, pass) }.to raise_error(SystemExit)
      end

      it "引数の数が不適切なら言語一覧を取得できない" do
        expect{ robot_api_client.get_language(id, pass) }.to raise_error(ArgumentError)
      end
    end
    
  end
end