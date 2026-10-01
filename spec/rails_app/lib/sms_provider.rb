class SMSProvider
  Message = Struct.new(:to, :body)

  class_attribute :messages
  self.messages = []

  def self.send_message(opts = {})
    self.messages << Message.new(opts[:to], opts[:body])
  end

  def self.last_message
    self.messages.last
  end

end
