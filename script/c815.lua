--Raidraptor - Reactor
local s,id=GetID()
function s.initial_effect(c)
    -- Activation effect (optional discard and summon)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Draw 1 if DARK monster is Special Summoned by Rank-Up-Magic
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.drcon)
    e2:SetTarget(s.drtg)
    e2:SetOperation(s.drop)
    c:RegisterEffect(e2)

    -- Destruction replacement for Rank 4 DARK
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_DESTROY_REPLACE)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTarget(s.reptg)
    e3:SetValue(s.repval)
    e3:SetOperation(s.repop)
    c:RegisterEffect(e3)
end

-- Filter: Raidraptor
function s.rrfilter(c,e,tp)
    return c:IsSetCard(0xba) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- Filter: The Phantom Knights
function s.pkfilter(c,e,tp)
    return c:IsSetCard(0x10db) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- On activation: optional discard to summon RR + PK
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end

    if Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST,nil)==0 then return end

    local g1=Duel.GetMatchingGroup(s.rrfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
    local g2=Duel.GetMatchingGroup(s.pkfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)

    local ct=0
    if #g1>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg1=g1:Select(tp,1,1,nil)
        if #sg1>0 and Duel.SpecialSummonStep(sg1:GetFirst(),0,tp,tp,false,false,POS_FACEUP) then
            ct=ct+1
        end
    end
    if #g2>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg2=g2:Select(tp,1,1,nil)
        if #sg2>0 and Duel.SpecialSummonStep(sg2:GetFirst(),0,tp,tp,false,false,POS_FACEUP) then
            ct=ct+1
        end
    end
    if ct>0 then
        Duel.SpecialSummonComplete()
    end
end

-- Draw if DARK monster(s) are Special Summoned by a Rank-Up-Magic
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    return re and re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsSetCard(0x95)
        and eg:IsExists(function(c) return c:IsAttribute(ATTRIBUTE_DARK) and c:IsSummonPlayer(tp) end, 1, nil)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Draw(p,d,REASON_EFFECT)
end

-- Replacement condition: if Rank 4 DARK monster would be destroyed
function s.repfilter(c,tp)
    return c:IsFaceup() and c:IsControler(tp)
        and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevel(4)
        and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return not c:IsStatus(STATUS_DESTROY_CONFIRMED)
            and c:IsAbleToGrave()
            and eg:IsExists(s.repfilter,1,nil,tp)
    end
    return Duel.SelectEffectYesNo(tp,c,96)
end
function s.repval(e,c)
    return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
