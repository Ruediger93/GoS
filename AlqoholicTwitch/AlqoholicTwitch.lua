class "AlqoholicTwitch"

local _passiveBuffName = "TwitchDeadlyVenom"

function AlqoholicTwitch:__init()
	if myHero.charName ~= "Twitch" then return end
	require('DamageLib')
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function()	self:Tick()	end)
	Callback.Add("Draw", function()	self:Draw()	end)
	PrintChat("[AlqoholicTwitch] Initiated")
end

function AlqoholicTwitch:LoadSpells()
	W = {Range = 950, Delay = 0.25, Radius = 50, Speed = 1410}
	E = {Range = 1200, Delay = 0, Radius = 0, Speed = 1337000}
end

function AlqoholicTwitch:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "AlqoholicTwitch", name = "Alqohol - AlqoholicTwitch", leftIcon = "https://puu.sh/tq0A8/5b42557aa9.png"})

	--[[Combo]]
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	self.Menu.Combo:MenuElement({id = "ComboW", name = "Use W", value = true})
	self.Menu.Combo:MenuElement({id = "ComboE", name = "Use E", value = true})
	self.Menu.Combo:MenuElement({id = "ComboR", name = "Use R", value = true})
	self.Menu.Combo:MenuElement({id = "REnemies", name = "R when enemies >= x [?]", value = 2, min = 0, max = 5, step = 1, tooltip = "Will only ult when enemies in Ult range >= x (0 to disable [Always ult])"})

	--[[Harass]]
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
	self.Menu.Harass:MenuElement({id = "HarassW", name = "Use W", value = true})
	self.Menu.Harass:MenuElement({id = "HarassE", name = "Use E", value = true})
	self.Menu.Harass:MenuElement({id = "HarassStacks", name = "Min. Stacks to E", value = 3, min = 1, max = 6, step = 1})
	self.Menu.Harass:MenuElement({id = "HarassMana", name = "Min. Mana", value = 40, min = 0, max = 100, step = 1})

	--[[Misc]]
	self.Menu:MenuElement({type = MENU, id = "Misc", name = "Misc Settings"})
	self.Menu.Misc:MenuElement({id = "StealthRecall", name = "Stealth Recall", key = 84})
	self.Menu.Misc:MenuElement({id = "AutoE", name = "Auto E on Killable", value = true})
	self.Menu.Misc:MenuElement({id = "EOverKill", name = "E Over Kill Damage % [?]", value = 5, min = 1, max = 100, step = 1, tooltip = "Will add x% more damage onto the calculation"})
	self.Menu.Misc:MenuElement({id = "AutoQ", name = "Auto Q on Reset - NO API FOR IT YET", value = true})

	--[[Draw]]
	self.Menu:MenuElement({type = MENU, id = "Draw", name = "Draw Settings"})
	self.Menu.Draw:MenuElement({id = "DrawQ", name = "Draw Q", value = true})
	self.Menu.Draw:MenuElement({id = "DrawW", name = "Draw W", value = true})
	self.Menu.Draw:MenuElement({id = "DrawE", name = "Draw E", value = true})
	self.Menu.Draw:MenuElement({id = "DrawR", name = "Draw R", value = true})
	self.Menu.Draw:MenuElement({id = "DrawTarget", name = "Draw Target", value = true})
end

function AlqoholicTwitch:Tick()
	
	if self.Menu.Misc.AutoE:Value() and self:CanCast(_E) then
		local eTarget = self:GetTarget(E.Range)
		local overKill = self.Menu.Misc.EOverKill:Value()
		if eTarget and self:IsValidTarget(eTarget, E.Range) and self:HasBuff(eTarget, _passiveBuffName) and ((getdmg(_E, eTarget, myHero) + ((getdmg(_E, eTarget, myHero) / 100) * overKill)) > eTarget.health) then
			self:CastE()
		end
	end

	if self.Menu.Misc.StealthRecall:Value() and self:CanCast(_E) then
		self:CastE()
		DelayAction()
		Control.CastSpell('66')
	end

    if self:Mode() == "Combo" then
        self:Combo()
    elseif self:Mode() == "Harass" then
        self:Harass()
    end

end

function AlqoholicTwitch:Combo()

	local useQ = self.Menu.Misc.AutoQ:Value()
	local useW = self.Menu.Combo.ComboW:Value()
	local useE = self.Menu.Combo.ComboE:Value()
	local useR = self.Menu.Combo.ComboR:Value()
	local rEnemies = self.Menu.Combo.REnemies:Value()

	local target = self:GetTarget(W.Range)

	if target and self:IsValidTarget(target, W.Range) then
		-- if useQ
		if useW and self:CanCast(_W) and self:GetStacks(target) < 6 then
			local castPos = target:GetPrediction(W.Speed, W.Delay)
			self:CastW(castPos)
		elseif useR and self:GetEnemyCount() >= rEnemies then
			self:CastR()
		elseif useE and self:KillableWithE(E.Range) then
			self:CastE()
		end
	end
end

function AlqoholicTwitch:Harass()

	local useW = self.Menu.Harass.HarassW:Value()
	local useE = self.Menu.Harass.HarassE:Value()
	local harassStacks = self.Menu.Harass.HarassStacks:Value()

	local target = self:GetTarget(W.Range)

	if target and self:IsValidTarget(target, W.Range) and (myHero.mana/myHero.maxMana >= self.Menu.Harass.HarassMana:Value() / 100) then
		if useW and self:CanCast(_W) and self:GetStacks(target) < 6 then
			local castPos = target:GetPrediction(W.Speed, W.Delay)
			self:CastW(castPos)
		elseif useE and self:GetStacks(target) >= harassStacks then
			self:CastE()
		end
	end
end

function AlqoholicTwitch:CastQ()
	Control.CastSpell(HK_Q)
end

function AlqoholicTwitch:CastW(position)
	Control.CastSpell(HK_W, position)
end

function AlqoholicTwitch:CastE()
	Control.CastSpell(HK_E)
end

function AlqoholicTwitch:CastR()
	Control.CastSpell(HK_R)
end

function AlqoholicTwitch:Mode()
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

function AlqoholicTwitch:GetTarget(range)
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

function AlqoholicTwitch:GetFarmTarget(range)
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

function AlqoholicTwitch:GetPercentHP(unit)
    return 100 * unit.health / unit.maxHealth
end

function AlqoholicTwitch:GetPercentMP(unit)
    return 100 * unit.mana / unit.maxMana
end

function AlqoholicTwitch:HasBuff(unit, buffname)
    for K, Buff in pairs(self:GetBuffs(unit)) do
        if Buff.name:lower() == buffname:lower() then
            return true
        end
    end
    return false
end

function AlqoholicTwitch:GetStacks(unit)
	for K, Buff in pairs(self:GetBuffs(unit)) do
		if Buff.name:lower() == _passiveBuffName:lower() then
			return Buff.stacks
		end
	end
	return 0
end

function AlqoholicTwitch:KillableWithE(range)
	local canKill = false
	for i = 1, Game.Game.HeroCount() do
		local hero = Game.Hero(i)
		if self:IsValidTarget(hero, range) and hero.team ~= myHero.team and self:HasBuff(hero, _passiveBuffName) and ((getdmg(_E, hero, myHero) + ((getdmg(_E, hero, myHero) / 100) * overKill)) > hero.health) then
			canKill = true
			break
		end
	end
	return canKill
end

function AlqoholicTwitch:GetBuffs(unit)
    self.buffs = {}
    for i = 0, unit.buffCount do
        local Buff = unit:GetBuff(i)
        if Buff.count > 0 then
            table.insert(self.buffs, Buff)
        end
    end
    return self.buffs
end

function AlqoholicTwitch:GetEnemyCount(range)
	local count = 0
	for i=1,Game.HeroCount() do
		local hero = Game.Hero(i)
		if self:IsValidTarget(hero, range) and hero.team ~= myHero.team then
			count = count + 1
		end
	end
	return count
end

function AlqoholicTwitch:IsReady(spellSlot)
    return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function AlqoholicTwitch:CheckMana(spellSlot)
    return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function AlqoholicTwitch:CanCast(spellSlot)
    return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function AlqoholicTwitch:IsValidTarget(obj, spellRange)
    return obj ~= nil and obj.valid and obj.visible and not obj.dead and obj.isTargetable and obj.distance <= spellRange
end

function AlqoholicTwitch:Draw()
    if myHero.dead then return end

    if self.Menu.Draw.DrawReady:Value() then
        if self:IsReady(_Q) and self.Menu.Draw.DrawQ:Value() then
            Draw.Circle(myHero.pos,Q.Range,1,Draw.Color(255, 255, 255, 255))
        end
        if self:IsReady(_W) and self.Menu.Draw.DrawW:Value() then
            Draw.Circle(myHero.pos,W.Range,1,Draw.Color(255, 255, 255, 255))
        end
        if self:IsReady(_E) and self.Menu.Draw.DrawE:Value() then
            Draw.Circle(myHero.pos,E.Range,1,Draw.Color(255, 255, 255, 255))
        end
        if self:IsReady(_R) and self.Menu.Draw.DrawR:Value() then
            Draw.Circle(myHero.pos,R.Range,1,Draw.Color(255, 255, 255, 255))
        end
        if self.Menu.Draw.DrawQ:Value() then
            Draw.Circle(myHero.pos,Q.Range,1,Draw.Color(255, 255, 255, 255))
        end
        if self.Menu.Draw.DrawW:Value() then
            Draw.Circle(myHero.pos,W.Range,1,Draw.Color(255, 255, 255, 255))
        end
        if self.Menu.Draw.DrawE:Value() then
            Draw.Circle(myHero.pos,E.Range,1,Draw.Color(255, 255, 255, 255))
        end
        if self.Menu.Draw.DrawR:Value() then
            Draw.Circle(myHero.pos,R.Range,1,Draw.Color(255, 255, 255, 255))
        end
    end

    if self.Menu.Draw.DrawTarget:Value() then
        local drawTarget = self:GetTarget(Q.Range)
        if drawTarget then
            Draw.Circle(drawTarget.pos,80,3,Draw.Color(255, 255, 0, 0))
        end
    end
end

function OnLoad()
    AlqoholicTwitch()
end