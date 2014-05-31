fs = require 'fs'
request = require 'request'
async = require 'async'

months =
	'Jan' : 1
	'Feb' : 2
	'Mar' : 3
	'Apr' : 4
	'May' : 5
	'Jun' : 6
	'Jul' : 7
	'Aug' : 8
	'Sep' : 9
	'Oct' : 10
	'Nov' : 11
	'Dec' : 12

date = new Date().toString().split(' ')
month = months["#{date[1]}"]
day = date[2]
year = date[3]

src = "/Users/jashua/Google Drive/Stocks/symbols/nasdaq_nyse_amex.csv"

symbols = fs.readFileSync(src, 'utf8').split('\r').map((row)->
	row?.split(',')[0]?.split('"')[1]?.split('/')[0]?.replace('^', '-P')
)

async.forEachLimit symbols, 128, ((symbol, next)->
	url = "http://ichart.finance.yahoo.com/table.csv?s=#{symbol}&d=#{month}&e=#{day}&f=#{year}&g=d&a=7&b=19&c=2004&ignore=.csv"
	file = "/Users/jashua/Google Drive/Stocks/prices/daily/#{symbol}.csv"
	res = request.get(url)
	stream = fs.createWriteStream file
	res.on 'error', next
	stream.on 'finish', next
	res.pipe(stream)
	),
	(err)->
		return console.log err if err?
