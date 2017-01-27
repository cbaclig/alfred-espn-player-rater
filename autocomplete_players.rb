require 'uri'
require 'open-uri'
require 'nokogiri'
require 'json'

query = ARGV[0]

# E.g. http://games.espn.com/fba/playerrater?search=Stephen%20Curry
ESPN_FBA_PLAYER_RATER_URL='http://games.espn.com/fba/playerrater'

uri = URI.parse(ESPN_FBA_PLAYER_RATER_URL)
uri.query = URI.encode_www_form("search" => query)

doc = Nokogiri::HTML(open(uri.to_s))

nodes = doc.css('#playertable_0 .playertablePlayerName a:first-child')

if nodes.empty?
  items = [{ 
    uid: 'none', 
    valid: false, 
    title: "No players found for '#{query}'" 
  }]
else
  items = nodes.map do |node|
    name = node.text
    team_and_pos =  node.next.text[2..-1]
    
    
    {
      uid: node.text,
      subtitle: team_and_pos,
      title: node.text,
      autocomplete: node.text,
      arg: node.text
    }
  end
end

puts ({ items: items }).to_json