if myHero.charName ~= "Ezreal" then return end

require "DamageLib"

-- Spells
Q = {Delay = 0.25, Radius = 60, Range = 1150, Speed = 2000, Collision = true}
W = {Delay = 0.25, Radius = 80, Range = 1000, Speed = 2000, Collision = false}
R = {Delay = 0.25, Radius = 160, Range = 3000, Speed = 2000, Collision = false}

-- Menu
Menu = MenuElement({type = MENU, id = "AlqoholicEzreal", name = "Alqohol - AlqoholicEzreal", lefticon="https://cdn.discordapp.com/emojis/249237025754972171.png"})

-- [[Keys]]
Menu:MenuElement({type = MENU, id = "Key", name = "Key Settings"})
Menu.Key:MenuElement({id = "ComboKey", name = "Combo Key", key = 32})
Menu.Key:MenuElement({id = "HarassKey", name = "Harass Key", key = 67})
Menu.Key:MenuElement({id = "FarmKey", name = "Farm Key", key = 86})
Menu.Key:MenuElement({id = "LastHitKey", name = "Last Hit Key", key = 88})

-- [[Combo]]
Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
Menu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
Menu.Combo:MenuElement({id = "ComboW", name = "Use W", value = true})
Menu.Combo:MenuElement({id = "ComboR", name = "Use R - DISABLED FOR THE MOMENT", value = true})

-- [[Harass]]
Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
Menu.Harass:MenuElement({id = "HarassQ", name = "Use Q", value = true})
Menu.Harass:MenuElement({id = "HarassW", name = "Use W", value = true})
Menu.Harass:MenuElement({id = "HarassMana", name = "Min. Mana", value = 40, min = 0, max = 100})

-- [[Farm]]
Menu:MenuElement({type = MENU, id = "Farm", name = "Farm Settings"})
Menu.Farm:MenuElement({id = "FarmSpells", name = "Farm Spells", value = true})
Menu.Farm:MenuElement({id = "FarmQ", name = "Use Q", value = true})
Menu.Farm:MenuElement({id = "FarmMana", name = "Min. Mana", value = 40, min = 0, max = 100})

-- [[LastHit]]
Menu:MenuElement({type = MENU, id = "LastHit", name = "Last Hit Settings - WORK IN PROGRESS"})
Menu.LastHit:MenuElement({id = "LastHitQ", name = "Use Q", value = true})
Menu.LastHit:MenuElement({id = "LastHitMana", name = "Min. Mana", value = 40, min = 0, max = 100})

-- [[Misc]]
Menu:MenuElement({type = MENU, id = "Misc", name = "Misc Settings"})
Menu.Misc:MenuElement({id = "MaxRange", name = "Max Range Limiter", value = 0.9, min = 0.5, max = 1, step = 0.01})
Menu.Misc:MenuElement({type = SPACE, id = "ToolTip", name = "eg. X = 0.80 (Q.Range = (1150 * 0.80) = 920)"})

-- [[Draw]]
Menu:MenuElement({type = MENU, id = "Draw", name = "Drawing Settings"})
Menu.Draw:MenuElement({id = "DrawQ", name = "Draw Q", value = true})
Menu.Draw:MenuElement({id = "DrawW", name = "Draw W", value = true})
Menu.Draw:MenuElement({id = "DrawR", name = "Draw R", value = true})
Menu.Draw:MenuElement({id = "DrawTarget", name = "Draw Target", value = true})


-- [Checks]
-- GetTarget - Returns target
function GetTarget(targetRange)
	local result
	for i = 1,Game.HeroCount()  do
		local hero = Game.Hero(i)
		if isValidTarget(hero, targetRange) and hero.team ~= myHero.team then
      		result = hero
      		break
		end
	end
	return result
end

function GetFarmTarget(minionRange)
	local getFarmTarget
	for j = 1,Game.MinionCount()	do
		local minion = Game.Minion(j)
		if isValidTarget(minion, minionRange) and minion.team ~= myHero.team then
      		getFarmTarget = minion
      		break
		end
	end
	return getFarmTarget
end


-- [Events]
-- OnUpdate
Callback.Add('Tick',function()

	if Menu.Key.ComboKey:Value()  then
		if isReady(_Q) and Menu.Combo.ComboQ:Value() then
			local qTarget = GetTarget(Q.Range * Menu.Misc.MaxRange:Value())
			if qTarget and qTarget:GetCollision(Q.Radius, Q.Speed, Q.Delay) == 0 then
				local qPos = qTarget:GetPrediction(Q.Speed, Q.Delay)
				Control.CastSpell(HK_Q, qPos)
			end
		end
		if isReady(_W) and Menu.Combo.ComboW:Value() then
			local wTarget = GetTarget(W.Range * Menu.Misc.MaxRange:Value())
			if wTarget then
				local wPos = wTarget:GetPrediction(W.Speed, W.Delay)
				Control.CastSpell(HK_W, wPos)
			end
		end
		-- if isReady(_R) and Menu.Combo.ComboR:Value() then
		-- 	local rTarget = GetTarget(R.Range)
		-- 	if rTarget then
		-- 		local rPos = rTarget:GetPrediction(R.Speed, R.Delay)
		-- 		if true or true then
		-- 			Control.CastSpell(HK_R, rPos)
		-- 		end
		-- 	end
		-- end
	end

	if Menu.Key.HarassKey:Value() and (myHero.mana/myHero.maxMana >= Menu.Harass.HarassMana:Value()/100) then
		if isReady(_Q) and Menu.Harass.HarassQ:Value() then
			local qTarget = GetTarget(Q.Range * Menu.Misc.MaxRange:Value())
			if qTarget and qTarget:GetCollision(Q.Radius, Q.Speed, Q.Delay) == 0 then
				local qPos = qTarget:GetPrediction(Q.Speed, Q.Delay)
				Control.CastSpell(HK_Q, qPos)
			end
		end
		if isReady(_W) and Menu.Harass.HarassW:Value() then
			local wTarget = GetTarget(W.Range * Menu.Misc.MaxRange:Value())
			if wTarget then
				local wPos = wTarget:GetPrediction(W.Speed, W.Delay)
				Control.CastSpell(HK_W, wPos)
			end
		end
	end

	if Menu.Key.FarmKey:Value() and Menu.Farm.FarmSpells:Value() and (myHero.mana/myHero.maxMana >= Menu.Farm.FarmMana:Value()/100) then
		if isReady(_Q) and Menu.Farm.FarmQ:Value() then
			local qMinion = GetFarmTarget(Q.Range * Menu.Misc.MaxRange:Value())
			if qMinion then
				local qMinPos = qMinion:GetPrediction(Q.Speed, Q.Delay)
				Control.CastSpell(HK_Q, qMinPos)
			end
		end
	end

end)

-- OnLoad
Callback.Add('Load',function()
	PrintChat("Alqoholic Ezreal - Loaded")
end)

-- OnDraw
function OnDraw()
	if myHero.dead then return end

	if Menu.Draw.DrawQ:Value()	then
		Draw.Circle(myHero.pos,Q.Range * Menu.Misc.MaxRange:Value(),1,Draw.Color(255, 255, 255, 255))
	end
	if Menu.Draw.DrawW:Value()	then
		Draw.Circle(myHero.pos,W.Range * Menu.Misc.MaxRange:Value(),1,Draw.Color(255, 255, 255, 255))
	end
	if Menu.Draw.DrawR:Value()	then
		Draw.Circle(myHero.pos,R.Range * Menu.Misc.MaxRange:Value(),1,Draw.Color(255, 255, 255, 255))
	end

    if Menu.Draw.DrawTarget:Value() then
	    local drawTarget = GetTarget(Q.Range)
	    if drawTarget then
		    Draw.Circle(drawTarget.pos,80,3,Draw.Color(255, 255, 0, 0))
	    end
    end
end


-- isReady - Returns bool
function isReady(slot)
	return myHero:GetSpellData(slot).currentCd < 0.099 and myHero:GetSpellData(spellSlot).mana < myHero.mana and and myHero:GetSpellData(spellSlot).level > 0 -- Thanks MeoBeo
end

-- isValidTarget - Returns bool
function isValidTarget(obj, spellRange)
	return obj ~= nil and obj.valid and obj.visible and not obj.dead and obj.isTargetable and obj.distance <= spellRange
end