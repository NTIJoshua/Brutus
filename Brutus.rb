class AdventureGame
  COLORS = {
    red: "\e[31m",
    green: "\e[32m",
    yellow: "\e[33m",
    blue: "\e[34m",
    magenta: "\e[35m",
    cyan: "\e[36m",
    reset: "\e[0m"
  }

  def initialize
    @game_over = false
    @current_room = :battlefield
    @player_inventory = []
    @game_state = {
      robert_trust: 0,
      knows_about_invasion: false,
      found_parents: false,
      boulder_event: false
    }
    @level = 1
    @experience = 0
    @playername = ""
    @strength = rand(5..10)
    @time = "afternoon"
    @day = 1
    @enemies = {
      "stragglers" => { hp: 15, damage: 3, xp: 10 },
      "imperial_scout" => { hp: 20, damage: 5, xp: 15 },
      "mercenary" => { hp: 25, damage: 6, xp: 20 }
    }
  end

  def colorize(text, color)
  "#{COLORS[color]}#{text}#{COLORS[:reset]}"
  end

def player_name
  colorize(@playername, :yellow)
end

  def start
    character_creation
    introduction_dialogue  
    puts "\nType 'help' for a list of commands.\n"
    game_loop
  end

  private

  def character_creation
    puts "What's your name, kid?"
    puts "*He stretches out his war-worn hand.*"
    @playername = gets.chomp
    puts "#{colorize(*'You grab his hand and pull yourself up*', :green)}"
    sleep 4
    puts "My name is #{player_name}."
    sleep 4
    while @playername.length > 10
      puts "What?? That's too long!"
      @playername = gets.chomp
    end

    while @playername.include?("Brutus")
      puts "Stop lying. No parent would name their child that."
      @playername = gets.chomp
    end
    case @playername[0]&.upcase
    when "S"
      puts "#{player_name}, huh? Strong name. Don't worry, I've been on more battlefields than you can count. I'll get you out of here."
    when "J"
      puts "#{player_name}, huh? An honorable name. I can tell you'll be great. Don't worry, I've been on more battlefields than you can count. I'll get you out of here."
    when "H"
      puts "#{player_name}, huh? A name of vice. Don't worry, I've been on more battlefields than you can count. I'll get you out of here."
    when "A"
      puts "#{player_name}, huh? A wise name. Don't worry, I've been on more battlefields than you can count. I'll get you out of here."
    when "N"
      puts "#{player_name}, huh? An interesting name. Don't worry, I've been on more battlefields than you can count. I'll get you out of here."
    else
      puts "#{player_name}, huh? Don't worry, I've been on more battlefields than you can count. I'll get you out of here."
    end
  end

  def introduction_dialogue
    sleep 4
    puts "\nWho am I? The name's #{colorize('Robbert', :blue)}, a mercenary, nice to meet'cha."
    sleep 4
    puts "#{colorize('Robbert', :blue)}: By the way, how'd you get in this mess? How old are you even?"
    sleep 4
    
    # Player's response options
    puts "How do you respond?"
    puts "1. Tell the full truth"
    puts "2. Lie about your age"
    puts "3. Stay silent"
    print "> "
    answer = gets.chomp.to_i

    case answer
    when 1
      puts "#{player_name}: I'm twelve. Both of my parents died from a massive boulder that fell from the sky when the invasion began."
      @game_state[:robert_trust] += 2
      @game_state[:boulder_event] = true
      sleep 4
    when 2
      puts "#{player_name}: I'm... sixteen. I got separated from my unit."
      @game_state[:robert_trust] -= 1
      sleep 4
    else
      puts "#{player_name}: ..."
      puts "#{colorize('Robbert', :blue)}: Tough kid, huh? Fair enough."
      sleep 4
    end
    
    sleep 4
    puts "#{colorize('Robbert', :blue)}: ...My condolences. Then again, you're probably not the only one."
    sleep 4
    puts "#{colorize('Robbert', :blue)}: Wouldn't surprise me if the churches were working their asses off right now."
    sleep 4
    puts "\nThe battlefield stretches before you - smoke rises from distant craters, and the sounds of distant combat echo."
    @game_state[:knows_about_invasion] = true
    sleep 4
    describe_room
  end

  def describe_room
    case @current_room
    when :battlefield
      puts "\nDay #{@day}, #{@time.capitalize}:  \nA horrendous sight."
      puts "You start to wonder if it was all really worth it in the end."
      puts "A mercenary is staring at you from the ground."
      puts "And another."
      puts "And another."
      puts "You hold your head high." 
     
      
      if @game_state[:boulder_event] && !@game_state[:found_parents]
        puts "There's a massive, unnatural-looking boulder to the northeast with something glinting nearby."
      end
    when :boulder_site
      puts "\nThe Skyfall Impact Site"
      puts "The massive meteor-like boulder dominates the landscape. Its surface is unnaturally smooth."
      puts "Near its base, you spot two figures in noble garb - unmoving."  
    end
  end

  def handle_special_commands(input)
    case [@current_room, input]
    when [:battlefield, "search"]
      puts "You find a discarded sword still in good condition."
      @player_inventory << "sword" unless @player_inventory.include?("sword")
      return true
      
    when [:battlefield, "examine"]
      if @game_state[:boulder_event]
        @current_room = :boulder_site
        puts "You approach the massive boulder that fell from the sky..."
        return true
      end
    when [:boulder_site, "approach"]
      unless @game_state[:found_parents]
        puts "As you get closer, your heart sinks - it's your parents."
        sleep 1
        puts "Their noble crest, the same as your pendant, glints in the dim light."
        @game_state[:found_parents] = true
        @game_state[:robert_trust] += 5
        puts "#{colorize('Robbert', :blue)} puts a firm hand on your shoulder: 'We'll make them pay for this.'"
        return true
      end
    end
    false
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
        equip_weapon(item)
      when 'inventory', 'items'
        show_inventory
      when 'attack'
        target = params.join(' ')
        combat(target)
      when 'stats'
        show_stats
      when 'wait'
        advance_time
      when 'help'
        show_help
      when 'quit', 'exit'
        @game_over = true
      else
        puts "I don't understand that command."
      end
    end
    puts "Thanks for playing, #{player_name}."
  end

  def move_to(direction)
    case [@current_room, direction]
    when [:battlefield, "toward"], [:battlefield, "fighting"]
      puts "You move toward the sounds of clashing steel..."
      initiate_combat("stragglers")
    when [:battlefield, "northeast"], [:battlefield, "ne"]
      if @game_state[:boulder_event] && !@game_state[:found_parents]
        @current_room = :boulder_site
        puts "You approach the massive boulder that fell from the sky..."
      else
        puts "You don't see anything interesting in that direction."
      end
    when [:boulder_site, "return"], [:boulder_site, "back"], [:boulder_site, "battlefield"]
      @current_room = :battlefield
      puts "You return to the main battlefield."
    else
      puts "You can't go that way."
    end
  end

  def handle_dialogue(topic)
    case topic.downcase
    when "invasion"
      puts "#{colorize('Robbert', :blue)}: The Eastern Empire struck at dawn with those damned sky-boulders first."
      puts "Never seen anything like it. Took out half the noble houses before the fighting even started."
    when "parents"
      if @game_state[:found_parents]
        puts "#{colorize('Robbert', :blue)}: Your parents... they were targeted specifically. This was no random attack."
      else
        puts "#{colorize('Robbert', :blue)}: We'll find them, kid. But first we need to survive."
      end
    when "#{colorize('Robbert', :blue)}", "robert", "yourself"
      puts "#{colorize('Robbert', :blue)}: Me? Just a hired sword caught in the wrong place at the wrong time."
      puts "I've fought in three wars before this one, but nothing like... this."
      @game_state[:robert_trust] += 1
    when "boulder", "sky-boulder", "meteor"
      if @game_state[:boulder_event]
        puts "#{colorize('Robbert', :blue)}: Those things aren't natural. Empire's got some new weapon."
        puts "They're too smooth, too precise. And they always hit important targets."
      else
        puts "#{colorize('Robbert', :blue)}: What boulder are you talking about?"
      end
    else
      puts "#{colorize('Robbert', :blue)}: Not now, kid. Stay focused."
    end
  end

  def advance_time
    case @time
    when "afternoon" then @time = "evening"
    when "evening" then @time = "night"
    when "night"
      @time = "dawn"
      @day += 1
      puts "A new day breaks over the devastated battlefield..."
    when "dawn" then @time = "morning"
    when "morning" then @time = "afternoon"
    end
    puts "Time passes... It's now #{@time}."
    
    # Random encounter chance
    if rand(1..10) > 7
      enemy_types = ["stragglers", "imperial_scout", "mercenary"]
      enemy = enemy_types.sample
      initiate_combat(enemy)
    end
  end

  def initiate_combat(enemy)
    puts "\nYou encounter #{enemy}! Battle begins!"
    enemy_stats = @enemies[enemy]
    enemy_hp = enemy_stats[:hp]
    
    while enemy_hp > 0
      puts "\nEnemy HP: #{enemy_hp}"
      puts "Your HP: #{@strength}"
      puts "\nWhat will you do?"
      puts "1. Attack"
      puts "2. Run"
      print "> "
      choice = gets.chomp.to_i
      
      case choice
      when 1
        player_damage = current_weapon[:damage] + rand(1..3)
        puts "You attack with your #{current_weapon[:name]} and deal #{player_damage} damage!"
        enemy_hp -= player_damage
        
        if enemy_hp <= 0
          puts "You defeated the #{enemy}!"
          gain_experience(enemy_stats[:xp])
          loot_chance(enemy)
          break
        end
        
        enemy_damage = enemy_stats[:damage] + rand(0..2)
        puts "The #{enemy} attacks you for #{enemy_damage} damage!"
        @strength -= enemy_damage
        
        if @strength <= 0
          puts "You have been defeated..."
          @game_over = true
          break
        end
      when 2
        escape_chance = rand(1..10)
        if escape_chance > 3
          puts "You managed to escape!"
          break
        else
          puts "You couldn't escape!"
          enemy_damage = enemy_stats[:damage] + rand(0..2)
          puts "The #{enemy} attacks you for #{enemy_damage} damage!"
          @strength -= enemy_damage
          
          if @strength <= 0
            puts "You have been defeated..."
            @game_over = true
            break
          end
        end
      else
        puts "Invalid choice!"
      end
    end
  end

  def loot_chance(enemy)
    chance = rand(1..10)
    case enemy
    when "stragglers"
      if chance > 7 && !@player_inventory.include?("bandages")
        puts "You found some bandages!"
        @player_inventory << "bandages"
      end
    when "imperial_scout"
      if chance > 5 && !@player_inventory.include?("spear")
        puts "You found an Imperial Spear!"
        @player_inventory << "spear"
      end
    when "mercenary"
      if chance > 3 && !@player_inventory.include?("pendant")
        puts "You found a noble's pendant!"
        @player_inventory << "pendant"
      end
    end
  end

  def gain_experience(xp)
    @experience += xp
    puts "You gained #{xp} experience points!"
    
    if @experience >= @level * 10
      level_up
    end
  end

  def level_up
    @level += 1
    @strength += 2
    @experience = 0
    puts "You leveled up! You are now level #{@level}!"
    puts "Your strength increased to #{@strength}!"
  end

  def show_inventory
    if @player_inventory.empty?
      puts "Your inventory is empty."
    else
      puts "You are carrying:"
      @player_inventory.each { |item| puts "- #{item}" }
    end
  end

  def use_item(item)
    if @player_inventory.include?(item)
      case item
      when 'sword'
        puts "You take a stance, imagining an enemy. The only thing they fear is you."
      when 'spear'
        puts "The spear was finely crafted, are you capable of using it to its fullest potential?"
      when 'bandages'
        heal_amount = rand(3..5)
        @strength += heal_amount
        @player_inventory.delete('bandages')
        puts "You use the bandages to heal #{heal_amount} health. Your strength is now #{@strength}."
      when 'pendant'
        if @game_state[:found_parents]
          puts "You look at the pendant, matching your parents' crest. A tear rolls down your cheek."
          puts "#{colorize('Robbert', :blue)}: We'll avenge them, I promise you that."
          @game_state[:robert_trust] += 1
        else
          puts "A noble pendant. It seems oddly familiar."
        end
      else
        puts "You use the #{item}, but nothing happens."
      end
    else
      puts "You don't have that item."
    end
  end

  def equip_weapon(item)
    weapons = ['spear', 'sword']
    if @player_inventory.include?(item) && weapons.include?(item)
      puts "You equip the #{item}."
      @equipped_weapon = item
    else
      puts "You can't equip that."
    end
  end

  def take_item(item)
    case [@current_room, item]
    when [:battlefield, 'sword']
      if !@player_inventory.include?('sword')
        @player_inventory << 'sword'
        puts "You take the Dulled sword."
      else
        puts "You already have a sword."
      end
    when [:battlefield, 'spear']
      if !@player_inventory.include?('spear')
        @player_inventory << 'spear'
        puts "You take the spear."
      else
        puts "You already have a spear."
      end
    when [:boulder_site, 'pendant']
      if @game_state[:found_parents] && !@player_inventory.include?('pendant')
        @player_inventory << 'pendant'
        puts "You take your family pendant from your parents' remains."
        puts "#{colorize('Robbert', :blue)} watches silently, his face grim with determination."
      else
        puts "I don't see that here."
      end
    else
      puts "I don't see that here."
    end
  end

  def show_stats
    puts "#{player_name}, Level #{@level}"
    puts "Strength: #{@strength}"
    puts "Experience: #{@experience}/#{@level * 10}"
    puts "Weapon: #{current_weapon[:name]} (#{current_weapon[:damage]} damage)"
    puts "Robert's Trust: #{@game_state[:robert_trust]}"
    puts "Current time: #{@time.capitalize}, Day #{@day}"
  end

  def current_weapon
    if @player_inventory.include?("spear") && @equipped_weapon == "spear"
      {name: "Spear", damage: 10}
    elsif @player_inventory.include?("sword") && (@equipped_weapon == "sword" || @equipped_weapon.nil?)
      {name: "Sword", damage: 8}
    else
      {name: "Fists", damage: 3}
    end
  end

  def show_help
    puts "Available commands:"
    puts "look - Describe current location"
    puts "go/move [direction] - Move to new area"
    puts "search - Look for items"
    puts "examine - Examine something interesting"
    puts "approach - Get closer to something"
    puts "talk/ask [topic] - Ask #{colorize('Robbert', :blue)} about something"
    puts "take/get [item] - Pick up an item"
    puts "use [item] - Use an item from your inventory"
    puts "equip [weapon] - Equip a weapon"
    puts "inventory/items - Show your inventory"
    puts "attack - Fight enemies"
    puts "wait - Pass time"
    puts "stats - Show your status"
    puts "help - Show this menu"
    puts "quit/exit - End the game"
  end
end

# Start the game
game = AdventureGame.new
game.start