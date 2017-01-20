class "AlqoholicLeeSin"

require("DamageLib")

local _inventoryTable = {}
local _wardItems = {}
local _updateTime = 0

function AlqoholicLeeSin:__init()
	if myHero.charName ~= "LeeSin" then return end
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	PrintChat("[AlqoholicLeeSin] Initiated")
end

function AlqoholicLeeSin:LoadSpells()
	Q = {Name = "BlindMonkQOne", Range = 1100, Delay = 0.25, Radius = 30, Speed = 1800}
	Q2 = {Name = "BlindMonkQTwo", Range = 1500, Delay = 0.25, Radius = 0, Speed = 1337000}
	W = {Name = "BlindMonkWOne", Range = 700, Delay = 0, Radius = 0, Speed = 1337000}
	W2 = {Name = "BlindMonkWTwo", Range = 0, Delay = 0, Radius = 0, Speed = 1337000}
	E = {Name = "BlindMonkEOne", Range = 400, Delay = 0.25, Radius = 400, Speed = 1337000}
	E2 = {Name = "BlindMonkETwo", Range = 450, Delay = 0.25, Radius = 450, Speed = 1337000}
	R = {Name = "BlindMonkRKick", Range = 375, Delay = 0.25, Radius = 100, Speed = 1500}
end

function AlqoholicLeeSin:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "AlqoholicLeeSin", name = "Alqohol - AlqoholicLeeSin", leftIcon = "https://puu.sh/tq0A8/5b42557aa9.png"})

	--[[Combo]]
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	self.Menu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
	self.Menu.Combo:MenuElement({id = "ComboQ2", name = "Use Q2", value = true})
	self.Menu.Combo:MenuElement({id = "ComboW", name = "Use W", value = true})
	self.Menu.Combo:MenuElement({id = "ComboWardJump", name = "Ward Jump [?]", value = true, tooltip = "Ward Jump to Target if out of E Range"})
	self.Menu.Combo:MenuElement({id = "ComboE", name = "Use E", value = true})
	self.Menu.Combo:MenuElement({id = "ComboR", name = "Use R to KS", value = true})
	--[[Farm]]
	self.Menu:MenuElement({type = MENU, id = "Farm", name = "Farm Settings"})
	self.Menu.Farm:MenuElement({id = "FarmQ", name = "Use Q", value = true})
	self.Menu.Farm:MenuElement({id = "FarmW", name = "Use W", value = true})
	self.Menu.Farm:MenuElement({id = "FarmE", name = "Use E", value = true})
	self.Menu.Farm:MenuElement({id = "FarmPassive", name = "Passive Usage", value = true})

	--[[Misc]]
	self.Menu:MenuElement({type = MENU, id = "Misc", name = "Misc Settings"})
	self.Menu.Misc:MenuElement({id = "WardJump", name = "Ward Jump", key = 71})

	--[[Draw]]
	self.Menu:MenuElement({type = MENU, id = "Draw", name = "Draw Settings"})
    self.Menu.Draw:MenuElement({id = "DrawReady", name = "Draw Only Ready Spells [?]", value = true, tooltip = "Only draws spells when they're ready"})
    self.Menu.Draw:MenuElement({id = "DrawQ", name = "Draw Q", value = true})
	self.Menu.Draw:MenuElement({id = "DrawW", name = "Draw W", value = true})
	self.Menu.Draw:MenuElement({id = "DrawE", name = "Draw E", value = true})
	self.Menu.Draw:MenuElement({id = "DrawR", name = "Draw R", value = true})
	self.Menu.Draw:MenuElement({id = "DrawTarget", name = "Draw Target", value = true})
end

function AlqoholicLeeSin:Tick()

	if (_updateTime + 5000 < GetTickCount()) then
        for j = ITEM_1, ITEM_7 do
            _inventoryTable[j] = myHero:GetItemData(j);
        end
        self:GetWardItems()
        _updateTime = GetTickCount()
    end
	if self.Menu.Misc.WardJump:Value() then
		self:WardJump(mousePos)
	end

	local target = self:GetTarget(Q.Range)

    if self:Mode() == "Combo" then
        self:Combo(target)
    elseif self:Mode() == "Farm" then
        self:Farm()
    end

end

function AlqoholicLeeSin:Combo(target)
	local useQ = self.Menu.Combo.ComboQ:Value()
	local useQ2 = self.Menu.Combo.ComboQ2:Value()
	local useW = self.Menu.Combo.ComboW:Value()
	local useWJ = self.Menu.Combo.ComboWardJump:Value()
	local useE = self.Menu.Combo.ComboE:Value()
	local useR = self.Menu.Combo.ComboR:Value()

	if target and self:IsValidTarget(target, Q.Range) then
		if useQ and self:CanCast(_Q) and myHero:GetSpellData(_Q).name == Q.Name then
			if target:GetCollision(Q.Radius * 2, Q.Speed, Q.Delay) == 0 then
				local castPos = target:GetPrediction(Q.Speed, Q.Delay)
				self:CastQ(castPos)
			end
		end
		if useQ2 and self:HasBuff(target, "BlindMonkQOne") and self:CanCast(_Q) then
			self:CastQ2()
		end
		if useE and target.distance < E.Range and self:CanCast(_E) and self:HasBuff(myHero, "blindmonkpassive_cosmetic") == false then
			self:CastE()
		end
		if useR and target.health < getdmg("R", target, myHero, 1, myHero:GetSpellData(_R).level) and target.distance <= R.Range then
			self:CastR(target)
		end
		if useWJ and target.distance > E.Range and target.distance < Q.Range then
			self:WardJump(target.pos)
		end
		if useW and self:GetPercentHP(myHero) < 30 and self:CanCast(_W) and self:HasBuff(myHero, "blindmonkpassive_cosmetic") == false then
			if myHero:GetSpellData(_W).name == W.Name then
				self:CastW(myHero)
			else
				self:CastW()
			end
		end
	end
end

function AlqoholicLeeSin:Farm()
	local useQ = self.Menu.Farm.FarmQ:Value()
	local useW = self.Menu.Farm.FarmW:Value()
	local useE = self.Menu.Farm.FarmE:Value()

	local minion = self:GetFarmTarget(E.Range)

	if minion and self:IsValidTarget(minion, E.Range) and self:HasBuff(myHero, "blindmonkpassive_cosmetic") == false then
		if useQ and self:CanCast(_Q) then
			if self:HasBuff(minion, "BlindMonkQOne") == false then
				local castPos = minion.pos
				self:CastQ(castPos)
			elseif self:HasBuff(minion, "BlindMonkQOne") and self:CanCast(_Q) then
				self:CastQ2()
			end
		end
		if useW and self:CanCast(_W) then
			if myHero:GetSpellData(_W).name == W.Name then
				self:CastW(myHero)
			else
				self:CastW()
			end
		end
		if useE and self:CanCast(_E) then
			self:CastE()
		end
	end
end

function AlqoholicLeeSin:WardJump(position)
	local unit = self:GetJumpUnit(150) --FIX ME
	if unit and myHero:GetSpellData(_W).name ~= W2.Name then
		self:CastW(unit)
	end
	if not unit and self:CanCast(_W) and myHero:GetSpellData(_W).name == W.Name then
		if _wardItems[12] ~= nil and myHero:GetSpellData(ITEM_7).ammo > 0 then
			if _wardItems[12].itemID == 3340 and _wardItems[12].stacks > 0 then
				local ward = position
				Control.CastSpell(HK_ITEM_7, ward)
				DelayAction(function()
					self:CastW(ward)
				end, 0.1)
			end
		end
		if myHero:GetSpellData(ITEM_7).ammo == 0 then
			for i=ITEM_1,ITEM_6 do
				if _wardItems[i] ~= nil then
					if i == 6 then
						if myHero:GetItemData(ITEM_1).ammo > 0 and myHero.pos:DistanceTo(position) < 600 then
							local ward = position
							Control.CastSpell(HK_ITEM_1, ward)
							DelayAction(function()
								self:CastW(ward)
							end, 0.1)
						end
					elseif i == 7 then
						if myHero:GetItemData(ITEM_1).ammo > 0 and myHero.pos:DistanceTo(position) < 600 then
							local ward = position
							Control.CastSpell(HK_ITEM_2, ward)
							DelayAction(function()
								self:CastW(ward)
							end, 0.1)
						end
					elseif i == 8 then
						if myHero:GetItemData(ITEM_1).ammo > 0 and myHero.pos:DistanceTo(position) < 600 then
							local ward = position
							Control.CastSpell(HK_ITEM_3, ward)
							DelayAction(function()
								self:CastW(ward)
							end, 0.1)
						end
					elseif i == 9 then
						if myHero:GetItemData(ITEM_1).ammo > 0 and myHero.pos:DistanceTo(position) < 600 then
							local ward = position
							Control.CastSpell(HK_ITEM_4, ward)
							DelayAction(function()
								self:CastW(ward)
							end, 0.1)
						end
					elseif i == 10 then
						if myHero:GetItemData(ITEM_1).ammo > 0 and myHero.pos:DistanceTo(position) < 600 then
							local ward = position
							Control.CastSpell(HK_ITEM_5, ward)
							DelayAction(function()
								self:CastW(ward)
							end, 0.1)
						end
					elseif i == 11 then
						if myHero:GetItemData(ITEM_1).ammo > 0 and myHero.pos:DistanceTo(position) < 600 then
							local ward = position
							Control.CastSpell(HK_ITEM_6, ward)
							DelayAction(function()
								self:CastW(ward)
							end, 0.1)
						end
					end
				end
			end
		end
	end
end

function AlqoholicLeeSin:CastQ(castPos)
	Control.CastSpell(HK_Q, castPos)
end

function AlqoholicLeeSin:CastQ2()
	Control.CastSpell(HK_Q)
end

function AlqoholicLeeSin:CastW(unit)
	Control.CastSpell(HK_W, unit)
end

function AlqoholicLeeSin:CastE()
	Control.CastSpell(HK_E)
end

function AlqoholicLeeSin:CastR(target)
	Control.CastSpell(HK_R, target)
end

function AlqoholicLeeSin:Mode()
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

function AlqoholicLeeSin:GetTarget(range)
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

function AlqoholicLeeSin:GetFarmTarget(range)
    local target
    for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if self:IsValidTarget(minion, range) and minion.team ~= myHero.team then
            target = minion
            break
        end
    end
    return target
end

function AlqoholicLeeSin:GetWardItems()
	local wardingTotem = 3340
	local sightStone = 2049
	local rubySightStone = 2045
	local trackersKnife = 3711
	local warrior = 1408
	local cinderhulk = 1409
	local bloodrazor = 1418
	local runicEchos = 1410

	for i= ITEM_1, ITEM_7 do
		if _inventoryTable[i] ~= nil and 
			(_inventoryTable[i].itemID == wardingTotem or
				_inventoryTable[i].itemID == sightStone or
				_inventoryTable[i].itemID == rubySightStone or
				_inventoryTable[i].itemID == trackersKnife or
				_inventoryTable[i].itemID == warrior or
				_inventoryTable[i].itemID == cinderhulk or
				_inventoryTable[i].itemID == bloodrazor or
				_inventoryTable[i].itemID == runicEchos) then

			_wardItems[i] = _inventoryTable[i]
		elseif _wardItems[i] ~= nil and _wardItems[i] ~= _inventoryTable[i] then
			_wardItems[i] = nil
		end
	end
end


function AlqoholicLeeSin:GetJumpUnit(range)
	local unit
	for i = 1,Game.WardCount() do
		local ward = Game.Ward(i)
		if ward.pos:DistanceTo(mousePos) <= range and ward.isTargetable and ward.valid then
			unit = ward
			break
		end
	end
	return unit
end

function AlqoholicLeeSin:GetPercentHP(unit)
    return 100 * unit.health / unit.maxHealth
end

function AlqoholicLeeSin:GetPercentMP(unit)
    return 100 * unit.mana / unit.maxMana
end

function AlqoholicLeeSin:HasBuff(unit, buffname)
    for K, Buff in pairs(self:GetBuffs(unit)) do
        if Buff.name:lower() == buffname:lower() then
            return true
        end
    end
    return false
end

function AlqoholicLeeSin:GetBuff(unit, buffname)
	local buff
	for K, Buff in pairs(self:GetBuffs(unit)) do
		if Buff.name:lower() == buffname:lower() then
			buff = Buff
			return buff
		end
	end
	return buff
end

function AlqoholicLeeSin:GetBuffs(unit)
    self.buffs = {}
    for i = 0, unit.buffCount do
        local Buff = unit:GetBuff(i)
        if Buff.count > 0 then
            table.insert(self.buffs, Buff)
        end
    end
    return self.buffs
end

function AlqoholicLeeSin:GetEnemyCount(range)
	local count = 0
	for i=1,Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero.team ~= myHero.team then
			count = count + 1
		end
	end
	return count
end

function AlqoholicLeeSin:IsReady(spellSlot)
    return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function AlqoholicLeeSin:CheckMana(spellSlot)
    return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function AlqoholicLeeSin:CanCast(spellSlot)
    return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function AlqoholicLeeSin:IsValidTarget(obj, spellRange)
    return obj ~= nil and obj.valid and obj.visible and not obj.dead and obj.isTargetable and obj.distance <= spellRange
end

function AlqoholicLeeSin:Draw()
    if myHero.dead then return end

	if self.Menu.Draw.DrawReady:Value() then
        if self:IsReady(_Q) and self.Menu.Draw.DrawQ:Value() then
            Draw.Circle(myHero.pos, Q.Range, 1, Draw.Color(255, 255, 255, 255))
        end
        if self:IsReady(_W) and self.Menu.Draw.DrawW:Value() then
            Draw.Circle(myHero.pos, W.Range, 1, Draw.Color(255, 255, 255, 255))
    		Draw.Circle(myHero.pos, 600, 1, Draw.Color(255,255,0,0))
        end
        if self:IsReady(_E) and self.Menu.Draw.DrawE:Value() then
            Draw.Circle(myHero.pos, E.Range, 1, Draw.Color(255, 255, 255, 255))
        end
        if self:IsReady(_R) and self.Menu.Draw.DrawR:Value() then
            Draw.Circle(myHero.pos, R.Range, 1, Draw.Color(255, 255, 255, 255))
        end
    else
        if self.Menu.Draw.DrawQ:Value() then
            Draw.Circle(myHero.pos, Q.Range, 1, Draw.Color(255, 255, 255, 255))
        end
        if self.Menu.Draw.DrawW:Value() then
            Draw.Circle(myHero.pos, W.Range, 1, Draw.Color(255, 255, 255, 255))
        end
        if self.Menu.Draw.DrawE:Value() then
            Draw.Circle(myHero.pos, E.Range, 1, Draw.Color(255, 255, 255, 255))
        end
        if self.Menu.Draw.DrawR:Value() then
            Draw.Circle(myHero.pos, R.Range, 1, Draw.Color(255, 255, 255, 255))
        end
    end


    if self.Menu.Draw.DrawTarget:Value() then
        local drawTarget = self:GetTarget(R.Range)
        if drawTarget then
            Draw.Circle(drawTarget.pos,80,3,Draw.Color(255, 255, 0, 0))
        end
    end
end

function OnLoad()
    AlqoholicLeeSin()
end