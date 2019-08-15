require 'faraday'
require 'json'
require 'csv'

connection = Faraday.new(url: "https://robot.diveintocode.jp:17777") do |builder|
  builder.use Faraday::Request::BasicAuthentication, "#{ARGV[1]}","#{ARGV[2]}"
  builder.adapter Faraday.default_adapter
end

response = connection.get("/programLanguages")
hash = JSON.parse(response.body)

case ARGV[0]
when "json" then 
  json_str = JSON.pretty_generate(hash)
  puts json_str
when "csv" then
  csv_string = CSV.generate do |csv|
    csv << hash[0].keys
    hash.each { |hash| csv << hash.values }
  end
  puts csv_string
end
