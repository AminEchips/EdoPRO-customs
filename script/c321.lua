--Darklord Sword of Rebellion
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
s.listed_names={25451652} -- Darklord Morningstar

function s.fusfilter(c,e,tp)
    return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
end
function s.matfilter(c)
    return c:IsFaceup() and c:IsAbleToGrave()
end
function s.morningfilter(c)
    return c:IsCode(25451652) and c:IsFaceup()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local opt1=Duel.IsExistingMatchingCard(s.morningfilter,tp,LOCATION_MZONE,0,1,nil)
    local opt2=Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) and Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_MZONE,0,1,nil)
    if chk==0 then return opt1 or opt2 end

    local op=0
    if opt1 and opt2 then
        op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1)) -- "Boost Morningstar" / "Fusion Summon"
    elseif opt1 then
        Duel.SelectOption(tp,aux.Stringid(id,0))
        op=0
    else
        Duel.SelectOption(tp,aux.Stringid(id,1))
        op=1
    end
    e:SetLabel(op)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local op=e:GetLabel()
    if op==0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local tc=Duel.SelectMatchingCard(tp,s.morningfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
        if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
            -- Gains 500 ATK
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(500)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
            -- Cannot be destroyed by opponent's card effects
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
            e2:SetValue(s.indval)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e2)
        end
    elseif op==1 then
        -- Fusion Summon using only your monsters on field
        local mat=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil)
        if #mat==0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local fusion=Duel.SelectMatchingCard(tp,s.fusfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
        if fusion then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local fusmat=mat:Select(tp,1,99,nil)
            Duel.SendtoGrave(fusmat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
            Duel.SpecialSummon(fusion,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
            fusion:CompleteProcedure()
        end
    end
end

function s.indval(e,re,tp)
    return tp~=e:GetHandlerPlayer()
end
