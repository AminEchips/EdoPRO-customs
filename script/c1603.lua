--Pferd of the Nordic Beasts
local s,id=GetID()
function s.initial_effect(c)
    -- e1: If added to hand (except by drawing), Special Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_TO_HAND)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon_hand)
    e1:SetTarget(s.sptg_hand)
    e1:SetOperation(s.spop_hand)
    c:RegisterEffect(e1)

    -- e2: If used for Synchro Summon of an Aesir, Special Summon from GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.spcon_gy)
    e2:SetTarget(s.sptg_gy)
    e2:SetOperation(s.spop_gy)
    c:RegisterEffect(e2)

    -- e3: If it battled a monster with equal or higher Level, reduce its ATK
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_DAMAGE_STEP_END)
    e3:SetCountLimit(1,{id,2})
    e3:SetCondition(s.atkcon)
    e3:SetOperation(s.atkop)
    c:RegisterEffect(e3)
end

-- e1 condition: added to hand, but not drawn
function s.spcon_hand(e,tp,eg,ep,ev,re,r,rp)
    return not e:GetHandler():IsReason(REASON_DRAW)
end
function s.sptg_hand(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop_hand(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- e2 condition: used for Aesir Synchro
function s.spcon_gy(e,tp,eg,ep,ev,re,r,rp)
    return r==REASON_SYNCHRO and e:GetHandler():GetReasonCard():IsSetCard(0x4b)
end
function s.sptg_gy(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop_gy(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- e3 condition: battled a monster with equal or higher Level
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local c = e:GetHandler()
    local tc = c:GetBattleTarget()
    return tc and tc:IsRelateToBattle() and tc:IsLevelAbove(c:GetLevel())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c = e:GetHandler()
    local tc = c:GetBattleTarget()
    if tc and tc:IsRelateToBattle() and tc:IsFaceup() and tc:IsLevelAbove(1) then
        local atkdrop = tc:GetLevel() * 100
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(-atkdrop)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
    end
end
