酷盘 Ruby SDK
=============

酷盘 ([kanbox.com](http://kanbox.com)) API for Ruby

## Installation

```bash
$ gem install kanbox
```

## Usage

使用方法参见 spec 里面的测试用例。

```ruby
require "kanbox"

$client = Kanbox.configure do |config|
  config.api_key = "you client id"
  config.api_secert = "you client secert"
end
```
