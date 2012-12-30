# To change this template, choose Tools | Templates
# and open the template in the editor.

puts "Hello World"

class Validations
  PHONE_PREFIX_LOCAL=/0/
  PHONE_PREFIX_INTERNATIONAL=/[0{2}\+][1-9]\d{0,2}/

  PHONE_SHARED_PART=/(\d[\-\s\(\)]{0,2}){6,11}\d/

  PHONE_LOCAL=/(#{PHONE_PREFIX_LOCAL})(#{PHONE_SHARED_PART})/
  PHONE_INTERNATIONAL=/(#{PHONE_PREFIX_INTERNATIONAL})(#{PHONE_SHARED_PART})/

  PHONE=/#{PHONE_LOCAL}|#{PHONE_INTERNATIONAL}/

  DOMAIN=/[a-zA-Z0-9][a-zA-Z0-9-]{0,60}[a-zA-Z0-9]/
  TLD=/[a-zA-Z0-9]{2,3}|[a-zA-Z0-9]{2}\.[a-zA-Z0-9]{2}/
  HOSTNAME=/#{DOMAIN}(\.#{DOMAIN})*(\.#{TLD})/

  EMAIL_NAME=/[a-zA-Z0-9][a-zA-Z0-9\_\+\-\.]{0,200}/
  EMAIL=/#{EMAIL_NAME}@#{HOSTNAME}/

  def self.email?(text)
    mailname, hostname = text.split('@')
    mailname=~/^#{EMAIL_NAME}$/ and self.hostname?(hostname)
  end

  def self.phone?(text)
    local="^#{PHONE_LOCAL}$"
    international="^#{PHONE_INTERNATIONAL}$"
    (text=~ /(#{local})|(#{international})/) != nil ? true : false
  end

  def self.hostname?(text)
    return false unless text=~/^#{HOSTNAME}$/
    text.split('.').select {|domain| domain.length < 63}.size == text.split('.').size
  end

  def self.number?(text)
    (text=~/^-?\d+\.?\d+$/) != nil ? true : false
  end

  def self.integer?(text)
    (text=~/^-?\d+$/) != nil ? true : false
  end

  def self.date?(text)
    (text=~/^(\d{4}-\d{2}-\d{2})$/) != nil ? true : false
  end

  def self.time?(text)
    (text=~/^(\d{2}:\d{2}:\d{2})$/) != nil ? true : false
  end

  def self.date_time?(text)
    date? text[0,10] and time? text[11,8]
  end

  def self.ip_address?(text)
    return false unless text.count(".") == 3
    text.split('.').select { |byte| self.integer? byte and (byte.to_i >= 0 && byte.to_i <=255) }.size == 4
  end
end

class PrivacyFilter
  attr_accessor :preserve_email_hostname, :preserve_phone_country_code, :partially_preserve_email_username
  def initialize(text)
    @preserve_phone_country_code = false
    @preserve_email_hostname = false
    @partially_preserve_email_username = false
    @text = text
  end

  def filtered
    filter_mail(filter_phone(@text))
  end

  private
  def filter_phone(text)
    return text.gsub Validations::PHONE,'[PHONE]' unless @preserve_phone_country_code
    text.gsub /#{Validations::PHONE}/, '\4 [FILTERED]'
  end

  def filter_mail(text)
    return text.gsub /#{Validations::EMAIL_NAME}@/, '[FILTERED]@' if @preserve_email_hostname
    text.gsub /(#{Validations::EMAIL_NAME})@/, ''
    return text.gsub /(#{Validations::EMAIL_NAME})@/, "#{$1[0,3]}[FILTERED]@" if @partially_preserve_email_username
    text.gsub Validations::EMAIL,'[EMAIL]'
  end

end
