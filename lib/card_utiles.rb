class CardUtiles
  RANK = {false => [3,4,5,6,7,8,9,10,11,12,13,1,2],
          true  => [2,1,13,12,11,10,9,8,7,6,5,4,3]}

  def self.create_hand(count)
    cards = Card.all.sort_by{rand}
    hands = []
    cards.each_slice(cards.size.quo(count).ceil) do |hand|
      hands << hand
    end
    hands.sort_by{rand}
  end

  def self.include?(hand, cards)
    cards.all?{|card| hand.any?{|h| h.equal_card?(card)}}
  end

  def self.yaku?(cards)
    case
    when cards.length <= 1
      true
    when cards.length != cards.uniq.length
      false
    when self.pare?(cards)
      true
    when self.kaidan?(cards)
      true
    else
      false
    end
  end

  def self.compare_yaku(place_cards, cards, revolution)
  end

  def self.pare?(cards)
    not_jokers = cards.reject{|card| card[:joker]}
    n = not_jokers[0][:number]
    not_jokers.all?{|card| n == card[:number]}
  end

  def self.kaidan?(cards)
    return false if cards.length < 2
    joker_count = cards.find_all{|card| card[:joker]}.length
    not_jokers = self.sort(cards.reject{|card| card[:joker]})
    return false unless not_jokers.all?{|card| not_jokers[0][:mark] == card[:mark]}
    result = true
    not_jokers.each_with_index do |card, i|
      break if i ==  not_jokers.length-1
      next_number = get_next_number(card)
      diff_count = get_diff_count(next_number, not_jokers[i+1][:number])
      if diff_count != 0
        if diff_count > joker_count
          result = false
          break
        else
          joker_count - diff_count
        end
      end
    end
    result
  end

  def self.sort(cards, revolution=false)
    cards.sort{|a,b| self.compare_to(a,b, revolution)}
  end

  def self.compare_to(a,b, revolution=false)
    rank = RANK[revolution]
    case
    when a[:joker]
      b[:joker] ? 0 : 1
    when b[:joker]
      -1
    else
      rank.index(a[:number]) <=> rank.index(b[:number])
    end
  end

  def self.get_next_number(card, revolution=false)
    rank = RANK[revolution]
    index = rank.index(card[:number]) + 1
    index = 0 if index == rank.length
    rank[index]
  end

  def self.get_diff_count(a, b)
    rank = RANK[false]
    a_index = rank.index(a)
    b_index = rank.index(b)
    b_index - a_index
  end

  def self.to_hashs(card_strings)
    card_strings.map{|card_string| self.to_hash(card_string)}
  end

  def self.to_hash(card_string)
    hash = {:mark => 0, :number => 0, :joker => false}
    case card_string
    when /joker/
      hash[:joker] = true
    when /(\d)-(\d+)/
      hash[:mark] = $1.to_i
      hash[:number] = $2.to_i
    end
    hash
  end
end
