require_relative('Functions.rb')

class AdventureGame
  
  def initialize
    @game_over = false
    @current_room = :battlefield
    @player_inventory = []
    @game_state = {
      robbert_trust: 0,
      knows_about_invasion: false,
      found_parents: false,
      boulder_event: false,
      hearing_fighting_battlefield: false,
      next_to_robbert: true,
      at_battlefield: true,
      equipped_chestplate: false,
      equipped_helmet: false,
      equipped_leggings: false,
      name_lie: false,
      yourself_question: false
    }
    @level = 1
    @experience = 0
    @playername = ""
    @health = rand(5..10)
    @time = "afternoon"
    @day = 1
    @thehour = 13
    @theminute = 10
    @enemies = {
      "stragglers" => { hp: 15, damage: 3, xp: 10 },
      "imperialscout" => { hp: 20, damage: 5, xp: 15 },
      "mercenary" => { hp: 25, damage: 6, xp: 20 }
    }
  end


  def start
    character_creation
    introduction_dialogue  
    puts "\nType 'help' for a list of commands.\n"
    game_loop
  end

  

 

  def introduction_dialogue
    sleep 4
    if @playername[0]&.upcase == "G"
      puts "#{player_name}: ...Who are you?"
    else
      puts "#{player_name}: Who are you?"
    end
  
    puts "\n???: Who am I? The name's #{colorize('Robbert', :blue)}, a mercenary, nice to meet'cha."
    sleep 4
    puts "#{colorize('Robbert', :blue)}: By the way, how'd you get in this mess? How old are you even?"
    sleep 4
    
    # Player's response options
    puts "\nHow do you respond?"
    puts "1. Tell the full truth"
    puts "2. Lie about your age"
    puts "3. Stay silent"
    print "> "
    answer = gets.chomp.to_i

    case answer
    when 1
      puts "#{player_name}: I'm twelve. Both of my parents went missing some days ago."
      @game_state[:robbert_trust] += 2
      sleep 4
    when 2
      puts "#{player_name}: I'm... sixteen. I got separated from my unit."
      @game_state[:robbert_trust] -= 1
      sleep 3
      puts "#{colorize('Robbert', :blue)}: ...My condolences. Then again, you're probably not the only one."
      sleep 3
      puts "#{colorize('Robbert', :blue)}: Wouldn't surprise me if the churches were working their asses off right now."
      sleep 3
    else
      puts "#{player_name}: ..."
      puts "#{colorize('Robbert', :blue)}: Tough kid, eh? Alright then."
      sleep 3
    end
    puts "#{colorize('*You take a look around*', :green)}"
    @game_state[:knows_about_invasion] = true
    sleep 4
    describe_room
  end


  

  def game_loop
    until @game_over
      print "> "
      input = gets.chomp.downcase.strip
      
      next if handle_special_commands(input)
      
      command, *params = input.split
      case command
      when 'look'
        describe_room
      when 'go', 'move'
        direction = params.first
        move_to(direction)
      when 'talk', 'ask'
        topic = params.join(' ')
        handle_dialogue(topic)
      when 'take', 'get'
        item = params.join(' ')
        take_item(item)
      when 'use'
        item = params.join(' ')
        use_item(item)
      when 'equip'
        item = params.join(' ')
        equip(item)
      when 'inventory', 'items'
        show_inventory
      when 'attack'
        enemy = params.join(' ')
        enemy_types = ["Stragglers", "Imperial Scout", "Mercenary"]
        nevermind = ["no", "nevermind", "stop", "quit"]
        if !enemy_types.include?(enemy)
          puts "Who are you attacking?"
          puts "Valid choices:\nStragglers\nMercenary\nImperial Scout"
          print "> "
          enemy = gets.chomp.downcase.strip
          if nevermind.include?(enemy)
            puts "Tragedy averted."
          end
            
        end
        initiate_combat(enemy)
      when 'stats'
        show_stats
      when 'wait'
        advance_time
      when 'unequip'
        item = params.join(' ')
        unequip(item)
      when 'help'
        show_help
      when 'quit', 'exit'
        @game_over = true
      when 'listen'
        ''
      else
        puts "I don't understand that command."
      end
    end
    puts "Thanks for playing, #{player_name}."
  end


  def advance_time
    case @time
    when "afternoon"
      @time = "evening"
      @thehour = 18
    when "evening" 
      @time = "night"
      @thehour = 0
    when "night"
      @time = "morning"
      @thehour = 6
      @day += 1
      puts "A new day breaks over the devastated battlefield..."
    when "morning"
      @time = "afternoon"
      @thehour = 12
    end
    puts "Time passes... It's now #{@time}."
    
    if rand(1..10) > 7
      enemy_types = ["Stragglers", "Imperial Scout", "Mercenary"]
      enemy = enemy_types.sample
      initiate_combat(enemy)
    end
  end


# Start the game
game = AdventureGame.new
game.start
end