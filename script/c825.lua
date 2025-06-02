--The Phantom Knights of Flaming Shurikens
local s,id=GetID()
function s.initial_effect(c)
    Pendulum.AddProcedure(c)

    -- Pendulum Effect 1: Shuffle 3 banished "Phantom Knights" into Deck
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1,id)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetTarget(s.pztg1)
    e1:SetOperation(s.pzop1)
    c:RegisterEffect(e1)

    -- Pendulum Effect 2: On Pendulum Summon of "The Phantom Knights" monster, destroy this + opponent monster
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_PZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET)
    e2:SetCondition(s.pzcond2)
    e2:SetTarget(s.pztg2)
    e2:SetOperation(s.pzop2)
    c:RegisterEffect(e2)

    -- Monster Effect: On summon, recycle 3 DARK Warriors
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TODECK+CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(1,{id,2})
    e3:SetTarget(s.montg)
    e3:SetOperation(s.monop)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e4)
end

-- Pendulum Shuffle 3
function s.pkfilter(c)
    return c:IsSetCard(0x10db) and c:IsAbleToDeck()
end
function s.pztg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    if chk==0 then return Duel.IsExistingTarget(s.pkfilter,tp,LOCATION_REMOVED,0,3,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.pkfilter,tp,LOCATION_REMOVED,0,3,3,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
end
function s.pzop1(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e)
    if #g==3 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end

-- Pendulum Summon reaction
function s.cfilter(c,tp)
    return c:IsSetCard(0x10db) and c:IsType(TYPE_MONSTER) and c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsControler(tp)
end
function s.pzcond2(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.pzmonfilter(c)
    return c:IsFaceup() and c:IsLevelBelow(4)
end
function s.pztg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.pzmonfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.pzmonfilter,tp,0,LOCATION_MZONE,1,nil) and e:GetHandler():IsDestructable() end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,s.pzmonfilter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g+e:GetHandler(),2,0,0)
end
function s.pzop2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 and tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end

-- Monster effect: recycle 3 DARK Warrior monsters
function s.monfilter(c)
    return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToDeck()
end
function s.montg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.monfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.monfilter,tp,LOCATION_REMOVED,0,3,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.monfilter,tp,LOCATION_REMOVED,0,3,3,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
end
function s.monop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetTargetCards(e)
    if #tg~=3 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local gy=Group.CreateGroup()
    local sg=tg:Select(tp,1,1,nil)
    local card=sg:GetFirst()
    if card then
        if Duel.SendtoGrave(card,REASON_EFFECT)~=0 then
            tg:RemoveCard(card)
            Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        end
    end
end
