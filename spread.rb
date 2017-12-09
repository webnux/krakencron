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

total_cash = wallet_euro + wallet_xbt*last
total_xbt = wallet_xbt + wallet_euro/last
position_rate_euro = total_cash / 10
position_rate_xbt = (total_cash/last) / 10

buy_at = last * (1-0.25/100)
sell_at = last * (1+0.25/100)


if wallet_euro > total_cash/3
  if position_rate_euro <= wallet_euro
    volume = position_rate_euro/last
    volume = volume.floor2(4)
  else
    volume = wallet_euro/last
    volume = volume.floor2(4)
  end
  opts = {pair: 'XBTEUR',type: 'buy',ordertype: 'limit', price: buy_at.round(1), volume: volume}
  client.private.add_order(opts)
  puts opts
else
  puts "No cash to buy bitcoins..."
end

if wallet_xbt > total_xbt/3
  if position_rate_xbt <= wallet_xbt
    volume = position_rate_xbt
    volume = volume.floor2(4)
  else
    volume = wallet_xbt
    volume = volume.floor2(4)
  end
  opts = {pair: 'XBTEUR',type: 'sell',ordertype: 'limit', price: sell_at.round(1), volume: volume}
  client.private.add_order(opts)
  puts opts
else
  puts "No bitcoin to sell..."
end

time2 = Time.now
puts "END AT " + time2.inspect
puts "______________________________________________________"
