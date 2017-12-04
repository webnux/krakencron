class Float
  def floor2(exp = 0)
   multiplier = 10 ** exp
   ((self * multiplier).floor).to_f/multiplier.to_f
  end
end

require 'kraken_client'

client = KrakenClient.load({base_uri: 'https://api.kraken.com', tier: 3, api_key: '', api_secret: ''})


puts "______________________________________________________"
puts "______________________________________________________"

time1 = Time.new
puts "Current Time : " + time1.inspect

# permet de recup la balance par devise
balance = client.private.balance

puts balance

puts client.private.open_orders

wallet_euro = balance["ZEUR"].to_f.floor2(2)
wallet_xbt = balance["XXBT"].to_f

low = client.public.ticker('XXBTZEUR')['XXBTZEUR']['l'][1].to_f.floor2(2)
last = client.public.ticker('XXBTZEUR')['XXBTZEUR']['c'][0].to_f.floor2(2)
high = client.public.ticker('XXBTZEUR')['XXBTZEUR']['h'][1].to_f.floor2(2)
avg = client.public.ticker('XXBTZEUR')['XXBTZEUR']['p'][1].to_f.floor2(2)

moving_pv = (high-low)/high*100
buy_pv = moving_pv/3
sell_pv = moving_pv/2
security_pv = 1

if client.private.open_orders["open"].empty? && wallet_euro > 100
  if last < avg
    pv = (avg-last)/last*100
    if pv > security_pv && pv > buy_pv
      volume = wallet_euro/last
      volume = volume.floor2(4)
      opts = {pair: 'XBTEUR',type: 'buy',ordertype: 'market', volume: volume}
      client.private.add_order(opts)
      file = File.open("bidprice.txt","w")
      file.puts last
      file.close
      puts "Achat"
      puts last
      puts avg
      puts opts
    end
  end
end

if client.private.open_orders["open"].empty? && wallet_euro < 100
  file = File.open("bidprice.txt", "r")
  bidprice = file.read
  file.close
  bidprice = bidprice.to_f
  if last > bidprice
    pv = (last-bidprice)/bidprice*100
    if pv > security_pv && pv > sell_pv
      opts = {pair: 'XBTEUR',type: 'sell',ordertype: 'market', volume: wallet_xbt}
      client.private.add_order(opts)
      puts "Vente"
      puts last
      puts avg
      puts opts
    end
  end
end

time2 = Time.now
puts "Current Time : " + time2.inspect

puts "______________________________________________________"
puts "______________________________________________________"