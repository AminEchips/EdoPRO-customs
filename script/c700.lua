--Infernoble Knight Prince Roy
local s,id=GetID()
function s.initial_effect(c)
    -- Normal Summon: Equip Gwen and change Attribute
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_EQUIP+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.eqtg)
    e1:SetOperation(s.eqop)
    c:RegisterEffect(e1)

    -- Quick Effect: Redirect if targeted
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BECOME_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.tgcon)
    e2:SetTarget(s.tgtg)
    e2:SetOperation(s.tgop)
    c:RegisterEffect(e2)
end

-- Gwenhwyfar ID
s.listed_names={19748583}

-- EQUIP: Gwen from Deck
function s.eqfilter(c)
    return c:IsCode(19748583) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
            and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local ec=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
    if not ec then return end

    -- Try to simulate Gwen's own Equip effect (as if it was used)
    local effs={ec:GetCardEffect(75402014)} -- Standard Noble Arms equip effect
    for _,te in ipairs(effs) do
        local val=te:GetValue()
        if not val or val(c,ec,tp) then
            te:GetOperation()(ec,te:GetLabelObject(),tp,c)
            goto equipped
        end
    end

    -- Fallback: force equip with manual Equip Limit
    if Duel.Equip(tp,ec,c) then
        local e1=Effect.CreateEffect(ec)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EQUIP_LIMIT)
        e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        e1:SetValue(function(e,mc) return mc==e:GetOwner() end)
        ec:RegisterEffect(e1)
    end

    ::equipped::
    -- Change Attribute
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
    local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e2:SetValue(att)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
    c:RegisterEffect(e2)
end

-- REDIRECT TRIGGER: when targeted by attack or card effect
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsContains(e:GetHandler())
end
function s.spfilter(c,e,tp)
    return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.eqfilter2(c)
    return (c:IsSetCard(0x507a) or (c:IsSetCard(0x607a) and c:IsType(TYPE_EQUIP))) and not c:IsForbidden()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
            and Duel.IsExistingMatchingCard(s.eqfilter2,tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
    if not sc or Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)==0 then return end

    Duel.BreakEffect()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local ec=Duel.SelectMatchingCard(tp,s.eqfilter2,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
    if ec then
        Duel.Equip(tp,ec,sc)
        -- Optional redirect
        if re and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.ChangeTargetCard(ev,Group.FromCards(sc))
        end
    end
end
