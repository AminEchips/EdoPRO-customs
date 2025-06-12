--Salamangreat Sunrise Panther
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.EnableCheckReincarnation(c)
    Xyz.AddProcedure(c,nil,8,2,nil,nil,99)

    -- Detach to boost all FIRE monsters
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.atkcost)
    e1:SetOperation(s.atkop)
    c:RegisterEffect(e1)

    -- Reborn from GY if sent this turn
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

    -- Grant effects to Xyz monsters that use this as material
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e3:SetRange(LOCATION_OVERLAY)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(function(e,c) return c:IsType(TYPE_XYZ) and c:HasOverlayCard(e:GetHandler()) end)
    e3:SetLabelObject(s.make_granted_effect(c))
    c:RegisterEffect(e3)
end
s.listed_series={0x119}

-- Cost: detach 1
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

-- Effect: all FIRE monsters gain 1000 ATK
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

-- Condition: was sent to GY this turn
function s.recon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY+REASON_EFFECT+REASON_BATTLE)
        and c:GetTurnID()==Duel.GetTurnCount()
end

function s.retg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCountFromEx(tp)>0 and Duel.IsPlayerCanSpecialSummon(tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_EXTRA)
end

-- Operation: Special Summon from Extra Deck using itself as material (treated as Xyz Summon)
function s.reop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=Duel.CreateToken(tp,id)
    Duel.SpecialSummonStep(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
    Duel.Overlay(tc,Group.FromCards(c))
    tc:CompleteProcedure()
    Duel.SpecialSummonComplete()
end

-- EFFECT: grant ATK + S/T wipe when used as material
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

            -- Destroy all Spells/Traps
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
