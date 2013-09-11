require "json"
module Kanbox
  
=begin rdoc
  API Result model
=end
  class Result < Base
    attr_accessor :success, :error_code, :raw
    
    def to_s
      { success: self.success, error_code: self.error_code }.to_s
    end
    
    def self.parse(body)
      r = Result.new(success: false, error_code: nil)
      return r if body.blank?
      json = JSON.parse(body)
      r.raw = json
      if json['status'] == 'ok'
        r.success = true
      else
        r.error_code = json['errorCode']
      end
      r
    end
  end
end