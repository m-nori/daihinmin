class Card < ActiveRecord::Base
  def equal_card?(hash)
    case
    when hash[:joker]
      joker ? true : false
    when hash[:mark] == mark && hash[:number] == number
      true
    else
      false
    end
  end
end
