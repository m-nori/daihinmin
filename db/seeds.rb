
1.upto(4) do |mark|
  1.upto(13) do |number|
    Card.create(:mark => mark, :number => number, :joker => false )
  end
end
Card.create(:mark => 0, :number => 0, :joker => true )
Card.create(:mark => 0, :number => 0, :joker => true )

