--Darklord Azazel, the Neonate
local s,id=GetID()
function s.initial_effect(c)
    --Cannot be Special Summoned more than once per turn
    c:SetSPSummonOnce(id)

    --Effect on Normal or Special Summon: Choose 1 of 2 effects
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)

    -- ATK/DEF boost if Morningstar is on the field (unused: now in effect choice)
end

s.listed_names={25451652}
s.listed_series={0xef}

-- Option filter
function s.spfilter(c,e,tp)
    return c:IsSetCard(0xef) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.morningstarfilter(c)
    return c:IsCode(25451652)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
    local b2=Duel.IsExistingMatchingCard(s.morningstarfilter,tp,LOCATION_MZONE,0,1,nil)
    if chk==0 then return b1 or b2 end

    local opt=0
    if b1 and b2 then
        opt=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
    elseif b1 then
        opt=0
    else
        opt=1
    end
    e:SetLabel(opt)
    if opt==0 then
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
    end
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local opt=e:GetLabel()
    local c=e:GetHandler()
    if opt==0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        end
    else
        if c:IsFaceup() and c:IsRelateToEffect(e) then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_SET_ATTACK_FINAL)
            e1:SetValue(c:GetBaseAttack()*2)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
            c:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
            e2:SetValue(c:GetBaseDefense()*2)
            c:RegisterEffect(e2)
        end
    end
end
