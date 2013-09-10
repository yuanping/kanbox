require 'oauth2'
require "json"

module Kanbox
  class Client
    attr_accessor :api_key, :api_secert, :config, :access_token
    
    def initialize(&block)
      instance_eval &block
    end
    
    def oauth_client
      @oauth_client ||= OAuth2::Client.new(self.api_key,self.api_secert,
                                      site: "https://auth.kanbox.com",
                                      authorize_url: "/0/auth",
                                      token_url: "/0/token")
    end
    
    def authorize_url(opts = {})
      opts[:redirect_uri] ||= DEFAULT_REDIRECT_URI
      self.oauth_client.auth_code.authorize_url(redirect_uri: opts[:redirect_uri])
    end
    
    def token!(authorization_code,opts = {})
      opts[:redirect_uri] ||= DEFAULT_REDIRECT_URI
      self.access_token = self.oauth_client.auth_code.get_token(authorization_code, redirect_uri: opts[:redirect_uri])
    end
    
    def refresh_token!(refresh_token)
      old_token = OAuth2::AccessToken.new(self.oauth_client,'', refresh_token: refresh_token)
      self.access_token = old_token.refresh!
    end
    
    def revert_token!(access_token)
      self.access_token = OAuth2::AccessToken.new(self.oauth_client,access_token)
    end
    
    def api_url(path)
      ["https://api.kanbox.com/0",path].join("/")
    end
    
    def profile
      response = self.access_token.get(self.api_url("info")).body
      json = JSON.parse(response)
      return nil if json['status'] != 'ok'
      return User.new(email: json['email'], space_quota: json['spaceQuota'], space_used: json['spaceUsed'])
    end
    
    def files
      response = self.access_token.get(self.api_url("list")).body
      json = JSON.parse(response)
      return [] if json['status'] != 'ok'
      files = []
      for item in json['contents']
        files << FileInfo.new(full_path: item['fullPath'], 
                              updated_at: Date.parse(item['modificationDate']),
                              size: item['fileSize'],
                              is_folder: item['fileSize'])
      end
      files
    end

    def put(path, source_file_path, opts = {})
      opts[:content_type] ||= "image/jpeg"
      f = Faraday::UploadIO.new(source_file_path.to_s,opts[:content_type])
      conn = Faraday.new(:url => "https://api-upload.kanbox.com") do |conn|
        conn.request :multipart
        conn.request :url_encoded
      end
      response = conn.post do |req|
        req.url "/0/upload"
        req.body = { path: path, file: f }.to_s
        req.headers['Authorization'] = "Bearer #{self.access_token.token}"
        req.headers['Content-Type'] = opts[:content_type]
      end
      if response.status != 200
        puts "resute: #{response.inspect}"
      end
      response.status
    end

    def delete(path)
    end

    def move(path,destination_path)
    end

    def copy(path,destination_path)
    end

    def mkdir(path)
    end

    def share(path, with_users)
    end

    def pending_shares
    end
  end
end