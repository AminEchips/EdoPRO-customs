--HERO Force!!
local s,id=GetID()
function s.initial_effect(c)
    --Activate and search Elemental HERO Neos or Neo-Spacian
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target1)
    e1:SetOperation(s.activate1)
    c:RegisterEffect(e1)
    --GY effect: Banish to add from GY to hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.target2)
    e2:SetOperation(s.activate2)
    c:RegisterEffect(e2)
end

s.listed_names={89943723} -- Elemental HERO Neos
s.listed_series={0x1f,0x8,0x3008} -- Neo-Spacian, HERO, Elemental HERO

-- First effect: Search Neos or Neo-Spacian monster
function s.filter1(c)
    return c:IsAbleToHand() and (c:IsCode(89943723) or (c:IsSetCard(0x1f) and c:IsMonster()))
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate1(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- Second effect: Add from GY to hand
function s.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x1f) and c:IsType(TYPE_MONSTER)
end
function s.filter2(c,att)
    return c:IsSetCard(0x8) and c:IsAttribute(att) and c:IsType(TYPE_EFFECT) and c:IsAbleToHand()
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
            and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_GRAVE,0,1,nil,ATTRIBUTE_ALL)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
    e:SetLabel(tc:GetAttribute())
    e:SetLabelObject(tc)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
    local att=e:GetLabel()
    local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_GRAVE,0,1,1,nil,att)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

