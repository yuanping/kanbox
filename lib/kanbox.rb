require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/class/attribute'
require 'active_support/concern'

%w(models/base models/file_info models/user models/result client).each do |fname|
  require File.expand_path("../kanbox/#{fname}", __FILE__)
end

module Kanbox
  DEFAULT_REDIRECT_URI = "urn:ietf:wg:oauth:2.0:oob"
  
  class << self
    def configure(&block)
      Client.new(&block)
    end
  end
end