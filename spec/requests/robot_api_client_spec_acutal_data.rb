require 'spec_helper'
require 'dotenv'
Dotenv.load
require 'open3'
require_relative "../../robot_api_client.rb"

RSpec.describe RobotApiClient do
  let(:id) { ENV['ID'] }
  let(:pass) { ENV['PASS'] }

  HASH = [{"code":"ruby","displayName":"Ruby"},{"code":"python","displayName":"Python"},{"code":"java","displayName":"Java"}]
  HASH.freeze

  let(:json_str) { JSON.pretty_generate(HASH) }
  
  let(:csv_str) do
    CSV.generate do |csv|
      csv << HASH[0].keys
      HASH.each { |hash| csv << hash.values }
    end
  end
  
  describe "言語一覧取得(GET)" do
    context "正常系" do
      it "エラーなく言語一覧を取得する(JSON)" do
        stdout, status = Open3.capture2 %(ruby robot_api_client.rb json #{id} #{pass})
        expect(stdout).to match(json_str)
        expect(status.exitstatus).to eq(0)
      end

      it "エラーなく言語一覧を取得する(CSV)" do
        stdout, status = Open3.capture2 %(ruby robot_api_client.rb csv #{id} #{pass})
        expect(stdout).to match(csv_str)
        expect(status.exitstatus).to eq(0)
      end
    end

    context "異常系" do
      it "IDとパスワードが不適切なら言語一覧を取得できない" do
        err_msg = "You have entered an invalid id or password\n"

        # json
        stdout, status = Open3.capture2 %(ruby robot_api_client.rb json other_than_id #{pass})
        expect(stdout).to eq(err_msg)
        expect(status.exitstatus).to eq(1)

        stdout, status = Open3.capture2 %(ruby robot_api_client.rb json #{id} other_than_pass)
        expect(stdout).to eq(err_msg)
        expect(status.exitstatus).to eq(1)

        stdout, status = Open3.capture2 %(ruby robot_api_client.rb json other_than_id other_than_pass)
        expect(stdout).to eq(err_msg)
        expect(status.exitstatus).to eq(1)

        #csv
        stdout, status = Open3.capture2 %(ruby robot_api_client.rb csv other_than_id #{pass})
        expect(stdout).to eq(err_msg)
        expect(status.exitstatus).to eq(1)

        stdout, status = Open3.capture2 %(ruby robot_api_client.rb csv #{id} other_than_pass)
        expect(stdout).to eq(err_msg)
        expect(status.exitstatus).to eq(1)

        stdout, status = Open3.capture2 %(ruby robot_api_client.rb csv other_than_id other_than_pass)
        expect(stdout).to eq(err_msg)
        expect(status.exitstatus).to eq(1)
      end

      it "JSONとCSV以外のデータ形式を指定すると言語一覧を取得できない" do
        err_msg = "Please specify the data format from json or csv\n"

        stdout, status = Open3.capture2 %(ruby robot_api_client.rb xml #{id} #{pass})
        expect(stdout).to eq(err_msg)
        expect(status.exitstatus).to eq(1)
      end

      it "引数の数が不適切なら言語一覧を取得できない" do
        err_msg = "Usage: ruby robot_api_client.rb < json | csv > <id> <pass>\n"

        stdout, status = Open3.capture2 %(ruby robot_api_client.rb #{id} #{pass})
        expect(stdout).to eq(err_msg)
        expect(status.exitstatus).to eq(1)

        stdout, status = Open3.capture2 %(ruby robot_api_client.rb json #{id} #{pass} hoge)
        expect(stdout).to eq(err_msg)
        expect(status.exitstatus).to eq(1)
      end
    end
  end
end