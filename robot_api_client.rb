require 'faraday'
require 'json'
require 'csv'

class RobotApiClient
  def get_language(data_format, id, pass)
    begin
      response = connection(id, pass).get("/programLanguages")
    rescue Faraday::ClientError => e
      raise Unauthorized, e.message
    end

    hash = JSON.parse(response.body)

    case data_format
    when "json" then 
      json_str = JSON.pretty_generate(hash)
      puts json_str
      return json_str
    when "csv" then
      csv_str = CSV.generate do |csv|
        csv << hash[0].keys
        hash.each { |hash| csv << hash.values}
      end
      puts csv_str
      return csv_str
    else
      raise DataFormatError, "choose only json or csv"
    end
  end

  private
  def connection(id, pass)
    Faraday.new(url: "https://robot.diveintocode.jp:17777") do |connection|
      connection.use Faraday::Request::BasicAuthentication, id, pass
      connection.response :raise_error
      connection.adapter Faraday.default_adapter
    end
  end
end

class Unauthorized < StandardError; end
class DataFormatError < StandardError; end

if $0 == __FILE__
  raise ArgumentError, "Usage: ruby robot_api_client.rb <data format(json|csv)> <id> <pass>" unless ARGV.length == 3
  RobotApiClient.new.get_language(ARGV[0], ARGV[1], ARGV[2])
end