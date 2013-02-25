# coding: utf-8
class RubyStack < Array
  alias top last
end
CStack = RubyStack