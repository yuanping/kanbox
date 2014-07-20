require 'oauth2'
require "json"

module Kanbox
  
  BASE_URL = 'https://api.kanbox.com/0'
  ##
  # Kanbox Client - methods for Authorization and access API
  class Client
    attr_accessor :api_key, :api_secret, :config
    ##
    # OAuth2::AccessToken
    #
    # Store authorized infos
    attr_accessor :access_token

    # @param [String] token the Access Token value
    # @param [Hash] opts the options to create the Access Token with
    # @option opts [String] :refresh_token (nil) the refresh_token value
    # @option opts [FixNum, String] :expires_in (nil) the number of seconds in which the AccessToken will expire
    # @option opts [FixNum, String] :expires_at (nil) the epoch time in seconds in which AccessToken will expire
    def initialize(token=nil, opts={}, &block)
      instance_eval &block
      self.access_token = OAuth2::AccessToken.new(self.oauth_client, token, opts) if token
    end

    ##
    # OAuth2::Client instance with kanbox OAuth
    def oauth_client
      @oauth_client ||= OAuth2::Client.new(self.api_key,self.api_secret,
                                      site: "https://auth.kanbox.com",
                                      authorize_url: "/0/auth",
                                      token_url: "/0/token")
    end

    
=begin rdoc
OAuth2 +authorize_url+

redirect or open this URL for login in Kanbox website
    
=== Params:
    
* +opts+ Hash
  * +redirect_uri+ String - default Kanbox::DEFAULT_REDIRECT_URI,URL with logined redirect back

=== Rails example:

  class SessionController
    def oauth
      redirect_to $kanbox.authorize_url(redirect_uri: callback_session_url)
    end

    def callback
      auth_code = params[:code]
      $kanbox.token!(auth_code)
    end
  end
=end
    def authorize_url(opts = {})
      opts[:redirect_uri] ||= DEFAULT_REDIRECT_URI
      self.oauth_client.auth_code.authorize_url(redirect_uri: opts[:redirect_uri])
    end

    
=begin rdoc
OAuth get_token method
    
This method will get #access_token (OAuth2::AccessToken) ... and save in Kanbox instance
    
== Params:
    
* authorization_code - Authorization Code in callback URL
* opts
  * +redirect_uri+ String - default Kanbox::DEFAULT_REDIRECT_URI,URL with logined redirect back
=end
    def token!(authorization_code,opts = {})
      opts[:redirect_uri] ||= DEFAULT_REDIRECT_URI
      self.access_token = self.oauth_client.auth_code.get_token(authorization_code, redirect_uri: opts[:redirect_uri])
    end

=begin rdoc
OAuth refresh_token method

Refresh tokens when token was expired

== Params:

* refresh_token - refresh_token in last got #access_token
=end
    def refresh_token!(refresh_token)
      old_token = OAuth2::AccessToken.new(self.oauth_client,'', refresh_token: refresh_token)
      self.access_token = old_token.refresh!
    end

=begin rdoc
Revert #access_token info with String access_token

You can store #access_token.token in you database or local file, when you restart you app, you can revert #access_token instance by that token

== Params:

* access_token - token in last got #access_token.token
=end
    def revert_token!(access_token)
      self.access_token = OAuth2::AccessToken.new(self.oauth_client,access_token)
    end
    
    def valid_token
      if access_token.expired?
        self.access_token = access_token.refresh!
      end
      self.access_token
    end


    def api_url(path)
      URI.parse([BASE_URL, URI::encode(path)].join("/"))
    end

    def status(response)
      return Result.new(success: false) if response.blank?
      Result.parse(response.body)
    end

    def profile
      response = valid_token.get(self.api_url("info")).body
      json = JSON.parse(response)
      return nil if json['status'] != 'ok'
      return User.new(email: json['email'], space_quota: json['spaceQuota'], space_used: json['spaceUsed'])
    end

    def files(path=nil)
      url = self.api_url("list#{path if path}")
      response = valid_token.get(url).body
      json = JSON.parse(response)
      return [] if json['status'] != 'ok'
      files = []
      for item in json['contents']
        files << FileInfo.new(full_path: item['fullPath'],
                              updated_at: Time.parse(item['modificationDate']),
                              size: item['fileSize'],
                              is_folder: item['fileSize'])
      end
      files
    end

    def get(path)
      response = valid_token.get(self.api_url("download/#{path}"))
      return response
    end

    def head(path)
      response = valid_token.get(self.api_url("download/#{path}"))
      return response
    end

    def put(path, file, opts = {})
      # TODO: use ruby stdlib to instead rest-client
      require 'rest-client'
      
      url = "https://api-upload.kanbox.com/0/upload/#{path}"
      response = RestClient.post(URI::encode(url), file, valid_token.headers)
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
      response = valid_token.get(self.api_url("copy/#{path}?destination_path=/#{destination_path}"))
      status response
    end

    def move(path,destination_path)
      response = valid_token.get(self.api_url("move/#{path}?destination_path=/#{destination_path}"))
      status response
    end

    def delete(path)
      response = valid_token.get(self.api_url("delete/#{path}"))
      status response
    end

    def mkdir(path)
      response = valid_token.get(self.api_url("create_folder/#{path}"))
      status response
    end

    def share(path, with_emails)
      response = valid_token.post(self.api_url("share/#{path}"),"{#{with_emails}}")
      status response
    end

    def pending_shares
      response = valid_token.get(self.api_url("pendingshares/#{path}"))
      status response
    end
    
    
  end
end
