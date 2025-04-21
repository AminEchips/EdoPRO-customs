--Starry Knight Hope
local s,id=GetID()
function s.initial_effect(c)
    -- Activate (Continuous Spell)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    -- Monsters you control can't be negated by DARK monsters
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_INACTIVATE)
    e1:SetRange(LOCATION_SZONE)
    e1:SetValue(s.effectfilter)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_NEGATE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetValue(s.effectfilter)
    c:RegisterEffect(e2)

    -- Opponent's monsters become DARK if you control Level 7 LIGHT Dragon
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTargetRange(0,LOCATION_MZONE)
    e3:SetCondition(s.darkcon)
    e3:SetValue(ATTRIBUTE_DARK)
    c:RegisterEffect(e3)

    -- Target 1 banished LIGHT Fairy: Special Summon or send to GY
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_SZONE)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetCountLimit(1,id)
    e4:SetCondition(s.thcon)
    e4:SetTarget(s.thtg)
    e4:SetOperation(s.thop)
    c:RegisterEffect(e4)
end
s.listed_series={0x15b}

-- Prevent negation by opponent's DARK monsters
function s.effectfilter(e,ct)
    local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
    local tc=te:GetHandler()
    return tp~=e:GetHandlerPlayer() and tc:IsAttribute(ATTRIBUTE_DARK)
end

-- Control Level 7 LIGHT Dragon
function s.darkfilter(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(7) and c:IsRace(RACE_DRAGON)
end
function s.darkcon(e)
    return Duel.IsExistingMatchingCard(s.darkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

-- Third effect condition
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.darkfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- Target 1 banished LIGHT Fairy
function s.thfilter(c,e,tp)
    return c:IsFaceup() and c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT) and
        (c:IsAbleToGrave() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.thfilter(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))==0) then
            Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
        elseif tc:IsAbleToGrave() then
            Duel.SendtoGrave(tc,REASON_EFFECT)
        end
    end
end
