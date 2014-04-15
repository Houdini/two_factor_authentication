RSpec.configure do |c|
  c.before(:each) do
    SMSProvider.messages.clear
  end
end
