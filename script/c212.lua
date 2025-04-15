--Hope for Neo Space
local s,id=GetID()
function s.initial_effect(c)
    --Effect 1: Gain LP
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_RECOVER)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.lpcon)
    e1:SetTarget(s.lptg)
    e1:SetOperation(s.lpop)
    c:RegisterEffect(e1)

    --Effect 2: Destroy 1 card
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.descon)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)

    --Effect 3: Contact-like Fusion Summon
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_ACTIVATE)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetCountLimit(1,{id,2})
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end
s.listed_names={89943723,24094653} -- Neos, Polymerization
s.listed_series={0x1f, 0x3008} -- Neo-Spacian, Elemental HERO

-- Effect 1: LP Recovery
function s.lpfilter(c)
    return c:IsFaceup() and (c:IsSetCard(0x3008) or c:IsSetCard(0x1f))
end
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.lpfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=Duel.GetMatchingGroupCount(s.lpfilter,tp,LOCATION_MZONE,0,nil)
    if chk==0 then return ct>0 end
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct*1000)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
    local ct=Duel.GetMatchingGroupCount(s.lpfilter,tp,LOCATION_MZONE,0,nil)
    if ct>0 then
        Duel.Recover(tp,ct*1000,REASON_EFFECT)
    end
end

-- Effect 2: Destroy if control Neos
function s.neosfilter(c)
    return c:IsFaceup() and c:IsCode(89943723)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.neosfilter,tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end

-- Effect 3: Contact-like Fusion Summon
function s.spfilter(c)
    return c:IsType(TYPE_FUSION) and c:IsSetCard(0x3008) and c:IsLevel(12)
        and c:IsCanBeSpecialSummoned(nil,0,tp,true,true)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local neos=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,89943723)
    local spacians=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_MZONE,0,nil,0x1f)
    local poly=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_HAND,0,1,nil,24094653)
    if chk==0 then
        return poly and neos and #spacians>=2 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local poly=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_HAND,0,1,1,nil,24094653)
    local neos=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,89943723)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local spacians=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_MZONE,0,2,2,nil,0x1f)
    if #poly==1 and #neos==1 and #spacians==2 then
        local mat=Group.CreateGroup()
        mat:Merge(poly)
        mat:Merge(neos)
        mat:Merge(spacians)
        if Duel.SendtoGrave(mat,REASON_EFFECT)==#mat then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil)
            if #g>0 then
                Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
            end
        end
    end
end
