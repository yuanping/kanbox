require "rspec"
require "kanbox"

$client = Kanbox.configure do |config|
  config.api_key = "3166247a84749f9aed19c3449447e437"
  config.api_secert = "616d4153a16d60a64bd92cb08daf2278"
end

$temp_access_token = "56e872bbad241af8b1700780414c0937"