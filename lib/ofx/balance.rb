module OFX
  class Balance < Foundation
    attr_accessor :amount
    attr_accessor :amount_in_pennies
    attr_accessor :posted_at
  end
end