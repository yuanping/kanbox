# coding: utf-8
require "spec_helper"
require "oauth2"

describe "Kanbox" do
  describe "OAuth" do
    before :all do
      @mock_hash = { 
        access_token: "SlAV32hkKG", 
        token_type: "Bearer",
        expires_in: 3600, 
        refresh_token: "5c32995dd5c7b3ff8e1a6b047e9f3af4" 
      } 
    end
    
    describe "#authorize_url" do
      it "should work" do
        url = $client.authorize_url
        url.should == "https://auth.kanbox.com/0/auth?response_type=code&client_id=#{$client.api_key}&redirect_uri=#{CGI.escape(Kanbox::DEFAULT_REDIRECT_URI)}"
      end

      it "should work with custom redirect_uri" do
        to_url = "http://foo.aaa.com/a"
        url = $client.authorize_url(redirect_uri: to_url)
        url.should == "https://auth.kanbox.com/0/auth?response_type=code&client_id=#{$client.api_key}&redirect_uri=#{CGI.escape(to_url)}"
      end
    end

    describe "#token!" do
      it "should work" do
        access_token_mock = OAuth2::AccessToken.from_hash($client.oauth_client,@mock_hash.dup)
        $client.oauth_client.auth_code.should_receive(:get_token).once.with('aaa',redirect_uri: Kanbox::DEFAULT_REDIRECT_URI).and_return(access_token_mock)
        token = $client.token!('aaa')
        $client.access_token.token.should == @mock_hash[:access_token]
        token.token.should == @mock_hash[:access_token]
        token.refresh_token.should == @mock_hash[:refresh_token]
      end
    end
  
    describe "#refresh_token!" do
      it "should work" do
        access_token_mock = OAuth2::AccessToken.from_hash($client.oauth_client,@mock_hash.dup)
        OAuth2::AccessToken.should_receive(:new).with(any_args).and_return(access_token_mock)
        fack_result_access_token = access_token_mock.dup
        fack_result_access_token.stub(:token).and_return { "aaa" }
        access_token_mock.should_receive(:refresh!).and_return(fack_result_access_token)
        $client.refresh_token!($client.access_token.refresh_token)
        $client.access_token.token.should == "aaa"
      end
    end
  end  
end
