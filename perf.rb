class Float
  def floor2(exp = 0)
   multiplier = 10 ** exp
   ((self * multiplier).floor).to_f/multiplier.to_f
  end
end

require 'kraken_client'

client = KrakenClient.load({base_uri: 'https://api.kraken.com', tier: 3, api_key: '', api_secret: ''})


# permet de recup la balance par devise
balance = client.private.balance

wallet_euro = balance["ZEUR"].to_f.floor2(2)
wallet_xbt = balance["XXBT"].to_f

low = client.public.ticker('XXBTZEUR')['XXBTZEUR']['l'][1].to_f.floor2(2)
last = client.public.ticker('XXBTZEUR')['XXBTZEUR']['c'][0].to_f.floor2(2)
high = client.public.ticker('XXBTZEUR')['XXBTZEUR']['h'][1].to_f.floor2(2)
avg = client.public.ticker('XXBTZEUR')['XXBTZEUR']['p'][1].to_f.floor2(2)


total_cash = wallet_euro + wallet_xbt*last

perf = (total_cash-600)/600*100
perf = perf.round(2)

file = File.open("/var/www/html/index.nginx-debian.html","w")
file.puts "<html><head><title>Kiki's Bitcoin Trading Bot</title></head><body style='background-color:black;'><div style='text-align:center;color:green;font-size:50px;position: absolute;top: 50%;left: 50%;transform: translateX(-50%) translateY(-50%);'>+#{perf}% <br /><span style='font-size:20px;color:white;'>(since 2017/12/03)</span></div></body></html>"
file.close
