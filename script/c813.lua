--Raidraptor - Last Blast Falcon
local s,id=GetID()
function s.initial_effect(c)
    Xyz.AddProcedure(c,nil,10,4)
    c:EnableReviveLimit()

    -- Cannot return to Extra Deck / Battle indestructible
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_TO_DECK)
    e1:SetCondition(s.matcon)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetCondition(s.matcon)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- Gain ATK by sending Winged Beast from Extra Deck
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.atkcon)
    e3:SetCost(s.atkcost)
    e3:SetOperation(s.atkop)
    c:RegisterEffect(e3)

    -- Float from banished
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATTACH)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_REMOVE)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
    e4:SetCondition(s.recon)
    e4:SetTarget(s.retg)
    e4:SetOperation(s.reop)
    c:RegisterEffect(e4)
end

-- Condition: Has a Raidraptor Xyz as material
function s.matfilter(c)
    return c:IsSetCard(0xba) and c:IsType(TYPE_XYZ)
end
function s.matcon(e)
    return e:GetHandler():GetOverlayGroup():IsExists(s.matfilter,1,nil)
end

-- Battle damage condition
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetBattleDamage(tp)>0 or Duel.GetBattleDamage(1-tp)>0
end

-- Cost: send 1 Winged Beast from ED to GY
function s.cfilter(c)
    return c:IsRace(RACE_WINGEDBEAST) and c:IsAbleToGraveAsCost() and c:GetAttack()>0
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_EXTRA,0,1,1,nil)
    e:SetLabel(g:GetFirst():GetAttack())
    e:SetLabelObject(g:GetFirst())
    Duel.SendtoGrave(g,REASON_COST)
end

-- Operation: gain ATK, schedule banish
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local atk=e:GetLabel()
    if c:IsRelateToEffect(e) and c:IsFaceup() and atk>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(atk)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
        c:RegisterEffect(e1)
        -- Schedule banishment at end of Damage Step
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_DAMAGE_STEP_END)
        e2:SetCountLimit(1)
        e2:SetLabelObject(e:GetLabelObject()) -- Pass the GY Xyz
        e2:SetOperation(s.rmop)
        e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
        Duel.RegisterEffect(e2,tp)
    end
end

-- Remove the card at end of damage step
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetOwner()
    if c:IsRelateToBattle() and c:IsControler(tp) then
        Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
        c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
        c:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD,0,1)
        c:SetCardTarget(e:GetLabelObject()) -- Store the sent monster as target
    end
end

-- Float condition: was banished by own effect
function s.recon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetFlagEffect(id)>0 and e:GetHandler():GetFlagEffect(id+1)>0
end

-- Float target: GY target that was used earlier
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local tc=c:GetFirstCardTarget()
    if chk==0 then
        return tc and tc:IsType(TYPE_XYZ)
            and tc:IsAbleToExtra()
            and Duel.GetLocationCountFromEx(tp,tp,nil,tc)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,tc:GetCode(),e,tp,c)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

-- Float operation
function s.spfilter(c,code,e,tp,mat)
    return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mat,c)>0
end
function s.reop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=c:GetFirstCardTarget()
    if not (c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e)) then return end
    if Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_EXTRA) then
        Duel.ShuffleDeck(tp)
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,tc:GetCode(),e,tp,c)
        local sc=g:GetFirst()
        if sc and Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
            Duel.Overlay(sc,Group.FromCards(c))
            sc:CompleteProcedure()
        end
    end
end
