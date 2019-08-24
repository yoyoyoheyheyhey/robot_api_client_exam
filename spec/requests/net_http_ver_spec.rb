require 'spec_helper'
require_relative '../../net_http_ver.rb'
require 'dotenv'
Dotenv.load
require 'open3'

RSpec.describe 'robot_api_client' do
  let(:id) { ENV['ID'] }
  let(:pass) { ENV['PASS'] }

  describe '言語一覧を取得すること' do  
    HASH = [{"code":"ruby","displayName":"Ruby"},{"code":"python","displayName":"Python"},{"code":"java","displayName":"Java"}]
    HASH.freeze
    let(:json_str) { JSON.pretty_generate(HASH) }
    let(:csv_str) do
      CSV.generate do |csv|
        csv << HASH[0].keys
        HASH.each { |hash| csv << hash.values }
      end
    end
    
    context '第一引数がjsonの場合' do
      it 'jsonで言語一覧を取得すること' do
        stdout, status = Open3.capture2 %(ruby net_http_ver.rb json #{id} #{pass})
        expect(stdout).to match(json_str)
      end
    end

    context '第一引数がcsvの場合' do
      it 'csv言語一覧を取得すること' do
        stdout, status = Open3.capture2 %(ruby net_http_ver.rb csv #{id} #{pass})
        expect(stdout).to match(csv_str)
      end
    end
  end
end
