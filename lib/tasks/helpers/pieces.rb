module Populator
  module Pieces
    def create_pieces_and_prices
      sizes = [2.25, 3, 3.5, 4]
      basic_pieces_array = Array.new
      weighted_pieces_array = Array.new

      sizes.each do |size|
        basic_pieces = FactoryGirl.create(:item, 
          name: "Basic Chess Pieces - #{size} inch King", 
          description: "The Basic Chess Pieces are our least expensive pieces and are ideal for schools and clubs working on a tight budget. These chess sets meet all chess tournament standards and regulations. They are a standard Staunton design and have a 3 3/4 inch tall King with a 1 1/2 inch felt paper base.", 
          color: "black/white", 
          category: "pieces", 
          picture: "basic-chess-pieces.jpg",
          weight: 0.85)
        basic_pieces_array << basic_pieces

        weighted_pieces = FactoryGirl.create(:item, 
          name: "Weighted Chess Pieces - #{size} inch King", 
          description: "Our Weighted Tournament Chess Pieces are just that - heavy! The entire set weighs in at just over 2 pounds and has a nice weighted feel. The pieces are easy to play with and their weight makes them perfect for tournaments or blitz play. With a King of 3 3/4 inch tall and a 1 1/2 inch base, these pieces meet all tournament regulations. The set includes extra queens as well.", 
          color: "black/white", 
          category: "pieces", 
          picture: "basic-chess-pieces.jpg",
          weight: 2.2)
        weighted_pieces_array << weighted_pieces
      end

      basic_pieces_array.each do |bp|
        old_price = 1.65
        4.times do |i|
          prices = get_new_prices(old_price)
          month = 25 - 6*i
          new_manf_price = FactoryGirl.create(:item_price, item: bp, price: prices[0], start_date: month.months.ago.to_date, category: 'manufacturer')
          new_whol_price = FactoryGirl.create(:item_price, item: bp, price: prices[1], start_date: month.months.ago.to_date)
          old_price = prices[0]
          FactoryGirl.create(:purchase, item: bp, quantity: Populator::QUANTITIES.sample, date: month.months.ago.to_date)
        end
      end

      weighted_pieces_array.each do |wp|
        old_price = 2.65
        4.times do |i|
          prices = get_new_prices(old_price)
          month = 25 - 6*i
          new_manf_price = FactoryGirl.create(:item_price, item: wp, price: prices[0], start_date: month.months.ago.to_date, category: 'manufacturer')
          new_whol_price = FactoryGirl.create(:item_price, item: wp, price: prices[1], start_date: month.months.ago.to_date)
          old_price = prices[0]
          FactoryGirl.create(:purchase, item: wp, quantity: Populator::QUANTITIES.sample, date: month.months.ago.to_date)
        end
      end

      zagreb_pieces = FactoryGirl.create(:item, 
        name: "Zagreb Chess Pieces", 
        description: "This is a beautiful reproduction of Zagreb Chess Set used at major international chess tournaments. The queens and bishops have a contrasting color ball on top and the king has a contrasting crown. The knight is a most interesting piece. Patterned after a Russian knight, he has his head down, a closed mouth, a dramatically carved head, and thin curved neck above his thick chest.  As with all wood pieces, sets many have variations in colors of grain within a set.  These pieces are weighted.", 
        color: "brown/tan", 
        category: "pieces", 
        weight: 2.25,
        inventory_level: 25,
        reorder_level: 10,
        active: false)

      wooden_pieces = FactoryGirl.create(:item, 
        name: "Wooden Chess Pieces", 
        description: "These beautiful wooden chess pieces are a great addition to any chess pieces collection or entry-level wood chess sets. The pieces are specifically designed to offer a solid, durable style that can stand up to abuse without breaking. They are designed with a simple but traditional style and are available in two wood finishes for the dark pieces. Light pieces are made from light boxwood, and dark pieces are made from sheesham. Each set features a full 32 pieces. These pieces are lightly weighted.", 
        color: "brown/tan", 
        category: "pieces",
        picture: "wooden-chess-pieces.jpg",
        inventory_level: 40,
        reorder_level: 10, 
        weight: 2.0)

      wdp1_m = FactoryGirl.create(:item_price, item: wooden_pieces, price: 5.95, category: 'manufacturer', start_date: 24.months.ago.to_date)
      wdp1_w = FactoryGirl.create(:item_price, item: wooden_pieces, price: 8.95, category: 'wholesale', start_date: 24.months.ago.to_date)
      wdr1 = FactoryGirl.create(:purchase, item: wooden_pieces, quantity: Populator::QUANTITIES.sample, date: 24.months.ago.to_date)
      wdp2_m = FactoryGirl.create(:item_price, item: wooden_pieces, price: 6.25, category: 'manufacturer', start_date: 12.months.ago.to_date)
      wdp2_w = FactoryGirl.create(:item_price, item: wooden_pieces, price: 9.95, category: 'wholesale', start_date: 12.months.ago.to_date)
      wdr1 = FactoryGirl.create(:purchase, item: wooden_pieces, quantity: Populator::QUANTITIES.sample, date: 12.months.ago.to_date)
      wdp3_m = FactoryGirl.create(:item_price, item: wooden_pieces, price: 7.50, category: 'manufacturer', start_date: 12.months.ago.to_date)
      wdp3_w = FactoryGirl.create(:item_price, item: wooden_pieces, price: 13.95, category: 'wholesale', start_date: 12.months.ago.to_date)
      wdr1 = FactoryGirl.create(:purchase, item: wooden_pieces, quantity: Populator::QUANTITIES.sample, date: 6.months.ago.to_date)
    end
    
    def get_new_prices(old_price)
      m_price = old_price + Populator::PRICE_INCREMENTS.sample
      w_price = m_price * Populator::MARKUPS.sample
      [m_price,w_price]
    end
  end
end