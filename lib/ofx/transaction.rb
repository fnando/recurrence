module OFX
  class Transaction < Foundation
    attr_accessor :amount
    attr_accessor :amount_in_pennies
    attr_accessor :check_number
    attr_accessor :fit_id
    attr_accessor :memo
    attr_accessor :payee
    attr_accessor :posted_at
    attr_accessor :ref_number
    attr_accessor :type
  end
end