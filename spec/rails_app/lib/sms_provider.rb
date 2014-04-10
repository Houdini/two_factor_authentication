require 'ostruct'

class SMSProvider
  Message = Class.new(OpenStruct)

  class_attribute :messages
  self.messages = []

  def self.send_message(opts = {})
    self.messages << Message.new(opts)
  end

  def self.last_message
    self.messages.last
  end

end
