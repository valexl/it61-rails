# Ответы сервера:
# 0 - сообщение добавлено в очередь (время отправки от 30 секунд до 2 минут)
# -9 - исчерпан баланс
# -765 - server error(db)
# -761 - invalid datetime
# -767 - invalid phone
# -763 - server errror
module SmsSender
  NoMoneyError = Class.new(RuntimeError)
  ServerDbError = Class.new(RuntimeError)
  InvalidDateTimeError = Class.new(RuntimeError)
  InvalidPhoneError = Class.new(RuntimeError)
  ServerError = Class.new(RuntimeError)
  UnknownResponseCodeError = Class.new(RuntimeError)
  SmsServiceNotConfiguredError = Class.new(RuntimeError)
  NotImplementedError = Class.new(RuntimeError)

  class Epochta
    def initialize
      @epochta = EPochtaService::EPochtaSMS.new(private_key: ENV['EPOCHTA_PRIVATE_KEY'],
                                                public_key: ENV['EPOCHTA_PUBLIC_KEY'])
    end

    def send!(text, sender_name, phone_number, sending_time = nil)
      # В базе хранятся номера нормализованные в соответсвии со стандартом E.164, который не подразумевает
      # символ '+' перед кодом страны. Но Epochta требует, чтобы номер начинались с '+'.
      phone_number.prepend '+' unless phone_number.start_with? '+'
      options = { text: text,
                  phone: phone_number,
                  sms_lifetime: '0',
                  type: ENV['EPOCHTA_TYPE'].to_s }
      options[:sender] = sender_name if sender_name.present?
      options[:datetime] = sending_time if sending_time
      result = @epochta.send_sms(options)
      raise SmsSender::ServerError.new unless result
      result
    end
  end
end