class QuakeLogParser
    def initialize(log_file)
      @log_file = log_file
    end
  
    def parse
      games = []
      current_game = nil
  
      File.foreach(@log_file) do |line|
        if line.include?("InitGame:")
          current_game = {
            total_kills: 0,
            players: [],
            kills: Hash.new(0),
            kills_by_means: Hash.new(0)
          }
          games << current_game
        elsif line.include?("Kill:")
          parse_kill_line(line, current_game)
        end
      end
  
      games
    end
  
    def generate_reports(games)
      games.each_with_index do |game, index|
        puts "Game #{index + 1}:"
        puts "  Total kills: #{game[:total_kills]}"
        puts "  Players: #{game[:players].join(', ')}"
        puts "  Kills: #{game[:kills]}"
  
        puts "  Kills by Means:"
        game[:kills_by_means].each do |means_of_death, count|
          puts "    #{means_of_death}: #{count}"
        end
  
        puts "\n"
      end
  
      puts "Overall Ranking:"
      generate_overall_ranking(games)
    end
  
    private
  
    def parse_kill_line(line, game)
      parts = line.split(":")
      killer, killed, means_of_death = parts[1].strip, parts[2].strip, parts[3].split(" ")[0].strip
  
      game[:total_kills] += 1
      game[:players] |= [killer, killed]
      game[:kills][killer] += 1 unless killer == "<world>"
      game[:kills][killed] -= 1 unless killed == "<world>"
      game[:kills_by_means][means_of_death] += 1
    end
  
    def generate_overall_ranking(games)
      player_kills = Hash.new(0)
  
      games.each do |game|
        game[:kills].each do |player, kills|
          player_kills[player] += kills
        end
      end
  
      sorted_ranking = player_kills.sort_by { |_, kills| -kills }
  
      sorted_ranking.each_with_index do |(player, kills), index|
        puts "#{index + 1}. #{player}: #{kills} kills"
      end
    end
end
  
  # chamada de arquivo de log externo.

    parser = QuakeLogParser.new("./games.log")
    games = parser.parse
    parser.generate_reports(games)
  