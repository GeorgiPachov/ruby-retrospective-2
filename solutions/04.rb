module Validations
  PHONE_SEPARATOR=/[\-\s\(\)]/

  PHONE_PREFIX_LOCAL=/0/
#  PHONE_PREFIX_INTERNATIONAL=/[00\+]#{PHONE_SEPARATOR}?[1-9]\d{0,2}#{PHONE_SEPARATOR}?/
  PHONE_PREFIX_INTERNATIONAL=/((00)|\+)#{PHONE_SEPARATOR}?[1-9]\d{0,2}#{PHONE_SEPARATOR}?/

  PHONE_SHARED_PART=/((\d#{PHONE_SEPARATOR}{0,2})){6,11}\d/
  PHONE_LOCAL_SUFFIX=/([1-9]#{PHONE_SEPARATOR}{0,2}(\d#{PHONE_SEPARATOR}{0,2})){4,10}\d/

  PHONE_LOCAL=/(#{PHONE_PREFIX_LOCAL})#{PHONE_SEPARATOR}?(#{PHONE_LOCAL_SUFFIX})/
  PHONE_INTERNATIONAL=/(#{PHONE_PREFIX_INTERNATIONAL})#{PHONE_SEPARATOR}?(#{PHONE_SHARED_PART})/

  PHONE=/#{PHONE_LOCAL}|#{PHONE_INTERNATIONAL}/

  DOMAIN=/[a-zA-Z0-9][a-zA-Z0-9-]{0,60}[a-zA-Z0-9]|[a-zA-Z0-9]/
  TLD=/[a-zA-Z]{2,3}|[a-zA-Z]{2}\.[a-zA-Z]{2}/
  HOSTNAME=/#{DOMAIN}(\.#{DOMAIN})*(\.#{TLD})/

  EMAIL_NAME=/[a-zA-Z0-9][a-zA-Z0-9\_\+\-\.]{0,200}/
  EMAIL=/#{EMAIL_NAME}@#{HOSTNAME}/

  INTEGER=/([0-9])|([1-9][0-9]*)/

  def self.email?(text)
    mailname, hostname = text.split('@')
    mailname=~/^#{EMAIL_NAME}$/ and self.hostname?(hostname)
  end

  def self.phone?(text)
    local="^#{PHONE_LOCAL}$"
    international="^#{PHONE_INTERNATIONAL}$"
    (text=~ /(#{local})|(#{international})/) != nil ?  check_newline(text) : false
  end

  def self.hostname?(text)
    return false unless text=~/^#{HOSTNAME}$/ and check_newline(text)
    text.split('.').select {|domain| domain.length < 63}.size == text.split('.').size
  end

  def self.number?(text)
    (text=~/^-?#{INTEGER}(\.\d+)?$/) != nil ? check_newline(text) : false
  end

  def self.integer?(text)
    (text=~/^-?(#{INTEGER})$/) != nil ? check_newline(text) : false
  end

  def self.date?(text)
    return check_newline(text) if (text=~/^(\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[01]))$/)
  end

  def self.time?(text)
    (text=~/^(([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9])$/) != nil ? check_newline(text) : false
  end

  def self.date_time?(text)
    date? text[0,10] and time? text[11,8] and check_newline(text)
  end

  def self.ip_address?(text)
    return false unless text.count(".") == 3
    text.split('.').select { |byte| byte? byte }.size == 4
  end

  private
  def self.check_newline(text)
    (text=~/\n/) == nil
  end

  def self.byte?(text)
    integer? text and (text.to_i >= 0 && text.to_i <=255)
  end
end

class PrivacyFilter
  attr_accessor :preserve_email_hostname, :preserve_phone_country_code,
    :partially_preserve_email_username

  def initialize(text)
    @preserve_phone_country_code = false
    @preserve_email_hostname = false
    @partially_preserve_email_username = false
    @text = text
  end

  def filtered
    filtered_1 = filter_phone(@text)
    has_mail = filtered_1.split(/[\s:,]/).count { |word| word=~/^#{Validations::EMAIL}$/} > 0
    return filter_mail(filtered_1) if has_mail
    return filtered_1
  end

  private
  def filter_phone(text)
    return text.gsub /#{Validations::PHONE}/, '\4 [FILTERED]' if @preserve_phone_country_code
    text.gsub Validations::PHONE,'[PHONE]'
    return text.gsub Validations::PHONE,'[PHONE]'
  end

  def filter_mail(text)
    return text.gsub /#{Validations::EMAIL_NAME}@/, '[FILTERED]@' if @preserve_email_hostname
    return text.gsub Validations::EMAIL,'[EMAIL]' unless @partially_preserve_email_username
    text.gsub /(#{Validations::EMAIL_NAME})@/, ''
    text.gsub /(#{Validations::EMAIL_NAME})@/, "#{$1[0, min(3,$1.size- 3)]}[FILTERED]@"
  end

  private
  def min(a,b)
    return a if a <= b
    return b
  end

end
{
  'Reach me at: 0885123123' => 'Reach me at: [PHONE]',
  '+155512345699' => '[PHONE]',
  '+1 555 123-456' => '[PHONE]',
  '+1 (555) 123-456-99' => '[PHONE]',
  '004412125543' => '[PHONE]',
  '0044 1 21 25 543' => '[PHONE]',
}.each do |text, filtered|
#  puts PrivacyFilter.new(text).filtered
#  puts filtered
end
puts '0885123123'=~Validations::PHONE_LOCAL_SUFFIX

