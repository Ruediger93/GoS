class "AlqoholicTwistedFate"

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
	self.Menu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true, too})
	self.Menu.Combo:MenuElement({id = "ComboW", name = "Use W", value = true})


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
	self.Menu.WSettings:MenuElement({id = "ComboCard", name = "Combo Card", drop = {"Gold"[, "Red", "Blue"]}})
	self.Menu.WSettings:MenuElement({id = "HarassCard", name = "Harass Card", drop = {"Red"[, "Gold", "Blue"]}})
	self.Menu.WSettings:MenuElement({id = "FarmCard", name = "Farm Card", drop = {"Red"[, "Gold", "Blue"]}})
	self.Menu.WSettings:MenuElement({type = SPACE, id = "CardSpace", name = "Card Keys"})
	self.Menu.WSettings:MenuElement({id = "GoldKey", "Pick Gold Card", key = 71, onclick = self:PickGold()})
	self.Menu.WSettings:MenuElement({id = "RedKey", "Pick Red Card", key = 84, onclick = self:PickRed()})
	self.Menu.WSettings:MenuElement({id = "BlueKey", "Pick Blue Card", key = 69, onclick = self:PickBlue()})

	--[[Misc]]
	self.Menu:MenuElement({type = MENU, id = "Misc", name = "Misc Settings"})
	self.Menu.Misc:MenuElement({id = "MaxRange", name = "Max Range Limiter", value = 0.9, min = 0.5, max = 1, step = 0.01})
	self.Menu.Misc:MenuElement({type = SPACE, id = "ToolTip", name = "eg. X = 0.80 (Q.Range = (1150 * 0.80) = 920)"})
	self.Menu.Misc:MenuElement({type = SPACE, id = "TODO", name = "Need things to add - Give feedback."})

	--[[Draw]]
	self.Menu:MenuElement({type = MENU, id = "Draw", name = "Drawing Settings"})
	self.Menu.Draw:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true})
	self.Menu.Draw:MenuElement({id = "DrawTarget", name = "Draw Target", value = true})

	PrintChat("[AlqoholicTwistedFate] Menu Loaded")
end

function AlqoholicTwistedFate:Tick()
	local target = GetTarget(Q.Range * self.Menu.Misc.MaxRange:Value())

	if Utility:Mode() == "Combo" then
		self:Combo(target)
	elseif Utility:Mode() == "Harass" then
		self:Harass()
	elseif Utility:Mode() == "Farm" then
		self:Farm()
	end
end

function AlqoholicTwistedFate:Combo(target)
	if self.Menu.Combo.ComboQ:Value() and Utility:CanCast(_Q) and Utility:IsValidTarget(target, (Q.Range * self.Menu.Misc.MaxRange:Value())) then
		CastQ(target)
	end
end

function AlqoholicTwistedFate:Harass(target)
	
end

function AlqoholicTwistedFate:Farm(minion)
	
end

function AlqoholicTwistedFate:PickGold()
	
end

function AlqoholicTwistedFate:PickRed()
	
end

function AlqoholicTwistedFate:PickBlue()
	
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

function OnLoad()
	AlqoholicTwistedFate()
end

class "Utility"

function Utility:__init()
end

function Utility:Mode()
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

function Utility:GetPercentHP(unit)
	return 100 * unit.health / unit.maxHealth
end

function Utility:GetPercentMP(unit)
	return 100 * unit.mana / unit.maxMana
end

function Utility:HasBuff(unit, buffname)
	for K, Buff in pairs(self:GetBuffs(unit)) do
		if Buff.name:lower() == buffname:lower() then
			return true
		end
	end
	return false
end

function Utility:GetBuffs(unit)
	self.T = {}
	for i = 0, unit.buffCount do
		local Buff = unit:GetBuff(i)
		if Buff.count > 0 then
			table.insert(self.T, Buff)
		end
	end
	return self.T
end

function Utility:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function Utility:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function Utility:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function Utility:IsValidTarget(obj, spellRange)
	return obj ~= nil and obj.valid and obj.visible and not obj.dead and obj.isTargetable and obj.distance <= spellRange
end