require "json"
module Kanbox
  class Result < Base
    attr_accessor :success, :error_code
    
    def to_s
      { success: self.success, error_code: self.error_code }.to_s
    end
    
    def self.parse(body)
      r = Result.new(success: false, error_code: nil)
      return r if body.blank?
      json = JSON.parse(body)
      if json['status'] == 'ok'
        r.success = true
      else
        r.error_code = json['errorCode']
      end
      r
    end
  end
end