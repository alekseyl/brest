module ExceptionExt
  def app_backtrace
    backtrace.select{|ln| ln['app']}
  end

  def messages
    is_a?( ActiveRecord::RecordInvalid) ? record.errors.messages : self
  end

  def trace
    {
      errors: messages,
      backtrace: app_backtrace
    }
  end
end

Exception.include( ExceptionExt )