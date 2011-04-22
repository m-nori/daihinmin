class CardUtiles
  def CardUtiles.create_hand(count)
    cards = Card.all.sort_by{rand}
    hands = []
    cards.each_slice(cards.size.quo(count).ceil) do |hand|
      hands << hand
    end
    hands.sort_by{rand}
  end
end
