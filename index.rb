require 'net/http'
require 'json'

def calculate_score(pokemon)
  score = pokemon['moves'].count
  score
end

def battle(pokemon1, pokemon2)
  score1 = (pokemon1['stats'][1]['base_stat'] - pokemon1['stats'][2]['base_stat']) + calculate_score(pokemon1)
  score2 = (pokemon2['stats'][1]['base_stat'] - pokemon2['stats'][2]['base_stat']) + calculate_score(pokemon2)

  if score1 > score2
    return pokemon1
  elsif score1 < score2
    return pokemon2
  else
    return pokemon1['id'] > pokemon2['id'] ? pokemon1 : pokemon2
  end
end

def fetch_pokemon(id)
  url = URI.parse("https://pokeapi.co/api/v2/pokemon/#{id}/")
  response = Net::HTTP.get_response(url)
  JSON.parse(response.body)
end

def simulate_tournament(ids)
  round = 1
  remaining_pokemon = ids.dup

  while remaining_pokemon.length > 1
    winners = []

    puts "Ronda #{round}:"

    remaining_pokemon.each_slice(2) do |pair|
      pokemon1 = fetch_pokemon(pair[0])
      pokemon2 = fetch_pokemon(pair[1])
      winner = battle(pokemon1, pokemon2)

      winners << winner

      puts "#{pokemon1['name'].capitalize} (#{pokemon1['id']}) vs #{pokemon2['name'].capitalize} (#{pokemon2['id']})"
      puts "Ganador: #{winner['name'].capitalize} (#{winner['id']})"
      puts ""
    end

    remaining_pokemon = winners.map { |pokemon| pokemon['id'] }
    round += 1
  end

  champion = fetch_pokemon(remaining_pokemon[0])
  puts "Campeón del torneo: #{champion['name'].capitalize} (#{champion['id']})"
end

# Cargar los IDs de los Pokémon desde el archivo ids.json
ids_json = File.read('ids.json')
ids = JSON.parse(ids_json)

simulate_tournament(ids)
