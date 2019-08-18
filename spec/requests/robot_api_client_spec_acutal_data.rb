require 'spec_helper'
require 'dotenv'
Dotenv.load
require_relative "../../robot_api_client.rb"

RSpec.describe RobotApiClient do
  let(:robot_api_client) {described_class.new}

  hash = [{"code":"ruby","displayName":"Ruby"},{"code":"python","displayName":"Python"},{"code":"java","displayName":"Java"}]
  id = ENV['ID']
  pass = ENV['PASS']

  describe "言語一覧取得(GET)" do
    context "正常系" do
      it "エラーなく言語一覧を取得する(JSON)" do
        json_str = JSON.pretty_generate(hash)

        expect(robot_api_client.get_language("json", id, pass)).to eq(json_str)
      end

      it "エラーなく言語一覧を取得する(CSV)" do
        csv_str = CSV.generate do |csv|
          csv << hash[0].keys
          hash.each { |hash| csv << hash.values}
        end

        expect(robot_api_client.get_language("csv", id, pass)).to eq(csv_str)
      end
    end

    context "異常系" do
      it "IDとパスワードが不適切なら言語一覧を取得できない" do
        expect{ robot_api_client.get_language("json", "other_than_id", pass) }.to raise_error(Unauthorized)
        expect{ robot_api_client.get_language("json", id, "other_than_pass") }.to raise_error(Unauthorized)
        expect{ robot_api_client.get_language("json", "other_than_id", "other_than_pass") }.to raise_error(Unauthorized)

        expect{ robot_api_client.get_language("csv", "other_than_id", pass) }.to raise_error(Unauthorized)
        expect{ robot_api_client.get_language("csv", id, "other_than_pass") }.to raise_error(Unauthorized)
        expect{ robot_api_client.get_language("csv", "other_than_id", "other_than_pass") }.to raise_error(Unauthorized)
      end

      it "JSONとCSV以外のデータ形式を指定すると言語一覧を取得できない" do
        expect{ robot_api_client.get_language("xml", id, pass) }.to raise_error(DataFormatError)
      end
    end
  end
end