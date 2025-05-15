--Swordsoul Chancellor - Ganjiang
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Synchro Summon procedure
    aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_TUNER),aux.NonTuner(nil),1)
    
    -- Lists "Fallen of Albaz"
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_ADD_CODE)
    e0:SetValue(68468459) -- Fallen of Albaz
    c:RegisterEffect(e0)

    -- Banish target at End Phase if still on field
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.rmcon)
    e1:SetTarget(s.rmtg)
    e1:SetOperation(s.rmop)
    c:RegisterEffect(e1)

    -- Fusion Summon if Special Summon from hand/GY while you control Fusion/Synchro
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.fuscon)
    e2:SetTarget(s.fustg)
    e2:SetOperation(s.fusop)
    c:RegisterEffect(e2)
end

function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,68468459),tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsOnField() then
        -- Create delayed banish effect
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE+PHASE_END)
        e1:SetCountLimit(1)
        e1:SetLabelObject(tc)
        e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
            local tc=e:GetLabelObject()
            if tc and tc:IsOnField() then
                Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
            end
        end)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end

function s.fuscon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(function(c) return c:IsPreviousLocation(LOCATION_HAND+LOCATION_GRAVE) end,1,nil)
        and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE,0,1,nil,TYPE_FUSION+TYPE_SYNCHRO)
end
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanSpecialSummonMonster(tp,0,0,0x81,0,0,8,RACE_FUSION,ATTRIBUTE_LIGHT) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
    local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
    if sg:GetCount()<2 or Duel.GetLocationCountFromEx(tp,tp,sg)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
    local mat=sg:Select(tp,2,2,nil)
    if #mat<2 then return end
    Duel.SendtoGrave(mat,REASON_MATERIAL+REASON_FUSION)
    -- Assuming a valid Level 8 or lower Fusion exists that can be summoned
    local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_EXTRA,0,nil,TYPE_FUSION)
    local sc=g:Select(tp,1,1,nil):GetFirst()
    if sc then
        Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
        sc:CompleteProcedure()
    end
end
