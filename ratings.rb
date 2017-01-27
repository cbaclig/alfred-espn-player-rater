require 'uri'
require 'open-uri'
require 'nokogiri'
require 'json'

name = ARGV[0]

SPLITS = [
  { name: 'Last 7 days', splitTypeId: 1 },
  { name: 'Last 14 days', splitTypeId: 2 },
  { name: 'Last 30 days', splitTypeId: 3 },
  { name: 'Season', splitTypeId: 0 },
]

# E.g. http://games.espn.com/fba/playerrater?search=Stephen%20Curry
ESPN_FBA_PLAYER_RATER_URL='http://games.espn.com/fba/playerrater'


items = SPLITS.map do |split|
  uri = URI.parse(ESPN_FBA_PLAYER_RATER_URL)
  uri.query = URI.encode_www_form(search: name, splitTypeId: split[:splitTypeId])
  
  doc = Nokogiri::HTML(open(uri.to_s))
  
  subhead = doc.css('#playertable_0 .playerTableBgRowSubhead .playertableData:not(:first-child)')
  stats_row = doc.css('#playertable_0 .pncPlayerRow .playertableData:not(:first-child)')

  subhead.pop
  total_stat = stats_row.pop.text
  title_string = "#{split[:name]}: #{total_stat}"
    
  stats_string = subhead.each_with_index.map do |sub, i|
    "#{sub.text[0,2]}: #{stats_row[i].text}"
  end.join(', ')
  
  {
    title: title_string,
    subtitle: stats_string,
    autocomplete: split[:name],
    arg: uri.to_s
  }
end

puts ({ items: items }).to_json