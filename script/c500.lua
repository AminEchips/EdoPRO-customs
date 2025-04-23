--Altergeist Backuploader
local s,id=GetID()
function s.initial_effect(c)
    -- Link Summon Procedure
    c:EnableReviveLimit()
    Link.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x103),1,1)

    -- Effect on Link Summon: Pay 500 LP to Normal Summon Altergeist
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.nscon)
    e1:SetCost(s.nscost)
    e1:SetTarget(s.nstg)
    e1:SetOperation(s.nsop)
    c:RegisterEffect(e1)

    -- GY effect: Tribute 1 Altergeist to revive this card, banish when it leaves
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

-- e1: Normal Summon Altergeist on Link Summon
function s.nscon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.nscost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,500) end
    Duel.PayLPCost(tp,500)
end
function s.nsfilter(c)
    return c:IsSetCard(0x103) and c:IsSummonable(true,nil)
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
    local g=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        Duel.Summon(tp,tc,true,nil)
    end
end

-- e2: Revive by tributing Altergeist
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x103) end
    local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x103)
    Duel.Release(g,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        -- banish when leaves field
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
        e1:SetValue(LOCATION_REMOVED)
        c:RegisterEffect(e1,true)
    end
end
