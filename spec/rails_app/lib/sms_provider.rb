class SMSProvider
  Message = Struct.new(:to, :body, keyword_init: true)

  class_attribute :messages
  self.messages = []

  def self.send_message(opts = {})
    self.messages << Message.new(**opts)
  end

  def self.last_message
    self.messages.last
  end

end
