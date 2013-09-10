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
      URI.parse(["https://api.kanbox.com/0",path].join("/"))
    end
    
    def status(response)
      return Result.new(success: false) if response.blank?
      Result.parse(response.body)
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
    
    def get(path)
      response = self.access_token.get(self.api_url("download/#{path}"))
      return response
    end
    
    def head(path)
      response = self.access_token.get(self.api_url("download/#{path}"))
      return response
    end

    def put(path, source_file_path, opts = {})
      require 'rest-client'
      f = File.open(source_file_path)
      url = "https://api-upload.kanbox.com/0/upload/#{path}"
      response = RestClient.post(url,f, self.access_token.headers)
      result = Result.new
      if response == "1"
        result.success = true
      else
        result.success = false
        result.error_code = response
      end
      result
    end

    def copy(path,destination_path)
      response = self.access_token.get(self.api_url("copy/#{path}?destination_path=/#{destination_path}"))
      status response
    end

    def move(path,destination_path)
      response = self.access_token.get(self.api_url("move/#{path}?destination_path=/#{destination_path}"))
      status response
    end

    def delete(path)
      response = self.access_token.get(self.api_url("delete/#{path}"))
      status response
    end
    
    def mkdir(path)
    end

    def share(path, with_users)
    end

    def pending_shares
    end
  end
end
