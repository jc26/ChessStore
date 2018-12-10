module Populator
  module Boards
    def create_boards_and_prices
      colors = %w[green blue black red]
      vinyl_boards_array = Array.new

      colors.each do |color|
        vinyl_board = FactoryGirl.create(:item, 
          name: "Vinyl Chess Board - #{color.capitalize} & White", 
          color: "#{color}/white",
          picture: "vinyl-chess-board-#{color}.jpg")
        vinyl_boards_array << vinyl_board
      end

      vinyl_boards_array.each do |vb|
        old_price = 1.55
        4.times do |i|
          prices = get_new_prices(old_price)
          month = 25 - 6*i
          new_manf_price = FactoryGirl.create(:item_price, item: vb, price: prices[0], start_date: month.months.ago.to_date, category: 'manufacturer')
          new_whol_price = FactoryGirl.create(:item_price, item: vb, price: prices[1], start_date: month.months.ago.to_date)
          old_price = prices[0]
          FactoryGirl.create(:purchase, item: vb, quantity: Populator::QUANTITIES.sample, date: month.months.ago.to_date)          
        end
      end

      mahogany_board = FactoryGirl.create(:item, 
        name: "Mahogany Wood Chess Board", 
        description: "This attractive and affordable chess board features a classic 1-1/2 inch mahogany border. The squares are 2-1/8 inch and the board is 1/2 inch thick. It is made in Poland of quality manufacturing with alternating Mahogany squares.", 
        color: "brown/tan",
        picture: "mahogany-wood-chess-board.jpg",
        weight: 2.1)
      old_price = 1.55
      5.times do |i|
        prices = get_new_prices(old_price)
        month = 25 - 5*i
        new_manf_price = FactoryGirl.create(:item_price, item: mahogany_board, price: prices[0], start_date: month.months.ago.to_date, category: 'manufacturer')
        new_whol_price = FactoryGirl.create(:item_price, item: mahogany_board, price: prices[1], start_date: month.months.ago.to_date)
        old_price = prices[0]
        FactoryGirl.create(:purchase, item: mahogany_board, quantity: Populator::QUANTITIES.sample, date: month.months.ago.to_date)          
      end  
        
      maple_board    = FactoryGirl.create(:item, 
        name: "Maple Wood Chess Board", 
        description: "This board is composed of alternating 2 1/4 inch maple and walnut squares. It has a beautiful, unique 2 inch maple border with walnut trim around the playing surface for the perfect contrast. It makes an elegant companion to chess pieces with a king base of 1 3/8 inch to 1 3/4 inch (3-3/4 inch king height).  The board is backed with felt so it will not scratch the surface where it sits. It will look great with pieces featuring light or natural wooden tones.", 
        color: "brown/tan",
        weight: 2.2)      
      map1_m = FactoryGirl.create(:item_price, item: maple_board, category: 'manufacturer', price: 39.95, start_date: 12.months.ago.to_date)
      map2_m = FactoryGirl.create(:item_price, item: maple_board, category: 'manufacturer', price: 42.00, start_date: 6.months.ago.to_date)
      map3_m = FactoryGirl.create(:item_price, item: maple_board, category: 'manufacturer', price: 44.95, start_date: 2.weeks.ago.to_date)

      map1_w = FactoryGirl.create(:item_price, item: maple_board, category: 'wholesale', price: 69.95, start_date: 12.months.ago.to_date)
      map2_w = FactoryGirl.create(:item_price, item: maple_board, category: 'wholesale', price: 75.00, start_date: 6.months.ago.to_date)
      map3_w = FactoryGirl.create(:item_price, item: maple_board, category: 'wholesale', price: 79.95, start_date: 2.weeks.ago.to_date)

      rosewood_board  = FactoryGirl.create(:item, 
        name: "Rosewood Chess Board", 
        description: "This beautiful wood chess board is made of maple and rosewood with a very distinct and luxurious grain. The board has a narrow black accent separating the border from the squares, and the rosewood border features a black beveled edge. It makes an outstanding board for chess pieces with a king height of 3 3/4 inches. The board is backed with felt so it will not scratch the surface where it sits.", 
        weight: 2.25,
        color: "brown/tan",
        active: false)
    end
    
    def get_new_prices(old_price)
      m_price = old_price + Populator::PRICE_INCREMENTS.sample
      w_price = m_price * Populator::MARKUPS.sample
      [m_price,w_price]
    end
  end
end