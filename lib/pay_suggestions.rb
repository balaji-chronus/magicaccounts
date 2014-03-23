module PaySuggestions
  class PaySystem
    attr_accessor :group, :payers, :receivers, :users

    def initialize(group)
      self.group = group
      self.payers = Hash.new
      self.receivers = Hash.new
      self.get_payers_receivers(group)
      self.users = self.receivers.merge(self.payers)
    end

    def get_payers_receivers(group)
      balances = Transaction.user_balance(group).collect do |entry| 
        { 
          :user_id => entry.user_id, 
          :balance => entry.balance && entry.balance * -1
        }
      end
        balances = balances.reject{|x| x[:balance].nil? || x[:balance] == 0 }
      balances.select{|b| b[:balance] > 0}.sort_by{|b| -b[:balance]}.each do |entry|
        self.payers[entry[:user_id]] = PayUser.new(User.find(entry[:user_id]),entry[:balance])
      end
      balances.select{|b| b[:balance] < 0}.sort_by{|b| b[:balance]}.each do |entry|
        self.receivers[entry[:user_id]] = PayUser.new(User.find(entry[:user_id]),entry[:balance])
      end
    end

    def highest_payer
      hp = self.payers.values.sort{|v, u| u.new_balance <=> v.new_balance }[0]
      return hp if hp && hp.new_balance > 0
    end

    def highest_receiver
      hr = self.receivers.values.sort{|v, u| v.new_balance <=> u.new_balance }[0]
      return hr if hr && hr.new_balance < 0
    end

    def calculate
      hp = self.highest_payer
      hr = self.highest_receiver
      if hp && hr
        if hp.new_balance > (-1 * hr.new_balance)
          hp.transaction_partners[hr.group_user] = -1 * hr.new_balance
          hr.transaction_partners[hp.group_user] =  -1 * hr.new_balance

          hp.new_balance = hp.new_balance + hr.new_balance
          hr.new_balance = 0

        else
          hr.transaction_partners[hp.group_user] = hp.new_balance
          hp.transaction_partners[hr.group_user] = hp.new_balance

          hr.new_balance = hp.new_balance + hr.new_balance
          hp.new_balance = 0
        end
        self.calculate
      end
      return
    end

    def self.create(group)
      pay_struct = self.new(group)
      pay_struct.calculate
      return pay_struct
    end
  end

  class PayUser
    attr_accessor :group_user, :new_balance, :transaction_partners

    def initialize(user,balance)
      self.group_user = user
      self.new_balance = balance
      self.transaction_partners = Hash.new
    end

  end
end