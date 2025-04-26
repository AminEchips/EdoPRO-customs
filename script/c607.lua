--Assault Blackwing - Kunifusa the White Rainbow
local s,id=GetID()
s.listed_series={SET_BLACKWING,0x33} -- Blackwing archetype
local s,id=GetID()
s.listed_series={SET_BLACKWING,0x33}
function s.initial_effect(c)
    -- Synchro Summon procedure
    Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
    c:EnableReviveLimit()
    -- Become Tuner if Synchro Summoned using a Blackwing
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_TYPE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.tncon)
    e1:SetValue(TYPE_TUNER)
    c:RegisterEffect(e1)
    -- Shuffle 1 banished Blackwing into Deck and burn
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.tdtg)
    e2:SetOperation(s.tdop)
    c:RegisterEffect(e2)
end

----------------------------------------------------------
-- Tuner condition
----------------------------------------------------------
function s.tncon(e)
    local c=e:GetHandler()
    local sumtype=c:GetSummonType()
    return sumtype==SUMMON_TYPE_SYNCHRO and c:GetMaterial():IsExists(Card.IsSetCard,1,nil,0x33)
end

----------------------------------------------------------
-- Shuffle 1 banished Blackwing into Deck and burn
----------------------------------------------------------
function s.tdfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x33) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
            Duel.Damage(1-tp,300,REASON_EFFECT)
        end
    end
end
