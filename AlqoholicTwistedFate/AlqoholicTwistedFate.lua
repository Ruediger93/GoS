class "AlqoholicTwistedFate"

local _pickingCard = false
local _currentCard
local _card

function AlqoholicTwistedFate:__init()
	if myHero.charName ~= "TwistedFate" then return end
	require('DamageLib')
	PrintChat("[AlqoholicTwistedFate] Initiated")
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add('Tick', function() self:Tick() end)
	Callback.Add('Draw', function() self:Draw() end)
end

function AlqoholicTwistedFate:LoadSpells()
	Q = {Range = 1450, Delay = 0.25, Radius = 40, Speed = 1000}
	PrintChat("[AlqoholicTwistedFate] Spells Loaded")
end

function AlqoholicTwistedFate:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "AlqoholicTwistedFate", name = "Alqohol - AlqoholicTwistedFate"})

	--[[Combo]]
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	self.Menu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
	self.Menu.Combo:MenuElement({id = "ComboW", name = "Use W", value = true})
	self.Menu.Combo:MenuElement({id = "GoldWhenUlt", name = "Pick Gold on Ult", value = true})
	self.Menu.Combo:MenuElement({id = "UltKey", name = "Ultimate Key", key = 82})

	--[[Harass]]
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
	self.Menu.Harass:MenuElement({id = "HarassQ", name = "Use Q", value = true})
	self.Menu.Harass:MenuElement({id = "HarassMana", name = "Min. Mana", value = 40, min = 0, max = 100})

	--[[Farm]]
	self.Menu:MenuElement({type = MENU, id = "Farm", name = "Farm Settings"})
	self.Menu.Farm:MenuElement({id = "FarmQ", name = "Use Q", value = true})
	self.Menu.Farm:MenuElement({id = "FarmW", name = "Use W", value = true})
	self.Menu.Farm:MenuElement({id = "FarmMana", name = "Min. Mana", value = 40, min = 0, max = 100})

	--[[W Mode]]
	self.Menu:MenuElement({type = MENU, id = "WSettings", name = "W Settings"})
	self.Menu.WSettings:MenuElement({id = "ComboCard", name = "Combo Card [?]", drop = {"Gold", "Red", "Blue"}, tooltip = "Will pick this card in Combo"})
	self.Menu.WSettings:MenuElement({id = "HarassCard", name = "Harass Card [?]", drop = {"Red", "Gold", "Blue"}, tooltip = "Will pick this card in Harass"})
	self.Menu.WSettings:MenuElement({id = "FarmCard", name = "Farm Card [?]", drop = {"Red", "Gold", "Blue"}, tooltip = "Will pick this card in Farm"})
	self.Menu.WSettings:MenuElement({type = SPACE, id = "CardSpace", name = "Card Keys"})
	self.Menu.WSettings:MenuElement({id = "GoldKey", name = "Pick Gold Card [?]", key = 71, tooltip = "Tap for Gold"})
	self.Menu.WSettings:MenuElement({id = "RedKey", name = "Pick Red Card [?]", key = 84, tooltip = "Tap for Red"})
	self.Menu.WSettings:MenuElement({id = "BlueKey", name = "Pick Blue Card [?]", key = 69, tooltip = "Tap for Blue"})

	--[[Misc]]
	self.Menu:MenuElement({type = MENU, id = "Misc", name = "Misc Settings"})
	self.Menu.Misc:MenuElement({id = "MaxRange", name = "Max Range Limiter", value = 0.9, min = 0.5, max = 1, step = 0.01})
	self.Menu.Misc:MenuElement({type = SPACE, id = "ToolTip", name = "eg. X = 0.80 (Q.Range = (1150 * 0.80) = 920)"})
	self.Menu.Misc:MenuElement({type = SPACE, id = "TODO", name = "Need things to add - Give feedback."})

	--[[Draw]]
	self.Menu:MenuElement({type = MENU, id = "Draw", name = "Drawing Settings"})
	self.Menu.Draw:MenuElement({id = "DrawReady", name = "Draw Only Ready Spells", value = true})
	self.Menu.Draw:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true})
	self.Menu.Draw:MenuElement({id = "DrawTarget", name = "Draw Target", value = true})

	PrintChat("[AlqoholicTwistedFate] Menu Loaded")
end

function AlqoholicTwistedFate:Tick()

	_currentCard = myHero:GetSpellData(_W).name

	--------- YES I KNOW IT'S A MESS, ONLY WAY I COULD GET IT TO WORK
	if _pickingCard == true and _card == "Gold" then
		if _currentCard == "GoldCardLock" then
			Control.CastSpell(HK_W)
			_pickingCard = false
			_card = ""
		end
	end
	if _pickingCard == true and _card == "Red" then
		if _currentCard == "RedCardLock" then
			Control.CastSpell(HK_W)
			_pickingCard = false
			_card = ""
		end
	end
	if _pickingCard == true and _card == "Blue" then
		if _currentCard == "BlueCardLock" then
			Control.CastSpell(HK_W)
			_pickingCard = false
			_card = ""
		end
	end

	if self.Menu.Combo.GoldWhenUlt:Value() and self.Menu.Combo.UltKey:Value() and self:IsReady(_R) and _pickingCard == false then
		self:PickCard("Gold")
	end

	if self.Menu.WSettings.GoldKey:Value() and _pickingCard == false then
		self:PickCard("Gold")
	end

	if self.Menu.WSettings.RedKey:Value() and _pickingCard == false then
		self:PickCard("Red")
	end

	if self.Menu.WSettings.BlueKey:Value() and _pickingCard == false then
		self:PickCard("Blue")
	end

	local target = self:GetTarget(Q.Range * self.Menu.Misc.MaxRange:Value())

	if self:Mode() == "Combo" then
		self:Combo(target)
	elseif self:Mode() == "Harass" then
		self:Harass(target)
	elseif self:Mode() == "Farm" then
		self:Farm()
	end
end

function AlqoholicTwistedFate:GetTarget(range)
	local target
	for i = 1,Game.HeroCount() do
		local hero = Game.Hero(i)
		if self:IsValidTarget(hero, range) and hero.team ~= myHero.team then
      		target = hero
      		break
		end
	end
	return target
end

function AlqoholicTwistedFate:GetFarmTarget(range)
	local target
	for j = 1,Game.MinionCount() do
		local minion = Game.Minion(j)
		if self:IsValidTarget(minion, range) and minion.team ~= myHero.team then
      		target = minion
      		break
		end
	end
	return target
end

function AlqoholicTwistedFate:Combo(target)
	if self.Menu.Combo.ComboQ:Value() and self:CanCast(_Q) and self:IsValidTarget(target, (Q.Range * self.Menu.Misc.MaxRange:Value())) then
		self:CastQ(target)

	elseif self.Menu.Combo.ComboW:Value() and self:CanCast(_W) and _pickingCard == false and self:IsValidTarget(target, myHero.range) then

		local card
		if self.Menu.WSettings.ComboCard:Value() == 1 then
			card = "Gold"
		elseif self.Menu.WSettings.ComboCard:Value() == 2 then
			card = "Red"
		elseif self.Menu.WSettings.ComboCard:Value() == 3 then
			card = "Blue"
		end

		self:PickCard(card)
	end
end

function AlqoholicTwistedFate:Harass(target)
	if (myHero.mana/myHero.maxMana >= self.Menu.Harass.HarassMana:Value()/100) then
		if self.Menu.Harass.HarassQ:Value() and self:CanCast(_Q) and self:IsValidTarget(target, (Q.Range * self.Menu.Misc.MaxRange:Value())) then
			self:CastQ(target)

		elseif self.Menu.Harass.HarassW:Value() and self:CanCast(_W) and _pickingCard == false and self:IsValidTarget(target, myHero.range) then
			
			local card
			if self.Menu.WSettings.HarassCard:Value() == 1 then
				card = "Red"
			elseif self.Menu.WSettings.HarassCard:Value() == 2 then
				card = "Gold"
			elseif self.Menu.WSettings.HarassCard:Value() == 3 then
				card = "Blue"
			end

			self:PickCard(card)

		end
	end
end

function AlqoholicTwistedFate:Farm()
	if (myHero.mana/myHero.maxMana >= self.Menu.Harass.HarassMana:Value()/100) then
		local minion = self:GetFarmTarget(Q.Range * self.Menu.Misc.MaxRange:Value())

		if self.Menu.Farm.FarmQ:Value() and self:CanCast(_Q) and self:IsValidTarget(minion, (Q.Range * self.Menu.Misc.MaxRange:Value())) then
			self:CastQ(minion)

		elseif self.Menu.Farm.FarmW:Value() and self:CanCast(_W) and _pickingCard == false and self:IsValidTarget(target, myHero.range) then

			local card
			if self.Menu.WSettings.HarassCard:Value() == 1 then
				card = "Red"
			elseif self.Menu.WSettings.HarassCard:Value() == 2 then
				card = "Gold"
			elseif self.Menu.WSettings.HarassCard:Value() == 3 then
				card = "Blue"
			end

			self:PickCard(card)
			
		end
	end
end

function AlqoholicTwistedFate:PickCard(card)
	if self:IsReady(_W) and myHero:GetSpellData(_W).name == "PickACard" then
		Control.CastSpell(HK_W)
		PrintChat("Picking " .. card .. " Card")
		_pickingCard = true
		_card = card
	end
end

function AlqoholicTwistedFate:CastQ(target)
	if target then
		for i=1,target.buffCount do
			if target:GetBuff(i).type == 5 then
				local castPos = target:GetPrediction(Q.Speed, Q.Delay)
				Control.CastSpell(HK_Q, castPos)
				break
			end
		end
	end
end

function AlqoholicTwistedFate:Draw()
	if myHero.dead then return end

	if self.Menu.Draw.DrawReady:Value() then
		if self:IsReady(_Q) and self.Menu.Draw.DrawQ:Value() then
			Draw.Circle(myHero.pos,Q.Range * self.Menu.Misc.MaxRange:Value(),1,Draw.Color(255, 255, 255, 255))
		end
		elseif self.Menu.Draw.DrawQ:Value() then
			Draw.Circle(myHero.pos,Q.Range * self.Menu.Misc.MaxRange:Value(),1,Draw.Color(255, 255, 255, 255))
	end
    if self.Menu.Draw.DrawTarget:Value() then
	    local drawTarget = self:GetTarget(Q.Range)
	    if drawTarget then
		    Draw.Circle(drawTarget.pos,80,3,Draw.Color(255, 255, 0, 0))
	    end
    end
end

function AlqoholicTwistedFate:Mode()
	if Orbwalker["Combo"].__active then
		return "Combo"
	elseif Orbwalker["Harass"].__active then
		return "Harass"
	elseif Orbwalker["Farm"].__active then
		return "Farm"
	elseif Orbwalker["LastHit"].__active then
		return "LastHit"
	end
	return ""
end

function AlqoholicTwistedFate:GetPercentHP(unit)
	return 100 * unit.health / unit.maxHealth
end

function AlqoholicTwistedFate:GetPercentMP(unit)
	return 100 * unit.mana / unit.maxMana
end

function AlqoholicTwistedFate:HasBuff(unit, buffname)
	for K, Buff in pairs(self:GetBuffs(unit)) do
		if Buff.name:lower() == buffname:lower() then
			return true
		end
	end
	return false
end

function AlqoholicTwistedFate:GetBuffs(unit)
	self.T = {}
	for i = 0, unit.buffCount do
		local Buff = unit:GetBuff(i)
		if Buff.count > 0 then
			table.insert(self.T, Buff)
		end
	end
	return self.T
end

function AlqoholicTwistedFate:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function AlqoholicTwistedFate:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function AlqoholicTwistedFate:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function AlqoholicTwistedFate:IsValidTarget(obj, spellRange)
	return obj ~= nil and obj.valid and obj.visible and not obj.dead and obj.isTargetable and obj.distance <= spellRange
end

function OnLoad()
	AlqoholicTwistedFate()
end