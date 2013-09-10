require "spec_helper"

describe "Kanbox" do
  describe "Feature" do
    before :all do
      url = $client.authorize_url
      puts "="*20
      puts "Please open and login: #{url}"
      print "Code:"
      auth_code = $stdin.gets.chomp.split("\n").first
      $client.token!(auth_code)
      # TODO: auth_code will get failed with $client.token! in sometimes
    end

    describe "#revert_token!" do
      it "should work" do
        old_access_token = $client.access_token.token
        $client.access_token = nil
        $client.revert_token!(old_access_token)
        $client.access_token.should_not be_nil
        $client.access_token.token.should == old_access_token
      end
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

    describe "Operations" do
      before :all do
        @source_path = File.expand_path("../fixtures/a.jpg",__FILE__)
        @save_path = "#{(Time.now.to_i * 1000).to_i}.jpg"
      end
      
      it "#put should work" do
        result = $client.put(@save_path,@source_path)
        result.success.should be_true
      end
      
      it "#head should work" do
        $client.head(@save_path).status.should == 200
      end
      
      it "#get should work" do
        response = $client.get(@save_path)
        response.status.should == 200
      end
      
      it "#copy should work" do
        new_path = "copy_#{@save_path}"
        result = $client.copy(@save_path, new_path)
        result.success.should be_true
        $client.head(@save_path).status.should == 200
        $client.head(new_path).status.should == 200
      end
      
      it "#move should work" do
        from_path = "copy_#{@save_path}"
        new_path = "1_#{@save_path}"
        result = $client.move(from_path, new_path)
        result.success.should be_true
        # TODO: need to confirm file has delete
        # $client.head(from_path).status.should == 404
        $client.head(new_path).status.should == 200
      end
      
      it "#delete should work" do
        path = "1_#{@save_path}"
        result = $client.delete(path)
        result.success.should be_true
        # TODO: need to confirm file has delete
        # $client.head(path).status.should == 404
        
        result = $client.delete(@save_path)
        result.success.should be_true
        # TODO: need to confirm file has delete
        # $client.head(@save_path).status.should == 404
      end
    end
  end
end
