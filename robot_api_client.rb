require 'faraday'
require 'json'
require 'csv'

class RobotApiClient
  def get_language(datatype, id, pass)    
    response = connection(id, pass).get("/programLanguages")
    hash = JSON.parse(response.body)
    
    case datatype
    when "json" then 
      json_str = JSON.pretty_generate(hash)
      puts json_str
    when "csv" then
      csv_str = CSV.generate do |csv|
        csv << hash[0].keys
        hash.each { |hash| csv << hash.values}
      end
      puts csv_str
    end
  end

  private
  def connection(id, pass)
    Faraday.new(url: "https://robot.diveintocode.jp:17777") do |connection|
      connection.use Faraday::Request::BasicAuthentication, id, pass 
      connection.adapter Faraday.default_adapter
    end
  end
end

if $0 == __FILE__
  RobotApiClient.new.get_language(ARGV[0], ARGV[1], ARGV[2])
end
