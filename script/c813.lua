--Raidraptor - Last Blast Falcon
local s,id=GetID()
function s.initial_effect(c)
    Xyz.AddProcedure(c,nil,10,4)
    c:EnableReviveLimit()

    -- Cannot return to Extra Deck / Battle indestructible if it has Raidraptor Xyz material
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

    -- Quick Effect: Send Winged Beast from Extra Deck to GY, gain ATK
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

    -- Float when banished: revive an Xyz from GY and attach this card
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_REMOVE)
    e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e4:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
    e4:SetTarget(s.retg)
    e4:SetOperation(s.reop)
    c:RegisterEffect(e4)
end

-- Condition: This card has a Raidraptor Xyz as material
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

-- Cost: send 1 Winged Beast from Extra Deck to GY
function s.cfilter(c)
    return c:IsRace(RACE_WINGEDBEAST) and c:IsAbleToGraveAsCost() and c:GetAttack()>0
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_EXTRA,0,1,1,nil)
    e:SetLabel(g:GetFirst():GetAttack())
    Duel.SendtoGrave(g,REASON_COST)
end

-- Operation: gain ATK and schedule banish
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

        -- Schedule banish at Damage Step end
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_DAMAGE_STEP_END)
        e2:SetOperation(function(_,tp) Duel.Remove(c,POS_FACEUP,REASON_EFFECT) end)
        e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
        Duel.RegisterEffect(e2,tp)
    end
end

-- Float Target: Any Xyz monster in GY
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_XYZ),tp,LOCATION_GRAVE,0,1,nil)
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsType,TYPE_XYZ),tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

-- Float Operation
function s.spfilter(c,code,e,tp)
    return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.reop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not (c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e)) then return end
    if Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_EXTRA) then
        Duel.ShuffleDeck(tp)
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,tc:GetCode(),e,tp)
        local sc=g:GetFirst()
        if sc and Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
            Duel.Overlay(sc,Group.FromCards(c))
            sc:CompleteProcedure()
        end
    end
end
