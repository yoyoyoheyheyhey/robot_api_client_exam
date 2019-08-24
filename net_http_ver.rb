require 'net/http'
require 'uri'
require 'json'
require 'csv'

def get_language(id, pass)
  uri = URI.parse("https://robot.diveintocode.jp:17777/programLanguages")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = uri.scheme === "https"

  req = Net::HTTP::Get.new(uri.path)
  req.basic_auth id, pass
  response = http.request(req)
  
  JSON.parse(response.body)
end
   
def output_language(data_format, hash)
  case data_format
  when "json"
    json_str = JSON.pretty_generate(hash)
    puts json_str
  when "csv"
    csv_str = CSV.generate do |csv|
      csv << hash[0].keys
      hash.each { |hash| csv << hash.values}
    end
    puts csv_str
  end
end

if $0 == __FILE__
  output_language(ARGV[0], get_language(ARGV[1], ARGV[2]))
end
