--Rhea, Mother the Aesir
local s,id=GetID()
function s.initial_effect(c)
    --Synchro Summon procedure
    Synchro.AddProcedure(c,s.synfilter,1,1,Synchro.NonTuner(nil),1,99)
    c:EnableReviveLimit()

    -- Special Summon 1 Aesir (except Fairy)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0)) -- "Target 1 'Aesir' monster in your GY, except a Fairy monster; Special Summon it."
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Gain LP, possibly negate, always gain ATK
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1)) -- "Gain 1500 LP, then if the LP difference is 3000 or more and your opponent activated the effect, negate it. Then, this card gains ATK equal to the LP gained."
    e2:SetCategory(CATEGORY_RECOVER+CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.negcon)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)

    -- Revive self
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2)) -- "During the End Phase, if this card was sent to the GY by an opponent’s card effect: Special Summon it."
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,2})
    e3:SetCondition(s.revcon)
    e3:SetTarget(s.revtg)
    e3:SetOperation(s.revop)
    c:RegisterEffect(e3)

    -- Draw 2 after being revived by its own effect
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,3)) -- "If this card was Special Summoned by its own effect: Draw 2 cards."
    e4:SetCategory(CATEGORY_DRAW)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCountLimit(1,{id,3})
    e4:SetCondition(s.drawcon)
    e4:SetTarget(s.drawtg)
    e4:SetOperation(s.drawop)
    c:RegisterEffect(e4)
end

-- Synchro Tuner material: must be Nordic or Aesir
function s.synfilter(c,sc,tp)
    return c:IsType(TYPE_SYNCHRO) and c:IsType(TYPE_TUNER) and (c:IsSetCard(0x42) or c:IsSetCard(0x4b))
end

-- Special Summon Aesir from GY (except Fairy)
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x4b) and not c:IsRace(RACE_FAIRY)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- LP gain, conditional negate, always ATK gain
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return re:GetHandler()~=e:GetHandler() and re:IsActivated()
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local lpGain=1500
    if Duel.Recover(tp,lpGain,REASON_EFFECT)>0 then
        local lp_diff=math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp))
        if rp~=tp and lp_diff>=3000 and Duel.NegateEffect(ev) then
            -- successful negate
        end
        -- Always gain ATK
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(lpGain)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e1)
    end
end

-- End Phase revive self if sent by opponent
function s.revcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_EFFECT) and rp~=tp
end
function s.revtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.revop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
    end
end

-- Draw 2 if revived by own effect
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetFlagEffect(id)>0
end
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Draw(tp,2,REASON_EFFECT)
end
