class GameDataLoader
  # Constants for file paths
  INVENTORY_FILE = "data/inventory.txt"
  STATS_FILE = "data/stats.txt"
  ROOMS_FILE = "data/rooms.txt"
  DIALOGUE_FILE = "data/dialogue.txt"
  ENEMIES_FILE = "data/enemies.txt"
  
  # Load all game data at once
  def self.load_all_data
    {
      inventory_items: load_inventory_items,
      stats: load_stats,
      rooms: load_rooms,
      dialogues: load_dialogues,
      enemies: load_enemies
    }
  end

  # Load inventory items from file
  def self.load_inventory_items
    items = {}
    if File.exist?(INVENTORY_FILE)
      File.readlines(INVENTORY_FILE).each do |line|
        next if line.strip.empty? || line.start_with?('#')
        
        # Expected format: item_id|name|description|type|effect_value
        parts = line.strip.split('|')
        if parts.length >= 5
          item_id = parts[0]
          items[item_id] = {
            name: parts[1],
            description: parts[2],
            type: parts[3],
            effect_value: parts[4].to_i
          }
        end
      end
    end
    items
  end

  # Load player and NPC stats from file
  def self.load_stats
    stats = {}
    if File.exist?(STATS_FILE)
      current_entity = nil
      
      File.readlines(STATS_FILE).each do |line|
        line = line.strip
        next if line.empty? || line.start_with?('#')
        
        if line.start_with?('[') && line.end_with?(']')
          # This is an entity name like [player] or [Robbert]
          current_entity = line[1..-2].downcase
          stats[current_entity] = {}
        elsif current_entity && line.include?(':')
          # This is a stat entry like "strength: 5"
          key, value = line.split(':', 2).map(&:strip)
          stats[current_entity][key.to_sym] = parse_value(value)
        end
      end
    end
    stats
  end

  # Load room descriptions and properties from file
  def self.load_rooms
    rooms = {}
    if File.exist?(ROOMS_FILE)
      current_room = nil
      description = []
      
      File.readlines(ROOMS_FILE).each do |line|
        line = line.strip
        
        if line.start_with?('==') && line.end_with?('==')
          # New room definition
          if current_room
            # Save previous room before starting new one
            rooms[current_room][:description] = description.join("\n") if description.any?
          end
          
          current_room = line.gsub(/==|\s+/, '').downcase.to_sym
          rooms[current_room] = { exits: {}, items: [] }
          description = []
        elsif line.start_with?('exit:') && current_room
          # Room exit definition
          _, direction, destination = line.split(':', 3).map(&:strip)
          rooms[current_room][:exits][direction.downcase.to_sym] = destination.downcase.to_sym
        elsif line.start_with?('item:') && current_room
          # Item in room
          item = line.sub('item:', '').strip
          rooms[current_room][:items] << item
        elsif !line.empty? && !line.start_with?('#') && current_room
          # Description line
          description << line
        end
      end
      
      # Save the last room's description
      if current_room
        rooms[current_room][:description] = description.join("\n") if description.any?
      end
    end
    rooms
  end
  
  # Load dialogue options from file
  def self.load_dialogues
    dialogues = {}
    if File.exist?(DIALOGUE_FILE)
      current_npc = nil
      current_topic = nil
      current_lines = []
      
      File.readlines(DIALOGUE_FILE).each do |line|
        line = line.strip
        next if line.empty? || line.start_with?('#')
        
        if line.start_with?('[') && line.end_with?(']')
          # This is an NPC name like [Robbert]
          save_current_dialogue(dialogues, current_npc, current_topic, current_lines)
          current_npc = line[1..-2].downcase
          dialogues[current_npc] ||= {}
          current_topic = nil
          current_lines = []
        elsif line.start_with?('{') && line.end_with?('}') && current_npc
          # This is a topic like {invasion}
          save_current_dialogue(dialogues, current_npc, current_topic, current_lines)
          current_topic = line[1..-2].downcase
          dialogues[current_npc][current_topic] ||= { lines: [], requirements: {}, effects: {} }
          current_lines = []
        elsif line.start_with?('require:') && current_npc && current_topic
          # Requirement for this dialogue
          _, key, value = line.split(':', 3).map(&:strip)
          dialogues[current_npc][current_topic][:requirements][key.to_sym] = parse_value(value)
        elsif line.start_with?('effect:') && current_npc && current_topic
          # Effect of this dialogue
          _, key, value = line.split(':', 3).map(&:strip)
          dialogues[current_npc][current_topic][:effects][key.to_sym] = parse_value(value)
        elsif current_npc && current_topic
          # Dialogue line
          current_lines << line
        end
      end
      
      # Save the last dialogue
      save_current_dialogue(dialogues, current_npc, current_topic, current_lines)
    end
    dialogues
  end
  
  # Helper method to save dialogue during parsing
  def self.save_current_dialogue(dialogues, npc, topic, lines)
    if npc && topic && lines.any?
      dialogues[npc] ||= {}
      dialogues[npc][topic] ||= { lines: [], requirements: {}, effects: {} }
      dialogues[npc][topic][:lines] = lines
    end
  end
  
  # Load enemy definitions from file
  def self.load_enemies
    enemies = {}
    if File.exist?(ENEMIES_FILE)
      current_enemy = nil
      
      File.readlines(ENEMIES_FILE).each do |line|
        line = line.strip
        next if line.empty? || line.start_with?('#')
        
        if line.start_with?('[') && line.end_with?(']')
          # Enemy name like [stragglers]
          current_enemy = line[1..-2].downcase
          enemies[current_enemy] = {}
        elsif current_enemy && line.include?(':')
          # Property like "hp: 15"
          key, value = line.split(':', 2).map(&:strip)
          
          if key == 'loot'
            # Special handling for loot table
            enemies[current_enemy][:loot] ||= []
            item, chance = value.split(',').map(&:strip)
            enemies[current_enemy][:loot] << {
              item: item,
              chance: chance.to_i
            }
          else
            enemies[current_enemy][key.to_sym] = parse_value(value)
          end
        end
      end
    end
    enemies
  end
  
  # Helper method to parse values of different types
  def self.parse_value(value)
    return true if value.downcase == 'true'
    return false if value.downcase == 'false'
    return value.to_i if value =~ /^\d+$/
    return value.to_f if value =~ /^\d+\.\d+$/
    value # Return as string if no special type
  end
end

# Example usage files
def create_example_files
  FileUtils.mkdir_p('data')
  
  # Inventory items example
  File.open('data/inventory.txt', 'w') do |f|
    f.puts "# Inventory Items Format: item_id|name|description|type|effect_value"
    f.puts "sword|Dulled Sword|A dulled sword found on the battlefield.|weapon|8"
    f.puts "spear|Imperial Spear|A well-crafted spear of the Imperial army.|weapon|10"
    f.puts "bandages|Bandages|Medical bandages that can heal wounds.|healing|4"
    f.puts "pendant|Noble Pendant|A pendant bearing your family crest.|key_item|0"
  end
  
  # Stats example
  File.open('data/stats.txt', 'w') do |f|
    f.puts "# Character Stats"
    f.puts "[player]"
    f.puts "level: 1"
    f.puts "experience_cap: 10"
    f.puts "base_strength: 8"
    
    f.puts "[Robbert]"
    f.puts "base_trust: 0"
    f.puts "max_trust: 10"
  end
  
  # Rooms example
  File.open('data/rooms.txt', 'w') do |f|
    f.puts "# Room Definitions"
    f.puts "==battlefield=="
    f.puts "A horrendous sight."
    f.puts "You start to wonder if it was all really worth it in the end."
    f.puts "A mercenary is staring at you from the ground."
    f.puts "And another."
    f.puts "And another."
    f.puts "You hold your head high."
    f.puts "exit: northeast: boulder_site"
    f.puts "item: sword"
    
    f.puts "==boulder_site=="
    f.puts "The Skyfall Impact Site"
    f.puts "The massive meteor-like boulder dominates the landscape. Its surface is unnaturally smooth."
    f.puts "Near its base, you spot two figures in noble garb - unmoving."
    f.puts "exit: back: battlefield"
    f.puts "item: pendant"
  end
  
  # Dialogue example
  File.open('data/dialogue.txt', 'w') do |f|
    f.puts "# NPC Dialogues"
    f.puts "[Robbert]"
    f.puts "{invasion}"
    f.puts "The Eastern Empire struck at dawn with those damned sky-boulders first."
    f.puts "Never seen anything like it. Took out half the noble houses before the fighting even started."
    f.puts "effect: knows_about_invasion: true"
    
    f.puts "{parents}"
    f.puts "require: found_parents: true"
    f.puts "Your parents... they were targeted specifically. This was no random attack."
    f.puts "effect: Robbert_trust: +1"
    
    f.puts "{parents_default}"
    f.puts "require: found_parents: false"
    f.puts "We'll find them, kid. But first we need to survive."
    
    f.puts "{boulder}"
    f.puts "require: boulder_event: true"
    f.puts "Those things aren't natural. Empire's got some new weapon."
    f.puts "They're too smooth, too precise. And they always hit important targets."
  end
  
  # Enemies example
  File.open('data/enemies.txt', 'w') do |f|
    f.puts "# Enemy Definitions"
    f.puts "[stragglers]"
    f.puts "hp: 15"
    f.puts "damage: 3"
    f.puts "xp: 10"
    f.puts "loot: bandages, 30"
    
    f.puts "[imperial_scout]"
    f.puts "hp: 20"
    f.puts "damage: 5"
    f.puts "xp: 15"
    f.puts "loot: spear, 50"
    
    f.puts "[mercenary]"
    f.puts "hp: 25"
    f.puts "damage: 6"  
    f.puts "xp: 20"
    f.puts "loot: pendant, 70"
  end
end