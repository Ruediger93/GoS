class "AlqoholicZed"

require('DamageLib')

local _shadow = myHero.pos

function AlqoholicZed:__init()
    if myHero.charName ~= "Zed" then return end
    PrintChat("[AlqoholicZed] Initiated")
    self:LoadSpells()
    self:LoadMenu()
    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)
end

function AlqoholicZed:LoadSpells()
    Q = {Range = 850, Delay = 0.25, Radius = 50, Speed = 902}
    W = {Range = 650, Delay = 0.25, Radius = 40, Speed = 1600}
    E = {Range = 270, Delay = 0.25, Radius = 135, Speed = 1337000}
    R = {Range = 630, Delay = 0.25, Radius = 0, Speed = 1337000}
    PrintChat("[AlqoholicZed] Spells Loaded")
end

function AlqoholicZed:LoadMenu()
    self.Menu = MenuElement({type = MENU, id = "AlqoholicZed", name = "Alqohol - AlqoholicZed", leftIcon="https://puu.sh/tq0A8/5b42557aa9.png"})

    --[[Combo]]
    self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
    self.Menu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
    self.Menu.Combo:MenuElement({id = "ComboW", name = "Use W", value = true})
    self.Menu.Combo:MenuElement({id = "ComboE", name = "Use E", value = true})
    self.Menu.Combo:MenuElement({id = "ComboR", name = "Use R", value = true})
    self.Menu.Combo:MenuElement({id = "RKillable", name = "Only Ult when Killable", value = true})
    self.Menu.Combo:MenuElement({id = "ComboMode", name = "Combo Mode [?]", drop = {"Normal", "Line", "Illuminati", "The Alqoholic [COMING SOON]"}, tooltip = "Must have QWER available to perform 'Line', 'Illuminati', and 'The Alqoholic'"})

    --[[Harass]]
    self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
    self.Menu.Harass:MenuElement({id = "HarassQ", name = "Use Q", value = true})
    self.Menu.Harass:MenuElement({id = "HarassW", name = "Use W", value = true})
    self.Menu.Harass:MenuElement({id = "HarassE", name = "Use E", value = true})
    self.Menu.Harass:MenuElement({id = "LongHarass", name = "Long Harass", value = true})
    self.Menu.Harass:MenuElement({id = "HarassEnergy", name = "Min. Energy", value = 40, min = 0, max = 100})

    --[[Farm]]
    self.Menu:MenuElement({type = MENU, id = "Farm", name = "Farm Settings"})
    self.Menu.Farm:MenuElement({id = "FarmQ", name = "Use Q", value = true})
    self.Menu.Farm:MenuElement({id = "FarmE", name = "Use E", value = true})
    self.Menu.Farm:MenuElement({id = "FarmEnergy", name = "Min. Energy", value = 40, min = 0, max = 100})

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
    self.Menu.Draw:MenuElement({id = "DrawLongHarass", name = "Draw Long Harass Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawTarget", name = "Draw Target [?]", value = true, tooltip = "Draws current target"})

    PrintChat("[AlqoholicZed] Menu Loaded")
end

function AlqoholicZed:Tick()

    local comboTarget = self:GetTarget(Q.Range)
    local harassTarget = self:GetTarget(W.Range + Q.Range)

    -- PrintChat("")
    -- PrintChat("")
    -- PrintChat("")
    -- PrintChat("")
    -- PrintChat("Q: " .. myHero:GetSpellData(_Q).currentCd)
    -- PrintChat("W: " .. myHero:GetSpellData(_W).currentCd)
    -- PrintChat("E: " .. myHero:GetSpellData(_E).currentCd)
    -- PrintChat("R: " .. myHero:GetSpellData(_R).currentCd)
    -- PrintChat("CanCast R = " .. tostring(self:CanCast(_R)))  

    if self:Mode() == "Combo" then
        self:Combo(comboTarget)
    elseif self:Mode() == "Harass" then
        self:Harass(harassTarget)
    elseif self:Mode() == "Farm" then
        self:Farm()
    end
end

function AlqoholicZed:Combo(target)
    local comboMode = self.Menu.Combo.ComboMode:Value()
    if target and self:CanCast(_R) then
        if comboMode == 1 then
            self:NormalCombo(target)
        elseif comboMode == 2 then
            self:LineCombo(target)
        elseif comboMode == 3 then
            self:IlluminatiCombo(target)
        elseif comboMode == 4 then
            self:AlqoholicCombo(target)
        end
    else
        target = self:GetTarget(Q.Range)
        if target then
            self:NormalCombo(target)
        end
    end
end

function AlqoholicZed:NormalCombo(target)
    if target and self:IsValidTarget(target, R.Range + W.Range) then
        if myHero:GetSpellData(_R).name ~= "ZedR2" and self:IsValidTarget(target, R.Range) and self:CanCast(_R) then
            self:CastR(target)
        end
        if myHero:GetSpellData(_W).name == "ZedW2" and self:CanCast(_W) and self.Menu.Combo.ComboW:Value() then
            self:CastW()
        elseif myHero:GetSpellData(_W).name ~= "ZedW2" and self:CanCast(_W) and self.Menu.Combo.ComboW:Value() then
            local castPos = target:GetPrediction(W.Speed, W.Delay)
            self:CastW(castPos)
        end
        if self:CanCast(_Q) and self.Menu.Combo.ComboQ:Value() and target.distance < Q.Range then
            local castPos = target:GetPrediction(Q.Speed, Q.Delay)
            self.CastQ(castPos)
        elseif self:CanCast(_E) and self.Menu.Combo.ComboE:Value() and target.distance < E.Range then
            self:CastE()
        end
    end
end
     
function AlqoholicZed:LineCombo(target)
    if ((myHero:GetSpellData(_Q).mana + myHero:GetSpellData(_W).mana + myHero:GetSpellData(_E).mana) < myHero.mana) then
        if target and self:IsValidTarget(target, Q.Range) and self:CanCast(_R) and target.distance <= R.Range then -- and myHero:GetSpellData(_R).name == "ZedR" 
            self:CastR(target)
            --PrintChat("[Line Combo] Ulting: " .. target.charName)
            if myHero:GetSpellData(_R).name == "ZedR2" then
                DelayAction(function()
                    if self:CanCast(_W) and myHero:GetSpellData(_W).name ~= "ZedW2" and self.Menu.Combo.ComboW:Value() then
                        local linePos = myHero.pos:Extend(target.pos, -2000)
                        self:CastW(linePos)
                    end
                    if self:CanCast(_Q) and self.Menu.Combo.ComboQ:Value() then
                        local castPos = target:GetPrediction(Q.Speed, Q.Delay)
                        self:CastQ(castPos)
                    end
                end, 0.75)
            end
            if self:CanCast(_E) and self.Menu.Combo.ComboE:Value() and myHero:GetSpellData(_W).name == "ZedW2" then
                self:CastE()
            end
            if myHero:GetSpellData(_W).name == "ZedW2" and self:CanCast(_Q) and not self:CanCast(_E)then
                DelayAction(function()
                    self:CastW()
                end, 1)
            end
        elseif target and self:IsValidTarget(target, R.Range) and not self:CanCast(_R) then
            self:NormalCombo()
        end
    end
end

function AlqoholicZed:IlluminatiCombo(target)
    if ((myHero:GetSpellData(_Q).mana + myHero:GetSpellData(_W).mana + myHero:GetSpellData(_E).mana) < myHero.mana) then
        if target and self:IsValidTarget(target, Q.Range) and self:CanCast(_R) and target.distance <= R.Range then -- and myHero:GetSpellData(_R).name == "ZedR" 
            self:CastR(target)
            --PrintChat("[Line Combo] Ulting: " .. target.charName)
            if myHero:GetSpellData(_R).name == "ZedR2" then
                DelayAction(function()
                    if self:CanCast(_W) and myHero:GetSpellData(_W).name ~= "ZedW2" and self.Menu.Combo.ComboW:Value() then
                        local illuminatiPos = myHero.pos:Extend(myHero.pos, -1000)
                        self:CastW(illuminatiPos)
                    end
                    if self:CanCast(_Q) and self.Menu.Combo.ComboQ:Value() then
                        local castPos = target:GetPrediction(Q.Speed, Q.Delay)
                        self:CastQ(castPos)
                    end
                end, 0.75)
            end
            if self:CanCast(_E) and self.Menu.Combo.ComboE:Value() and myHero:GetSpellData(_W).name == "ZedW2" then
                self:CastE()
            end
            if myHero:GetSpellData(_W).name == "ZedW2" and self:CanCast(_Q) and not self:CanCast(_E)then
                DelayAction(function()
                    self:CastW()
                end, 1)
            end
        elseif target and self:IsValidTarget(target, R.Range) and not self:CanCast(_R) then
            self:NormalCombo()
        end
    end
end

function AlqoholicZed:AlqoholicCombo(target)
    PrintChat("Coming Soon™")
end

function AlqoholicZed:Harass(target)
    if not target and not self:IsValidTarget(target, W.Range + Q.Range) and (myHero.mana/myHero.maxMana >= self.Menu.Harass.HarassEnergy:Value() / 100) then return end

    local targetPos = target.pos
    local harassQ = self.Menu.Harass.HarassQ:Value()
    local harassW = self.Menu.Harass.HarassW:Value()
    local harassE = self.Menu.Harass.HarassE:Value()
    local longHarass = self.Menu.Harass.LongHarass:Value()

    if longHarass then
        if self:CanCast(_Q) and harassQ and self:CanCast(_W) and harassW and myHero:GetSpellData(_W).name ~= "ZedW2" then
            if self:CanCast(_E) and harassE and target.distance < W.Range + E.Range then
                local qPos = target:GetPrediction(Q.Speed, Q.Delay)
                local wPos = target:GetPrediction(W.Speed, W.Delay)
                self:CastW(wPos)
                DelayAction(function()
                    self:CastE()
                end, 0.5)
                DelayAction(function()
                    self:CastQ(qPos)
                end, 0.75)
            else
                local qPos = target:GetPrediction(Q.Speed, Q.Delay)
                local wPos = target:GetPrediction(W.Speed, W.Delay)
                self:CastW(wPos)
                DelayAction(function()
                    self:CastQ(qPos)
                end, 0.75)
            end
        elseif target.distance < Q.Range and self:CanCast(_Q) then
            local qPos = target:GetPrediction(Q.Speed, Q.Delay)
            self:CastQ(qPos)
        end
    end
    if not longHarass then
        if target.disance < Q.Range and self:CanCast(_Q) and harassQ then
            local qPos = target:GetPrediction(Q.Speed, Q.Delay)
            self:CastQ(qPos)
        end
        if target.distance < E.Range and self:CanCast(_E) and harassE then
            self:CastE()
        end
    end
end

function AlqoholicZed:Farm()
    if not (myHero.mana/myHero.maxMana >= self.Menu.Farm.FarmEnergy:Value() / 100) then return end

    if self.Menu.Farm.FarmQ:Value() and self:CanCast(_Q) then
        local minion = self:GetFarmTarget(Q.Range)
        if minion and self:IsValidTarget(minion, Q.Range) then
            local castPos = minion:GetPrediction(Q.Speed, Q.Delay)
            self:CastQ(castPos)
        end
    end

    if self.Menu.Farm.FarmE:Value() and self:CanCast(_E) then
        local minion = self:GetFarmTarget(E.Range)
        if minion and self:IsValidTarget(minion, E.Range) then
            self:CastE()
        end
    end
end

function AlqoholicZed:CastQ(position)
    if position then
        --PrintChat(GetTickCount() .. "TRYING TO CAST Q")
        Control.CastSpell(HK_Q, position)
    end
end

function AlqoholicZed:CastW(position)
    if position then
        --PrintChat(GetTickCount() .. "TRYING TO CAST W1")
        Control.CastSpell(HK_W, position)
        if not self:HasBuff(myHero, "ZedWHandler") then
            _shadow = position
        end
    else
        if self:HasBuff(myHero, "ZedWHandler") then
            _shadow = myHero.pos
        end
        --PrintChat(GetTickCount() .. "TRYING TO CAST W2")
        Control.CastSpell(HK_W)
    end
end

function AlqoholicZed:CastE()
    --PrintChat(GetTickCount() .. "TRYING TO CAST E")
    Control.CastSpell(HK_E)
end

function AlqoholicZed:CastR(target)
    if target and self:CanCast(_R) and myHero:GetSpellData(_R).name == "ZedR" then
        --PrintChat(GetTickCount() .. "TRYING TO CAST R1")
        Control.CastSpell(HK_R, target)
    elseif myHero:GetSpellData(_R).name == "ZedR2" then
        --PrintChat(GetTickCount() .. "TRYING TO CAST R2")
        Control.CastSpell(HK_R)
    end
end

function AlqoholicZed:Draw()
    if myHero.dead then return end

    if self.Menu.Draw.DrawReady:Value() then
        if self:IsReady(_Q) and self.Menu.Draw.DrawQ:Value() then
            Draw.Circle(myHero.pos, Q.Range, 1, Draw.Color(255, 255, 255, 255))
        end
        if self:IsReady(_W) and self.Menu.Draw.DrawW:Value() then
            Draw.Circle(myHero.pos, W.Range, 1, Draw.Color(255, 255, 255, 255))
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

    local textPos = myHero.pos:To2D()

    if self.Menu.Combo.ComboMode:Value() == 1 then
        Draw.Text("Combo Mode: Normal", 20, textPos.x - 80, textPos.y + 60, Draw.Color(255, 255, 0, 0))
    end
    if self.Menu.Combo.ComboMode:Value() == 2 then
        Draw.Text("Combo Mode: Line", 20, textPos.x - 80, textPos.y + 60, Draw.Color(255, 255, 0, 0))
    end
    if self.Menu.Combo.ComboMode:Value() == 3 then
        Draw.Text("Combo Mode: Illuminati", 20, textPos.x - 80, textPos.y + 60, Draw.Color(255, 255, 0, 0))
    end
    if self.Menu.Combo.ComboMode:Value() == 4 then
        Draw.Text("Combo Mode: The Alqoholic", 20, textPos.x - 80, textPos.y + 60, Draw.Color(255, 255, 0, 0))
    end

    if self.Menu.Draw.DrawLongHarass:Value() then
        Draw.Circle(myHero.pos, W.Range + Q.Range, 1, Draw.Color(63, 191, 84, 255))
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

function AlqoholicZed:GetShadow()
    local shadow
    local shadowName = "Shadow"
    for i = 1, Game.MinionCount() do
        local minion = Game.Minion(i)
        if minion.name == shadowName then
            shadow = minion
            break
        end
    end
    return shadow
end

function AlqoholicZed:GetKillableTarget(range)
    local target
    for i = 1,Game.HeroCount() do
        local hero = Game.Hero(i)
        if self:IsValidTarget(hero, range) and hero.team ~= myHero.team and (getdmg(_R, hero, myHero, 1) + (getdmg(_Q, hero, myHero, 1) * 2) + getdmg(_E, hero, myHero, 1) + (myHero.totalDamage * 2)) > hero.health then
            target = hero
            break
        end
    end
    return target
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
    return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
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