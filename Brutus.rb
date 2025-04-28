class AdventureGame
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
    puts "*You grab his hand and pull yourself up*"
    sleep 4
    puts "My name is #{@playername}."
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
      puts "#{@playername}, huh? Strong name. Don't worry, I've been on more battlefields than you can count. I'll get you out of here."
    when "J"
      puts "#{@playername}, huh? An honorable name. I can tell you'll be great. Don't worry, I've been on more battlefields than you can count. I'll get you out of here."
    when "H"
      puts "#{@playername}, huh? A name of vice. Don't worry, I've been on more battlefields than you can count. I'll get you out of here."
    when "A"
      puts "#{@playername}, huh? A wise name. Don't worry, I've been on more battlefields than you can count. I'll get you out of here."
    when "N"
      puts "#{@playername}, huh? An interesting name. Don't worry, I've been on more battlefields than you can count. I'll get you out of here."
    else
      puts "#{@playername}, huh? Don't worry, I've been on more battlefields than you can count. I'll get you out of here."
    end
  end

  def introduction_dialogue
    sleep 4
    puts "\nWho am I? The name's Robbert, a mercenary, nice to meet'cha."
    sleep 4
    puts "Robbert: By the way, how'd you get in this mess? How old are you even?"
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
      puts "#{@playername}: I'm twelve. Both of my parents died from a massive boulder that fell from the sky when the invasion began."
      @game_state[:robert_trust] += 2
      @game_state[:boulder_event] = true
      sleep 4
    when 2
      puts "#{@playername}: I'm... sixteen. I got separated from my unit."
      @game_state[:robert_trust] -= 1
      sleep 4
    else
      puts "#{@playername}: ..."
      puts "Robbert: Tough kid, huh? Fair enough."
      sleep 4
    end
    
    sleep 4
    puts "Robbert: ...My condolences. Then again, you're probably not the only one."
    sleep 4
    puts "Robbert: Wouldn't surprise me if the churches were working their asses off right now."
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
        puts "Robbert puts a firm hand on your shoulder: 'We'll make them pay for this.'"
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
    puts "Thanks for playing, #{@playername}."
  end

  def move_to(direction)
    case [@current_room, direction]
    when [:battlefield, "toward"], [:battlefield, "fighting"]
      puts "You move toward the sounds of clashing steel..."
      initiate_combat("stragglers")
    when [:boulder_site, "return"]
      @current_room = :battlefield
      puts "You return to the main battlefield."
    else
      puts "You can't go that way."
    end
  end

  def handle_dialogue(topic)
    case topic.downcase
    when "invasion"
      puts "Robbert: The Eastern Empire struck at dawn with those damned sky-boulders first."
      puts "Never seen anything like it. Took out half the noble houses before the fighting even started."
    when "parents"
      if @game_state[:found_parents]
        puts "Robbert: Your parents... they were targeted specifically. This was no random attack."
      else
        puts "Robbert: We'll find them, kid. But first we need to survive."
      end
    else
      puts "Robbert: Not now, kid. Stay focused."
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
    end
    puts "Time passes... It's now #{@time}."
  end

  def initiate_combat(enemy)
    puts "\nYou encounter #{enemy}! Battle begins!"
    # Your combat system would trigger here
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
      else
        puts "You use the #{item}, but nothing happens."
      end
    else
      puts "You don't have that item."
    end
  end

  def equip_weapon(item)
    weapons = ['spear', 'sword']
    if @player_inventory.include?(item)
      case item
      when weapons.include?(item)
        puts "You equip the #{item}."
      end
    end
    puts "I can't equip that."
  end

  def take_item(item)
    case [@current_room, item]
    when [:battlefield, 'sword']
      @player_inventory << 'sword'
      puts "You take the Dulled sword."
    when [:battlefield, 'spear']
      @player_inventory << 'spear'
      puts "You take the spear."
    else
      puts "I don't see that here."
    end
  end


  def show_stats
    puts "#{@playername}, Level #{@level}"
    puts "Strength: #{@strength}"
    puts "Weapon: #{current_weapon[:name]} (#{current_weapon[:damage]} damage)"
    puts "Robert's Trust: #{@game_state[:robert_trust]}"
  end

  def current_weapon
    @player_inventory.include?("sword") ? {name: "Sword", damage: 8} : {name: "Fists", damage: 3}
  end

  def show_help
    puts "Available commands:"
    puts "look - Describe current location"
    puts "move [direction] - Move to new area"
    puts "search - Look for items"
    puts "talk [topic] - Ask Robbert about something"
    puts "attack - Fight enemies"
    puts "wait - Pass time"
    puts "stats - Show your status"
    puts "help - Show this menu"
    puts "quit - End the game"
  end
end

# Start the game
game = AdventureGame.new
game.start