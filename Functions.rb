

COLORS = {
    red: "\e[31m",
    green: "\e[32m",
    yellow: "\e[33m",
    blue: "\e[34m",
    magenta: "\e[35m",
    cyan: "\e[36m",
    reset: "\e[0m"
  }

def character_creation
  system('cls')
  sleep 1
  puts "???: What's your name, kid?"
  sleep 1
  puts "#{colorize('*He stretches out his war-torn hand.*', :green)}"
  @playername = gets.chomp
  puts "#{colorize('*You grab his hand and pull yourself up*', :green)}"
  sleep 2
  puts "You: My name is #{player_name}."
  sleep 2
  if @playername.length > 10
    puts "What?? That's too long!\nAt least give me a nickname I can use!"
    @playername = gets.chomp
  end

  while @playername.include?("Brutus") || @playername.length >= 10 || @playername.length <= 2 || @playername.include?(' ')
    puts "Stop lying. No parent would name their child that."
    sleep 0.7
    if !@game_state[:name_lie]
      @game_state[:robbert_trust] -= 2
      @game_state[:name_lie] = true
    end
    puts "What's your actual name?"
    @playername = gets.chomp
  end

  firstletter = @playername[0]&.upcase
  case firstletter
  when "S"
    puts "???: #{player_name}, huh? Strong name. Don't worry, I've been on more battlefields than you can count. I'll get you out of here."
  when "G"
    puts "???: #{player_name}, huh..?"
    puts "#{colorize('*He looks at you strangely*', :green)}."
  when "J"
    puts "???: #{player_name}, huh? An honorable name. I can tell you'll be great. Don't worry, I've been on more battlefields than you can count. I'll get you out of here."
  when "H"
    puts "???: #{player_name}, huh? A name of vice. Don't worry, I've been on more battlefields than you can count. I'll get you out of here."
  when "A"
    puts "???: #{player_name}, huh? A wise name. Don't worry, I've been on more battlefields than you can count. I'll get you out of here."
  when "N"
    puts "???: #{player_name}, huh? An interesting name. Don't worry, I've been on more battlefields than you can count. I'll get you out of here."
  when "R"
    puts "???: #{player_name}, huh? Peculiar name. Don't worry, I've been on more battlefields than you can count. I'll get you out of here."
  when "X"
    puts "???: #{player_name}..? Fascinating name. 'X' just so happens to be my favorite letter. I can tell we'll get along well."
  else
    puts "???: #{player_name}, huh? Don't worry, I've been on more battlefields than you can count. I'll get you out of here."
  end
end

def initiate_combat(enemy)
  nevermind = ["no", "nevermind", "stop", "exit", "quit"]
  
  if nevermind.include?(enemy) || !@enemies.key?(enemy.downcase)
    return false
  end
  
  enemy_key = enemy.downcase  
  puts "\nYou encounter #{enemy}! Battle begins!"
  @game_state[:next_to_robbert] = false
  enemy_stats = @enemies[enemy_key]
  enemy_hp = enemy_stats[:hp]
  
  while enemy_hp > 0
    puts "\nEnemy HP: #{enemy_hp}"
    puts "Your HP: #{@health}"
    puts "\nWhat will you do?"
    puts "1. Attack"
    puts "2. Run"
    print "> "
    choice = gets.strip.to_s.downcase
    
    case choice
    when "1", "attack"
      puts ""
      player_damage = current_weapon[:damage] + rand(1..3)
      puts "You attack with your #{current_weapon[:name]} and deal #{player_damage} damage!"
      enemy_hp -= player_damage
      
      if enemy_hp <= 0
        puts "You defeated the #{enemy}!"
        gain_experience(enemy_stats[:xp])
        loot_chance(enemy)
        @game_state[:next_to_robbert] = true
        break
      end
      
      enemy_damage = enemy_stats[:damage] + rand(0..2)
      puts "The #{enemy} attacks you for #{enemy_damage} damage!"
      @health -= enemy_damage
      
      if @health <= 0
        puts "You have been defeated..."
        @game_over = true
        break
      end
    when "2", "run"
      escape_chance = rand(1..10)
      if escape_chance > 5
        puts "You managed to escape!"
        break
      else
        puts "You couldn't escape!"
        enemy_damage = enemy_stats[:damage] + rand(0..2)
        puts "The #{enemy} attacks you for #{enemy_damage} damage!"
        @health -= enemy_damage
        
        if @health <= 0
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
    if chance > 7
      puts "You found some bandages!"
      @player_inventory << "bandages"
    end
  when "imperial_scout"
    if chance > 5 && !@player_inventory.include?("spear")
      puts "You found an Imperial Spear!"
      @player_inventory << "spear"
    end
  when "mercenary"
    if chance > 3
      roll = rand(1..3)
      if roll == 1 && !@player_inventory.include?("Iron Helmet")
        puts "You found an iron helmet!"
        @player_inventory << "Iron Helmet"
      else 
        roll = rand(2..3)
      end
      if roll == 2 && !@player_inventory.include?("Iron Chestplate")
        puts "You found an iron chestplate!"
        @player_inventory << "Iron Chestplate"
      else
        roll = 3
      end
      if roll == 3 && !@player_inventory.include?("Iron Leggings")
        puts "You found iron leggings!"
        @player_inventory << "Iron Leggings"
      end
      if @player_inventory.include?("Iron Helmet", "Iron Chestplate", "Iron Leggings")
        puts "Nothing worth taking."
      end
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
  @health += 3
  @experience = 0
  puts "You leveled up! You are now level #{@level}!"
  puts "Your health increased to #{@health}!"
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
      puts "A finely crafted spear glimmers even in the darkest depths."
    when 'bandages'
      heal_amount = rand(3..5)
      @health += heal_amount
      @player_inventory.delete('bandages')
      puts "You use the bandages to heal #{heal_amount} health. Your health is now #{@health}."
    else
      puts "You use the #{item}, but nothing happens."
    end
  else
    puts "You don't have that item."
  end
end

def equip(item)
  weapons = ['spear', 'sword', 'fist']
  armor = ['Iron Helmet', 'Iron Chestplate', 'Iron Leggings']
  if @player_inventory.include?(item) && weapons.include?(item)
    puts "You equip the #{item}."
    @equipped_weapon = item
  elsif @player_inventory.include?(item) && armor.include?(item)
    puts "You equip the #{item}."
    if item == 'Iron Helmet' && @game_state[:equipped_helmet] == false
      @game_state[:equipped_helmet] = true
      @health += 3
    elsif item == 'Iron Chestplate' && @game_state[:equipped_chestplate] == false
      @game_state[:equipped_chestplate] = true
      @health += 5
    elsif item == 'Iron Leggings' && @game_state[:equipped_leggings] == false
      @game_state[:equipped_leggings] = true
      @health += 4
    end
  elsif item == "fist"
    puts "#{colorize('*You throw your weapon to the ground, now armed and dangerous.*', :green)}"
  else
    puts "You can't equip that."
  end
end

def unequip(item)
  weapons = ['spear', 'sword', 'fist']
  armor = ['Iron Helmet', 'Iron Chestplate', 'Iron Leggings']
  if @player_inventory.include?(item) && weapons.include?(item)
    puts "You unequip the #{item}."
    @equipped_weapon = 'fist'
  elsif @player_inventory.include?(item) && armor.include?(item)
    puts "You unequip the #{item}."
    if item == 'Iron Helmet' && @game_state[:equipped_helmet] == true
      @game_state[:equipped_helmet] = false
      @health -= 3
    elsif item == 'Iron Chestplate' && @game_state[:equipped_chestplate] == true
      @game_state[:equipped_chestplate] = false
      @health -= 5
    elsif item == 'Iron Leggings' && @game_state[:equipped_leggings] == true
      @game_state[:equipped_leggings] = false
      @health -= 4
    end
  end
end

def take_item(item)
  case [@current_room, item]
  when [:battlefield, 'sword']
    if !@player_inventory.include?('sword')
      @player_inventory << 'sword'
      puts "You take the sword."
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

def move_to(direction)
  case [@current_room, direction] 
  when [:battlefield, "toward fighting"], [:battlefield, "fighting"], [:battlefield, "toward"]
    if @game_state[:hearing_fighting_battlefield]
    puts "You move toward the sounds of clashing steel..."
    initiate_combat("stragglers")
    else
      "You seem to be a bit out of it."
    end
  
  when [:battlefield, "northeast"], [:battlefield, "ne"], [:battlefield, "boulder"]
    if @game_state[:boulder_event] && !@game_state[:found_parents]
      @current_room = :boulder_site
      puts "You move towards the massive boulder"
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

def describe_room
  case @current_room
  when :battlefield
    puts "\nDay #{@day}, #{@time.capitalize}:  \nA horrendous sight."
    sleep 1.2
    puts "You start to wonder if it was all really worth it in the end."
    sleep 3
    puts "A mercenary is staring at you from the ground."
    sleep 1
    puts "And another."
    sleep 1
    puts "And another."
    sleep 2
    puts "You hold your head high." 
    sleep 1
   
  when :boulder_site
    puts "\n"
    puts "The massive meteor-like boulder dominates the landscape. The boulder, charred and bloody, bears properties of both metal and stone."
    puts "The colossal stone dwarfed the corpses half-buried under the boulder, causing you to miss them at first glance."  
  end
end

def show_stats
  puts "#{player_name}, Level #{@level}"
  puts "health: #{@health}"
  puts "Experience: #{@experience}/#{@level * 10}"
  puts "Weapon: #{current_weapon[:name]} (#{current_weapon[:damage]} damage)"
  puts "robbert's Trust: #{@game_state[:robbert_trust]}"
  puts "Current time: #{@time.capitalize}, Day #{@day}"
end

def current_weapon
  if @player_inventory.include?("spear") && @equipped_weapon == "spear"
    {name: "spear", damage: 10}
  elsif @player_inventory.include?("sword") && (@equipped_weapon == "sword" || @equipped_weapon.nil?)
    {name: "sword", damage: 8}
  else
    {name: "fists", damage: 3}
  end
end

def show_help
  puts "Available commands:"
  puts "look - Describe current location"
  puts "go/move [direction] - Move to new area"
  puts "search - Look for items"
  puts "listen - Listen to your surroundings"
  puts "examine - Examine something interesting"
  puts "approach - Get closer to something"
  puts "talk/ask [topic] - Ask about something"
  puts "take/get [item] - Pick up an item"
  puts "use [item] - Use an item from your inventory"
  puts "equip [item] - Equip an item"
  puts "unequip [item] - Unequip an item"
  puts "inventory/items - Show your inventory"
  puts "attack - Fight enemies"
  puts "wait - Pass time"
  puts "stats - Show your status"
  puts "help - Show this menu"
  puts "quit/exit - End the game"
end

def handle_dialogue(topic)
  case topic.downcase
  when "invasion"
    puts "#{colorize('Robbert', :blue)}: The Eastern Empire started the invasion some months ago."
    puts "No clue what made them so brazen, but I have heard rumors about some weapon"
  when "parents"
    if @game_state[:found_parents]
      puts "#{colorize('Robbert', :blue)}: Your parents... I'm sorry, but you still have to live on."
    else
      puts "#{colorize('Robbert', :blue)}: You need to worry about yourself more. It's all for naught if you don't survive in the end."
    end
  when "#{colorize('Robbert', :blue)}", "Robbert", "yourself"
    if @game_state[:next_to_robbert]
      sleep 0.4
      puts "#{colorize('Robbert', :blue)}: Me? Just a hired sword caught in the wrong place at the wrong time."
      sleep 1
      puts "#{colorize('Robbert', :blue)}: I've fought in three wars before this one, but nothing like... this."
      if @game_state[:yourself_question] == false
        @game_state[:robbert_trust] += 1
        @game_state[:yourself_question] = true
      end
    else
      puts "He's not here..."
    end
  when "boulder", "weapon", "meteor"
    puts "#{colorize('Robbert', :blue)}: Mmm. Word on the street is, Empire's got some new secret weapon."
    puts "#{colorize('Robbert', :blue)}: If it's a weapon potent enough to start war anew, then it really sounds terrifying."
    puts "#{colorize('Robbert', :blue)}: Gives me some creepy vibes."
    @game_state[:boulder_event] = true
  when "time"
    if @game_state[:next_to_robbert]
    timern = "#{@thehour}:#{@theminute}"
    print "#{colorize('Robbert', :blue)}: It's currently #{colorize(timern, :cyan)}."
    else
      puts "#{player_name}: Oh yeah, we split up."
    end
  else
    puts "#{colorize('Robbert', :blue)}: What's up? (boulder/yourself/invasion/parents/time)."
  end
end

def handle_special_commands(input)
  case [@current_room, input]
  when [:battlefield, "search"]
    puts "You find a discarded sword still in good condition."
    @player_inventory << "sword" unless @player_inventory.include?("sword")
    return true
  when [:boulder_site], "search"
    puts "You pick up the blood-rusted crest."
    @player_inventory << "Family Crest" unless @player_inventory.include?("Family Crest")
    @game_state[:found_parents] = true
    return true
  when [:battlefield, "examine"]
      puts "\nThere's a massive boulder to the northeast."
      puts "You see lives ending." 
      puts "Violence in all directions.\n"
      @game_state[:hearing_fighting_battlefield] = true
      @game_state[:boulder_event] = true
      return true
    
  when [:battlefield, "listen"]
    @game_state[:hearing_fighting_battlefield] = true
    puts "Screams by children of war echo in your head."
    sleep 1
    puts "A certain sound takes priority over the others."
    sleep 1
    puts "Turning your head towards their fight, you observe as if in pain."
  when [:boulder_site, "listen"]
    puts "It's eerily silent."
  when [:battlefield, "approach"]
    puts "There's nothing to approach."
  when [:boulder_site, "approach"]
    unless @game_state[:found_parents]
      puts "As you get closer, your heart sinks."
      sleep 1
      puts "A noble crest glints in the dim light."
      sleep 1
      @game_state[:found_parents] = true
      @game_state[:robbert_trust] += 5
      @game_state[:next_to_robbert] = true
      puts "#{colorize('Robbert', :blue)}: What's this?"
      sleep 2
      puts "#{colorize(player_name, :yellow)}: ..My family crest."
      sleep 1
      puts "#{colorize('Robbert', :blue)}: ..My condolences."
      return true
    end
  end
  false
end


def player_name
  colorize(@playername.capitalize, :yellow)
end

def colorize(text, color)
  "#{COLORS[color]}#{text}#{COLORS[:reset]}"
end
