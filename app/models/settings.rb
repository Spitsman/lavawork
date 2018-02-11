class Settings

  instance_methods.each do |m|
    undef_method m unless m.to_s =~ /^__|method_missing|respond_to?/
  end

  class << self

    def method_missing(name, *args)
      if name =~ /\=/
        $redis.set name.to_s.gsub('=', ''), args[0]
        args[0]
      else
        $redis.get name
      end
    end

    def keys
      [:demurrage, :commission, :master_account, :accrual_frequency, :additional_amount, :amount]
    end

    def change_amount(amount)
      new_amount = $redis.get('amount').to_f + amount.to_f
      @redis.set('amount', new_amount)
      new_amount
    end

  end
end
