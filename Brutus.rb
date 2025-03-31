level = 1
experience = 0

p "What's your name, kid?"
playername = gets.chomp
while playername.length > 20
  p "What??"
  playername = gets.chomp
end
while playername.include?("Brutus")
  p "Stop lying. No parent would name their child that."
  playername = gets.chomp
end

if playername[0] == "S"
p "#{playername}, huh? Strong name. Don't worry, I've been on more battlefields than you can count. I'll get you out of here."
elsif playername[0] == "J"
p "#{playername}, huh? An honorable name. I can tell you'll be great. Don't worry, I've been on more battlefields than you can count. I'll get you out of here."
playername[0] == "H"
p "#{playername}, huh? A name of vice. Don't worry, I've been on more battlefields than you can count. I'll get you out of here."
playername[0] == "A"
p "#{playername}, huh? A wise name. Don't worry, I've been on more battlefields than you can count. I'll get you out of here."
playername[0] == "N"
p "#{playername}, huh? An interesting name. Don't worry, I've been on more battlefields than you can count. I'll get you out of here."
end




p "Who am i? The name's Robbert, a mercenary, nice to meet'cha."
sleep 0.5
p "Robbert: By the way, how'd you get in this mess? How old are you even?"
sleep 0.5
p "#{playername}: I'm twelve. Both of my parents died from a massive boulder that fell from the sky when the invasion began."
sleep 0.5
p "Robbert: ...My condolences. Then again, you're probably not the only one. Wouldn't surprise me if the churches were working their butts off right now."
sleep 0.5


def attackdmg(Weapon, Strength)
  if dodge > accuracy
    dodged = rand(1..3)
    if dodged > 2
      return (Weapon + Strength)/1.521
    end
  end
end