require 'faraday'
require 'json'
require 'csv'
require 'dotenv'
Dotenv.load

class RobotApiClient
  def get_language(data_format, id, pass)
    connection = connection(id, pass)
    hash = hash(connection)

    case data_format
    when "json" then 
      json_str = JSON.pretty_generate(hash)
      puts json_str
    when "csv" then
      csv_str = CSV.generate do |csv|
        csv << hash[0].keys
        hash.each { |hash| csv << hash.values}
      end
      puts csv_str
    else
      puts "Please specify the data format from json or csv"
      exit 1
    end
  end

  private
  def connection(id, pass)
    unless id == ENV['ID'] && pass == ENV['PASS']
      puts "You have entered an invalid id or password"
      exit 1
    end

    Faraday.new(url: "https://robot.diveintocode.jp:17777") do |connection|
      connection.use Faraday::Request::BasicAuthentication, id, pass
      connection.response :raise_error
      connection.adapter Faraday.default_adapter
    end
  end

  def hash(connection)
    response = connection.get("/programLanguages")
    JSON.parse(response.body)
  end
end

if $0 == __FILE__
  unless ARGV.length == 3
    puts "Usage: ruby robot_api_client.rb < json | csv > <id> <pass>" 
    exit 1
  end
  RobotApiClient.new.get_language(ARGV[0], ARGV[1], ARGV[2])
end