class "AlqoholicZed"

require('DamageLib')

local _wPosition = myHero.pos
local _rPosition = myHero.pos

local _comboRange = 800

function AlqoholicZed:__init()
	if myHero.charName ~= "Zed" then return end
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	PrintChat("[AlqoholicZed] Initiated")
end

function AlqoholicZed:LoadSpells()
	Q = {Range = 850, Delay = 0.25, Radius = 50, Speed = 1700}
	W = {Range = 650, Delay = 0.25, Radius = 40, Speed = 1600}
	E = {Range = 270, Delay = 0.25, Radius = 135, Speed = 1337000}
	R = {Range = 650, Delay = 0.25, Radius = 0, Speed = 1337000}
end

function AlqoholicZed:LoadMenu()
    self.Menu = MenuElement({type = MENU, id = "AlqoholicZed", name = "Alqohol - AlqoholicZed", leftIcon="https://puu.sh/tq0A8/5b42557aa9.png"})

    --[[Combo]]
    self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
    self.Menu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
    self.Menu.Combo:MenuElement({id = "ComboW", name = "Use W", value = true})
    self.Menu.Combo:MenuElement({id = "WGapClose", name = "Gapclose with W", value = true})
    self.Menu.Combo:MenuElement({id = "ComboE", name = "Use E", value = true})
    self.Menu.Combo:MenuElement({id = "ComboR", name = "Use R", value = true})
    self.Menu.Combo:MenuElement({id = "RKillable", name = "Only Ult when Killable", value = true})
    self.Menu.Combo:MenuElement({id = "ComboMode", name = "Combo Mode [?]", drop = {"Normal", "Line", "Illuminati", "The Alqoholic"}, tooltip = "Must have QWER available to perform 'Line', 'Illuminati', and 'The Alqoholic'"})

    --[[Harass]]
    self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
    self.Menu.Harass:MenuElement({id = "HarassQ", name = "Use Q", value = true})
    self.Menu.Harass:MenuElement({id = "HarassW", name = "Use W", value = true})
    self.Menu.Harass:MenuElement({id = "HarassE", name = "Use E", value = true})
    self.Menu.Harass:MenuElement({id = "HarassEnergy", name = "Min. Energy", value = 40, min = 0, max = 100})

    --[[Farm]]
    self.Menu:MenuElement({type = MENU, id = "Farm", name = "Farm Settings"})
    self.Menu.Farm:MenuElement({id = "FarmQ", name = "Use Q", value = true})
    self.Menu.Farm:MenuElement({id = "FarmE", name = "Use E", value = true})
    self.Menu.Farm:MenuElement({id = "FarmEnergy", name = "Min. Energy", value = 40, min = 0, max = 100})

    --[[Farm]]
    self.Menu:MenuElement({type = MENU, id = "LastHit", name = "LastHit Settings"})
    self.Menu.LastHit:MenuElement({id = "LastHitQ", name = "Use Q", value = true})
    self.Menu.LastHit:MenuElement({id = "LastHitEnergy", name = "Min. Energy", value = 40, min = 0, max = 100})

    --[[Misc]]
    self.Menu:MenuElement({type = MENU, id = "Misc", name = "Misc Settings"})
    self.Menu.Misc:MenuElement({id = "KS", name = "KS with Q", value = true})
    self.Menu.Misc:MenuElement({type = SPACE, id = "TODO", name = "Need things to add - Give feedback."})

    --[[Draw]]
    self.Menu:MenuElement({type = MENU, id = "Draw", name = "Drawing Settings"})
    self.Menu.Draw:MenuElement({id = "DrawReady", name = "Draw Only Ready Spells [?]", value = true, tooltip = "Only draws spells when they're ready"})
    self.Menu.Draw:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawW", name = "Draw W Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawE", name = "Draw E Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawR", name = "Draw R Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawTarget", name = "Draw Target [?]", value = true, tooltip = "Draws current target"})

    PrintChat("[AlqoholicZed] Menu Loaded")
end

function AlqoholicZed:Tick()
	
	local target = self:GetTarget(_comboRange)

	if self:Menu.Misc.KS:Value() then
		self:KS()
	end

	if self:Mode() == "Combo" then
		self:Combo(target)
	elseif self:Mode() == "Harass" then
		self:Harass(target)
	elseif self:Mode() == "Farm" then
		self:Farm()
	elseif self:Mode() = "LastHit" then
		self:LastHit()
	end
end

function AlqoholicZed:Combo(target)
	local useR = self.Menu.Combo.ComboR:Value()
	local comboMode = self.Menu.Combo.ComboMode:Value()

	if not target and not self:IsValidTarget(target, _comboRange) then return end

	if self:CanCast(_R) then
		if comboMode == 1 then
			self:NormalCombo(target)
		elseif comboMode == 2 then
			self:LineCombo(target)
		elseif comboMode == 3 then
			self:IlluminatiCombo(target)
		elseif comboMode == 4 then
			self:AlqoholicCombo(target)
		end
	end

	if self:CanCast(_W) and not self:HasBuff(myHero, "zedwhandler") then
		self:CastW(target)


end

function AlqoholicZed:Draw()
    if myHero.dead then return end

    if self.Menu.Draw.DrawReady:Value() then
        if self:IsReady(_Q) and self.Menu.Draw.DrawQ:Value() then
            Draw.Circle(myHero.pos,Q.Range * self.Menu.Misc.MaxRange:Value(),1,Draw.Color(255, 255, 255, 255))
        end
        if self:IsReady(_W) and self.Menu.Draw.DrawW:Value() then
            Draw.Circle(myHero.pos,W.Range * self.Menu.Misc.MaxRange:Value(),1,Draw.Color(255, 255, 255, 255))
        end
        if self:IsReady(_E) and self.Menu.Draw.DrawE:Value() then
            Draw.Circle(myHero.pos,E.Range * self.Menu.Misc.MaxRange:Value(),1,Draw.Color(255, 255, 255, 255))
        end
        if self.Menu.Draw.DrawQ:Value() then
            Draw.Circle(myHero.pos,Q.Range * self.Menu.Misc.MaxRange:Value(),1,Draw.Color(255, 255, 255, 255))
        end
        if self.Menu.Draw.DrawW:Value() then
            Draw.Circle(myHero.pos,W.Range * self.Menu.Misc.MaxRange:Value(),1,Draw.Color(255, 255, 255, 255))
        end
        if self.Menu.Draw.DrawE:Value() then
            Draw.Circle(myHero.pos,E.Range * self.Menu.Misc.MaxRange:Value(),1,Draw.Color(255, 255, 255, 255))
        end
    end

    if self.Menu.Draw.DrawTarget:Value() then
        local drawTarget = self:GetTarget(Q.Range)
        if drawTarget then
            Draw.Circle(drawTarget.pos,80,3,Draw.Color(255, 255, 0, 0))
        end
    end
end

function AlqoholicZed:Mode()
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

function AlqoholicZed:GetTarget(range)
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

function AlqoholicZed:GetFarmTarget(range)
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

function AlqoholicZed:GetPercentHP(unit)
    return 100 * unit.health / unit.maxHealth
end

function AlqoholicZed:GetPercentMP(unit)
    return 100 * unit.mana / unit.maxMana
end

function AlqoholicZed:HasBuff(unit, buffname)
    for K, Buff in pairs(self:GetBuffs(unit)) do
        if Buff.name:lower() == buffname:lower() then
            return true
        end
    end
    return false
end

function AlqoholicZed:GetBuffs(unit)
    self.T = {}
    for i = 0, unit.buffCount do
        local Buff = unit:GetBuff(i)
        if Buff.count > 0 then
            table.insert(self.T, Buff)
        end
    end
    return self.T
end

function AlqoholicZed:IsReady(spellSlot)
    return myHero:GetSpellData(spellSlot).currentCd < 0.01 and myHero:GetSpellData(spellSlot).level > 0
end

function AlqoholicZed:CheckMana(spellSlot)
    return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function AlqoholicZed:CanCast(spellSlot)
    return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function AlqoholicZed:IsValidTarget(obj, spellRange)
    return obj ~= nil and obj.valid and obj.visible and not obj.dead and obj.isTargetable and obj.distance <= spellRange
end

function OnLoad()
    AlqoholicZed()
end