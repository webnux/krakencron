class Float
  def floor2(exp = 0)
   multiplier = 10 ** exp
   ((self * multiplier).floor).to_f/multiplier.to_f
  end
end

time = Time.now
puts "STARTED AT " + time.inspect
puts "______________________________________________________"

require 'kraken_client'
client = KrakenClient.load({base_uri: 'https://api.kraken.com', tier: 3, api_key: '', api_secret: ''})
balance = client.private.balance
wallet_euro = balance["ZEUR"].to_f.floor2(2)
wallet_xbt = balance["XXBT"].to_f
low = client.public.ticker('XXBTZEUR')['XXBTZEUR']['l'][1].to_f.floor2(2)
last = client.public.ticker('XXBTZEUR')['XXBTZEUR']['c'][0].to_f.floor2(2)
high = client.public.ticker('XXBTZEUR')['XXBTZEUR']['h'][1].to_f.floor2(2)
avg = client.public.ticker('XXBTZEUR')['XXBTZEUR']['p'][1].to_f.floor2(2)
risk = 2.0
total_cash = wallet_euro + wallet_xbt*last
position_rate_euro = total_cash / 10
position_rate_xbt = (total_cash/last) / 10
last_order = File.open("bidprice.txt", "r")
last_bidprice = last_order.read.to_f
pv = (last-last_bidprice)/last_bidprice*100

puts balance

if pv > risk
  if wallet_euro > 10
    if position_rate_euro <= wallet_euro
      volume = position_rate_euro/last
      volume = volume.floor2(4)
    else
      volume = wallet_euro/last
      volume = volume.floor2(4)
    end
    opts = {pair: 'XBTEUR',type: 'buy',ordertype: 'market', volume: volume}
    client.private.add_order(opts)
    file = File.open("bidprice.txt","w")
    file.puts last
    puts opts
  else
    file = File.open("bidprice.txt","w")
    file.puts last
    puts "No cash, Bidprice increased to #{last}"
  end
elsif pv < -risk
  if wallet_xbt > 0.02
    if position_rate_xbt <= wallet_xbt
      volume = position_rate_xbt
      volume = volume.floor2(4)
    else
      volume = wallet_xbt
      volume = volume.floor2(4)
    end
    opts = {pair: 'XBTEUR',type: 'sell',ordertype: 'market', volume: volume}
    client.private.add_order(opts)
    file = File.open("bidprice.txt","w")
    file.puts last
    puts opts
  else
    file = File.open("bidprice.txt","w")
    file.puts last
    puts "No bitcoin, Bidprice decreased to #{last}"
  end
end

time2 = Time.now
puts "END AT " + time2.inspect
puts "______________________________________________________"
