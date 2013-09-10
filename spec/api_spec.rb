require "spec_helper"

describe "Kanbox" do
  describe "API" do
    before :all do
      $client.revert_token!($temp_access_token)
    end
    
    describe "#profile" do
      it "should work" do
        user = $client.profile
        user.should_not be_nil
        user.email.should_not be_blank
      end
    end
    
    describe "#files" do
      it "should work" do
        fake_body = %({
          "status":"ok",
          "hash":1365320174,
          "contents":[
            {"fullPath":"\/\u7167\u7247","modificationDate":"2013-04-07T07:36:14+00:00","fileSize":0,"isFolder":true,"isShared":false,"creationDate":null},
            {"fullPath":"\/\u6b22\u8fce\u4f7f\u7528\u9177\u76d8.pdf","modificationDate":"2013-04-07T07:36:14+00:00","fileSize":209402,"isFolder":false,"isShared":false,"creationDate":null}
          ]
        })
        fake_respose = Class.new
        fake_respose.stub(:body).and_return(fake_body)
        $client.access_token.should_receive(:get).with($client.api_url("list")).and_return(fake_respose)
        files = $client.files
        files.count.should == 2
        files[0].class.should == Kanbox::FileInfo
        files[0].full_path.should == "\/\u7167\u7247"
        files[0].updated_at.should == Date.parse("2013-04-07T07:36:14+00:00")
        files[0].size.should == 0
        files[0].is_folder.should be_true
        files[1].size.should == 209402
      end
    end
  end
end