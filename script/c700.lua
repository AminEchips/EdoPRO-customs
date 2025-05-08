--Infernoble Knight Prince Roy
local s,id=GetID()
function s.initial_effect(c)
    -- Normal Summon: Send Gwen to GY + Attribute change
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.gwytg)
    e1:SetOperation(s.gwyop)
    c:RegisterEffect(e1)

    -- When targeted (attack or effect): Special Summon + optional equip and redirect
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

-- IDs
s.listed_names={19748583}
s.listed_series={0x507a,0x607a,0x149}

-- EFFECT 1: Send Gwen to GY + Attribute change
function s.eqfilter(c)
    return c:IsCode(19748583) and c:IsAbleToGrave()
end
function s.gwytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.gwyop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local tc=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
    if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and c:IsFaceup() and c:IsRelateToEffect(e) then
        -- Change Attribute
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
        local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
        e1:SetValue(att)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e1)
    end
end

-- EFFECT 2: When targeted by attack or effect
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not eg:IsContains(c) then return false end
    -- For attack or effect
    return (re~=nil or Duel.GetAttacker()==e:GetHandler())
end
function s.spfilter(c,e,tp)
    return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.eqgyfilter(c)
    return (c:IsSetCard(0x507a) or (c:IsSetCard(0x607a) and c:IsType(TYPE_EQUIP))) and not c:IsForbidden()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
    if not sc or Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)==0 then return end

    -- If it's a "Roland" monster, equip from GY
    if sc:IsSetCard(0x149) and Duel.IsExistingMatchingCard(s.eqgyfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
        if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
            local eqc=Duel.SelectMatchingCard(tp,s.eqgyfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
            if eqc and Duel.Equip(tp,eqc,sc) then
                -- Equip Limit
                local e1=Effect.CreateEffect(eqc)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_EQUIP_LIMIT)
                e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                e1:SetValue(function(e,mc) return mc==e:GetOwner() end)
                eqc:RegisterEffect(e1)
            end
        end
    end

    -- Redirect target if possible
    if re and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
        local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
        if g and g:IsContains(e:GetHandler()) and sc:IsCanBeEffectTarget(re) then
            if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
                Duel.ChangeTargetCard(ev,Group.FromCards(sc))
            end
        end
    end

    -- If it was an attack, redirect it
    if Duel.GetAttacker() and Duel.GetAttackTarget()==e:GetHandler() and Duel.GetAttacker():IsControler(1-tp) and sc:IsAttackable() then
        if Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
            Duel.CalculateDamage(Duel.GetAttacker(),sc)
        end
    end
end
