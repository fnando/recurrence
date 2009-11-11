module OFX
  class Account < Foundation
    attr_accessor :balance
    attr_accessor :bank_id
    attr_accessor :currency
    attr_accessor :id
    attr_accessor :transactions
    attr_accessor :type
  end
end
