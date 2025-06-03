--Phantom Necrosoul Xyz Dragon
local s,id=GetID()
function s.initial_effect(c)
    --Xyz Summon
    Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),6,3)
    c:EnableReviveLimit()

    --Alternative Summon using any Rank 5 or lower DARK Xyz
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCondition(s.xyzcon)
    e0:SetTarget(s.xyztg)
    e0:SetOperation(s.xyzop)
    e0:SetValue(SUMMON_TYPE_XYZ)
    c:RegisterEffect(e0)

    --Battle Phase ATK gain + Double Attack
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.atkcon)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_EXTRA_ATTACK)
    e2:SetCondition(s.atkcon)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    --Floating effect (Mandatory)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_DISABLE+CATEGORY_SEARCH+CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCondition(s.thcon)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end

--Alternative Xyz Summon: any DARK Rank 5 or lower Xyz
function s.matfilter(c)
    return c:IsFaceup() and c:IsRankBelow(5) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_XYZ)
end
function s.xyzcon(e,c)
    if c==nil then return true end
    return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>-1
        and Duel.IsExistingMatchingCard(s.matfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    if chk==0 then return true end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local g=Duel.SelectMatchingCard(tp,s.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
    e:SetLabelObject(g:GetFirst())
    return true
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c)
    local tc=e:GetLabelObject()
    if not tc then return end
    local mg=tc:GetOverlayGroup()
    if #mg>0 then
        Duel.Overlay(c,mg)
    end
    c:SetMaterial(Group.FromCards(tc))
    Duel.Overlay(c,Group.FromCards(tc))
end

--Battle Phase condition
function s.atkcon(e)
    return Duel.IsBattlePhase()
end

--ATK gain: 200 per banished "The Phantom Knights" monster
function s.atkfilter(c)
    return c:IsSetCard(0x10db) and c:IsFaceup() and c:IsType(MONSTER)
end
function s.atkval(e,c)
    return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_REMOVED,0,nil)*200
end

--Floating: If Xyz Summoned & sent to GY by opponent
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_XYZ) and rp==1-tp and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    --Negate all face-up cards
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    for tc in g:Iter() do
        Duel.NegateRelatedChain(tc,RESET_TURN_SET)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        tc:RegisterEffect(e2)
    end

    --Search 1 "Rank-Up-Magic" from Deck
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg=Duel.SelectMatchingCard(tp,function(c) return c:IsSetCard(0x95) and c:IsAbleToHand() end,
        tp,LOCATION_DECK,0,1,1,nil)
    if #sg>0 then
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sg)
    end
end
