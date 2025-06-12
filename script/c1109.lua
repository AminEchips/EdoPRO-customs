--Salamangreat Sunrise Panther
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.EnableCheckReincarnation(c)
    Xyz.AddProcedure(c,nil,8,2,nil,nil,Xyz.InfiniteMats)

    -- Give all FIRE monsters +1000 ATK
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.atkcost)
    e1:SetOperation(s.atkop)
    c:RegisterEffect(e1)

    -- End Phase: Rank-Up into another copy from GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE+PHASE_END)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.rkcon)
    e2:SetTarget(s.rktg)
    e2:SetOperation(s.rkop)
    c:RegisterEffect(e2)
end

s.listed_series={0x119}

-- ATK Cost
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

-- FIRE monsters gain 1000 ATK
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsAttribute,tp,LOCATION_MZONE,0,nil,ATTRIBUTE_FIRE)
    for tc in g:Iter() do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(1000)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
    end
end

-- Check if sent to GY this turn
function s.rkcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_ONFIELD) and c:GetTurnID()==Duel.GetTurnCount()
end

function s.rktg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCountFromEx(tp,tp,c)>0
        and Duel.IsExistingMatchingCard(s.rkfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
    Duel.SetTargetCard(c)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.rkfilter(c,e,tp,mc)
    return c:IsCode(id) and mc:IsCanBeXyzMaterial(c)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end

function s.rkop(e,tp,eg,ep,ev,re,r,rp)
    local c=Duel.GetFirstTarget()
    if not c or not c:IsRelateToEffect(e) or Duel.GetLocationCountFromEx(tp,tp,c)<=0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sc=Duel.SelectMatchingCard(tp,s.rkfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c):GetFirst()
    if not sc then return end

    local overlay=c:GetOverlayGroup()
    if #overlay>0 then
        Duel.Overlay(sc,overlay)
    end

    sc:SetMaterial(Group.FromCards(c))
    Duel.Overlay(sc,Group.FromCards(c))
    if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
        sc:CompleteProcedure()

        -- Gain +300 ATK per material
        local e1=Effect.CreateEffect(sc)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e1:SetRange(LOCATION_MZONE)
        e1:SetValue(function(e) return e:GetHandler():GetOverlayCount()*300 end)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        sc:RegisterEffect(e1)

        -- Gain effect: destroy all Spell/Trap cards
        local e2=Effect.CreateEffect(sc)
        e2:SetDescription(aux.Stringid(id,2))
        e2:SetCategory(CATEGORY_DESTROY)
        e2:SetType(EFFECT_TYPE_IGNITION)
        e2:SetRange(LOCATION_MZONE)
        e2:SetCountLimit(1,{id,2})
        e2:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) end)
        e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
            if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
            local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
            Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
        end)
        e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
            local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
            Duel.Destroy(g,REASON_EFFECT)
        end)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        sc:RegisterEffect(e2)
    end
end
