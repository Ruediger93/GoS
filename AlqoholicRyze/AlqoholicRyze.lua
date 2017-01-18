class "AlqoholicRyze"

local _noPassive = "ryzeqiconnocharge"
local _halfPassive = "ryzeqiconhalfcharge"
local _fullPassive = "ryzeqiconfullcharge"
local _eBuff = "RyzeE"
local _comboMode
local _inventoryTable = {};
local _tearStacks = 0
local _updateTime = 0

function AlqoholicRyze:__init()
    if myHero.charName ~= "Ryze" then return end
    require('DamageLib')
    PrintChat("[AlqoholicRyze] Initiated")
    self:LoadSpells()
    self:LoadMenu()
    Callback.Add('Tick', function() self:Tick() end)
    Callback.Add('Draw', function() self:Draw() end)
end

function AlqoholicRyze:LoadSpells()
    Q = {Range = 865, Delay = 0.25, Radius = 50, Speed = 1700}
    W = {Range = 585, Delay = 0, Radius = 0, Speed = 1700}
    E = {Range = 585, Delay = 0, Radius = 0, Speed = 1700}
end

function AlqoholicRyze:LoadMenu()
    self.Menu = MenuElement({type = MENU, id = "AlqoholicRyze", name = "Alqohol - AlqoholicRyze", leftIcon="https://puu.sh/tq0A8/5b42557aa9.png"})

    --[[Combo]]
    self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
    self.Menu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
    self.Menu.Combo:MenuElement({id = "ComboW", name = "Use W", value = true})
    self.Menu.Combo:MenuElement({id = "ComboE", name = "Use E", value = true})
    self.Menu.Combo:MenuElement({id = "ComboMode", name = "Combo Mode [?]", drop = {"Burst", "Survive"}, tooltip = "Burst will use abilities when available | Survive will try to proc shield passive"})

    --[[Harass]]
    self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
    self.Menu.Harass:MenuElement({id = "HarassQ", name = "Use Q", value = true})
    self.Menu.Harass:MenuElement({id = "HarassE", name = "Use E", value = true})
    self.Menu.Harass:MenuElement({id = "HarassMana", name = "Min. Mana", value = 40, min = 0, max = 100})

    --[[Farm]]
    self.Menu:MenuElement({type = MENU, id = "Farm", name = "Farm Settings"})
    self.Menu.Farm:MenuElement({id = "FarmQ", name = "Use Q", value = true})
    self.Menu.Farm:MenuElement({id = "FarmE", name = "Use E", value = true})
    self.Menu.Farm:MenuElement({id = "FarmMana", name = "Min. Mana", value = 40, min = 0, max = 100})

    --[[Farm]]
    self.Menu:MenuElement({type = MENU, id = "LastHit", name = "LastHit Settings"})
    self.Menu.LastHit:MenuElement({id = "LastHitQ", name = "Use Q", value = true})
    self.Menu.LastHit:MenuElement({id = "LastHitMana", name = "Min. Mana", value = 40, min = 0, max = 100})

    --[[Misc]]
    self.Menu:MenuElement({type = MENU, id = "Misc", name = "Misc Settings"})
    self.Menu.Misc:MenuElement({id = "MaxRange", name = "Max Range Limiter [?]", value = 0.9, min = 0.5, max = 1, step = 0.01, tooltip = "eg. X = 0.80 (Q.Range = (865 * 0.80) = 692)"})
    self.Menu.Misc:MenuElement({id = "StackTear", name = "StackTear when >= 90% mana", value = true})
    self.Menu.Misc:MenuElement({type = SPACE, id = "TODO", name = "Need things to add - Give feedback."})

    --[[Draw]]
    self.Menu:MenuElement({type = MENU, id = "Draw", name = "Drawing Settings"})
    self.Menu.Draw:MenuElement({id = "DrawReady", name = "Draw Only Ready Spells [?]", value = true, tooltip = "Only draws spells when they're ready"})
    self.Menu.Draw:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawW", name = "Draw W Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawE", name = "Draw E Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawTarget", name = "Draw Target [?]", value = true, tooltip = "Draws current target"})

    PrintChat("[AlqoholicRyze] Menu Loaded")
end

function AlqoholicRyze:Tick()

    if (_updateTime + 5000 < GetTickCount()) and self.Menu.Misc.StackTear:Value() then
        for j = ITEM_1, ITEM_6 do
            _inventoryTable[j] = myHero:GetItemData(j);
        end
        _updateTime = GetTickCount()
    end

    if self.Menu.Combo.ComboMode:Value() == 1 then
        _comboMode = "Burst"
    elseif self.Menu.Combo.ComboMode:Value() == 2 then
        _comboMode = "Survive"
    end

    if self.Menu.Misc.StackTear:Value() and self:Mode() == "" then
        self:StackTear()
    end

    if self:Mode() == "Combo" then
        self:Combo()
    elseif self:Mode() == "Harass" then
        self:Harass()
    elseif self:Mode() == "Farm" then
        self:Farm()
    elseif self:Mode() == "LastHit" then
        self:LastHit()
    end
end

function AlqoholicRyze:Combo() -- TODO IMPROVE LOGIC

    if _comboMode == "Burst" then

        local weTarget = self:GetTarget(E.Range * self.Menu.Misc.MaxRange:Value())
        local qTarget = self:GetTarget(Q.Range * self.Menu.Misc.MaxRange:Value())

        if weTarget and self:IsValidTarget(weTarget, E.Range * self.Menu.Misc.MaxRange:Value()) then
            if self.Menu.Combo.ComboW:Value() and self:CanCast(_W) then
                self:CastW(weTarget)
            elseif self.Menu.Combo.ComboE:Value() and self:CanCast(_E) then
                self:CastE(weTarget)
            end
        end

        if qTarget and self:IsValidTarget(qTarget, Q.Range) then
            if self.Menu.Combo.ComboQ:Value() and self:CanCast(_Q) then
                self:CastQ(qTarget)
            end
        end

    elseif _comboMode == "Survive" then
        local target = self:GetTarget(E.Range * self.Menu.Misc.MaxRange:Value())
        if target and self:IsValidTarget(target, E.Range * self.Menu.Misc.MaxRange:Value()) then
            if self:HasBuff(target, _eBuff) and self:HasBuff(myHero, _fullPassive) then
                self:CastQ(target)
            elseif self:HasBuff(target, _eBuff) and self:HasBuff(myHero, _halfPassive) then
                self:CastW(target)
            elseif self:HasBuff(myHero, _noPassive) then
                if self:CanCast(_E) then
                    self:CastE(target)
                elseif self:CanCast(_W) then
                    self:CastW(target)
                end
            elseif self:CanCast(_E) then
                self:CastE(target)
            elseif self:CanCast(_W) then
                self:CastW(target)
            end
        end
    end
end

function AlqoholicRyze:Harass()
    if (myHero.mana/myHero.maxMana >= self.Menu.Harass.HarassMana:Value() / 100) then
        local target = self:GetTarget(E.Range * self.Menu.Misc.MaxRange:Value())
        if self.Menu.Harass.HarassE:Value() and self:CanCast(_E) then
            self:CastE(target)
        elseif self.Menu.Harass.HarassQ:Value() and self:CanCast(_Q) then
            self:CastQ(target)
        end
    end
end

function AlqoholicRyze:Farm()
    if (myHero.mana/myHero.maxMana >= self.Menu.Farm.FarmMana:Value() / 100) then
        local qMinion = self:GetFarmTarget(Q.Range * self.Menu.Misc.MaxRange:Value())
        local eMinion = self:GetFarmTarget(E.Range * self.Menu.Misc.MaxRange:Value())
        if self.Menu.Farm.FarmE:Value() and self:CanCast(_E) then
            self:CastE(eMinion)
        elseif self.Menu.Farm.FarmQ:Value() and self:CanCast(_Q) then
            self:CastQ(qMinion)
        end
    end
end

function AlqoholicRyze:LastHit()
    if self.Menu.LastHit.LastHitQ:Value() and (myHero.mana/myHero.maxMana >= self.Menu.LastHit.LastHitMana:Value() / 100) and self:CanCast(_Q) then
        local target
        for i=1,Game.MinionCount() do
            local minion = Game.Minion(i)
            if (self:IsValidTarget(minion, Q.Range * self.Menu.Misc.MaxRange:Value())) and
                (minion.team ~= myHero.team) and
                (getdmg(_R, minion, myHero) > minion.health) then
                target = minion
                break
            end
        end

        if target and self:IsValidTarget(target, Q.Range * self.Menu.Misc.MaxRange:Value())then
            self:CastQ(target)
        end
    end
end

function AlqoholicRyze:StackTear()
    if self:CheckTear() and _tearStacks < 750 and (myHero.mana / myHero.maxMana >= 0.9) and self:CanCast(_Q) and not myHero.dead and not self:HasBuff(myHero, "recall") then
        Control.CastSpell(HK_Q, mousePos)
        _tearStacks = _tearStacks + 4
    end
end

function AlqoholicRyze:CheckTear()
    local tearID = 3070
    for i = ITEM_1, ITEM_6 do
        if _inventoryTable[i] ~= nil and _inventoryTable[i].itemID == tearID then
            return true
        end
    end
    return false
end

function AlqoholicRyze:CastQ(qtarget)
    if qtarget then
        if qtarget:GetCollision(Q.Radius * 2, Q.Speed, Q.Delay) == 0 then
            local castPos = qtarget:GetPrediction(Q.Speed, Q.Delay)
            Control.CastSpell(HK_Q, castPos)
        end
    end
end

function AlqoholicRyze:CastW(unit)
    Control.CastSpell(HK_W, unit)
end

function AlqoholicRyze:CastE(unit)
    Control.CastSpell(HK_E, unit)
end


function AlqoholicRyze:Draw()
    if myHero.dead then return end

    if self.Menu.Draw.DrawReady:Value() then
        if self:IsReady(_Q) and self.Menu.Draw.DrawQ:Value() then
            Draw.Circle(myHero.pos,Q.Range * self.Menu.Misc.MaxRange:Value(),1,Draw.Color(255, 255, 255, 255))
        elseif self:IsReady(_W) and self.Menu.Draw.DrawW:Value() then
            Draw.Circle(myHero.pos,W.Range * self.Menu.Misc.MaxRange:Value(),1,Draw.Color(255, 255, 255, 255))
        elseif self:IsReady(_E) and self.Menu.Draw.DrawE:Value() then
            Draw.Circle(myHero.pos,E.Range * self.Menu.Misc.MaxRange:Value(),1,Draw.Color(255, 255, 255, 255))
        end
        elseif self.Menu.Draw.DrawQ:Value() then
            Draw.Circle(myHero.pos,Q.Range * self.Menu.Misc.MaxRange:Value(),1,Draw.Color(255, 255, 255, 255))
        elseif self.Menu.Draw.DrawW:Value() then
            Draw.Circle(myHero.pos,W.Range * self.Menu.Misc.MaxRange:Value(),1,Draw.Color(255, 255, 255, 255))
        elseif self.Menu.Draw.DrawE:Value() then
            Draw.Circle(myHero.pos,E.Range * self.Menu.Misc.MaxRange:Value(),1,Draw.Color(255, 255, 255, 255))

    end
    if self.Menu.Draw.DrawTarget:Value() then
        local drawTarget = self:GetTarget(Q.Range)
        if drawTarget then
            Draw.Circle(drawTarget.pos,80,3,Draw.Color(255, 255, 0, 0))
        end
    end
end

function AlqoholicRyze:Mode()
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

function AlqoholicRyze:GetTarget(range)
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

function AlqoholicRyze:GetFarmTarget(range)
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

function AlqoholicRyze:GetPercentHP(unit)
    return 100 * unit.health / unit.maxHealth
end

function AlqoholicRyze:GetPercentMP(unit)
    return 100 * unit.mana / unit.maxMana
end

function AlqoholicRyze:HasBuff(unit, buffname)
    for K, Buff in pairs(self:GetBuffs(unit)) do
        if Buff.name:lower() == buffname:lower() then
            return true
        end
    end
    return false
end

function AlqoholicRyze:GetBuffs(unit)
    self.T = {}
    for i = 0, unit.buffCount do
        local Buff = unit:GetBuff(i)
        if Buff.count > 0 then
            table.insert(self.T, Buff)
        end
    end
    return self.T
end

function AlqoholicRyze:IsReady(spellSlot)
    return myHero:GetSpellData(spellSlot).currentCd < 0.01 and myHero:GetSpellData(spellSlot).level > 0
end

function AlqoholicRyze:CheckMana(spellSlot)
    return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function AlqoholicRyze:CanCast(spellSlot)
    return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function AlqoholicRyze:IsValidTarget(obj, spellRange)
    return obj ~= nil and obj.valid and obj.visible and not obj.dead and obj.isTargetable and obj.distance <= spellRange
end

function OnLoad()
    AlqoholicRyze()
end