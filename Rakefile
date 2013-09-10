require File.expand_path('../lib/kanbox', __FILE__)

task :real_test do
  $client = Kanbox.configure do |config|
    config.api_key = "3166247a84749f9aed19c3449447e437"
    config.api_secert = "616d4153a16d60a64bd92cb08daf2278"
  end

  if 1 == 2
    url = $client.authorize_url
    puts "Please open and login: #{url}"
    print "type callback url code:"
    auth_code = $stdin.gets.chomp.split("\n").first
  
    puts "=== Token"
    $client.token!(auth_code)
    puts "access_token : #{$client.access_token.token}"
    puts "refresh_token : #{$client.access_token.refresh_token}"
  
    puts "=== Refresh token"
    $client.refresh_token!($client.access_token.refresh_token)
    puts "New access_token: #{$client.access_token.token}"
  else
    $client.revert_token!('b62da8360482aa94659122734fa3ec11')
  end
  
  puts "=== Profile"
  print "   ",$client.profile.email
  puts ""
  
  puts "=== List"
  files = $client.files
  for file_info in files 
    puts "   #{file_info.full_path}  #{file_info.size}"
  end
  
  puts "=== Put"
  $client.put("foo.jpg",File.expand_path("../spec/fixtures/a.jpg",__FILE__))
end