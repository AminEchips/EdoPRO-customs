--Salamangreat Sunrise Panther
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.EnableCheckReincarnation(c)
    Xyz.AddProcedure(c,nil,8,2,nil,nil,Xyz.InfiniteMats)

    -- Detach to give all FIRE monsters +1000 ATK
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.atkcost)
    e1:SetOperation(s.atkop)
    c:RegisterEffect(e1)

    -- Special Summon from GY if sent there this turn
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE+PHASE_END)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.recon)
    e2:SetTarget(s.retg)
    e2:SetOperation(s.reop)
    c:RegisterEffect(e2)

    -- Grant effects if used as Xyz Material
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e3:SetRange(LOCATION_OVERLAY)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(function(e,c) return c:IsType(TYPE_XYZ) and c:HasOverlayCard(e:GetHandler()) end)
    e3:SetLabelObject(s.make_granted_effect(c))
    c:RegisterEffect(e3)
end
s.listed_series={0x119}

-- Cost for ATK boost
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

-- Boost all FIRE monsters
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

-- GY revival if sent this turn
function s.recon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
        and c:GetTurnID()==Duel.GetTurnCount()
end

function s.retg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCountFromEx(tp)>0 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_EXTRA)
end

function s.reop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local sc=Duel.CreateToken(tp,id)
    Duel.SpecialSummonStep(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
    Duel.Overlay(sc,Group.FromCards(c))
    sc:CompleteProcedure()
    Duel.SpecialSummonComplete()
end

-- Grant effect to Xyz monsters using this as material
function s.make_granted_effect(src)
    local e=Effect.CreateEffect(src)
    e:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e:SetCode(EVENT_ADJUST)
    e:SetRange(LOCATION_MZONE)
    e:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) end)
    e:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
        local c=e:GetHandler()
        if not c:IsHasEffect(id) then
            -- Gain 300 ATK per material
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
            e1:SetRange(LOCATION_MZONE)
            e1:SetValue(function(e) return e:GetHandler():GetOverlayCount()*300 end)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            c:RegisterEffect(e1)

            -- Destroy all Spell/Trap cards
            local e2=Effect.CreateEffect(c)
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
            c:RegisterEffect(e2)

            c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
        end
    end)
    return e
end
