--Starry Knight Hope
local s,id=GetID()
function s.initial_effect(c)
    --Continuous Effect: Your monsters are unaffected by negation from DARK monsters
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_DISABLE)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(s.indtg)
    c:RegisterEffect(e1)

    --Continuous Effect: Opponent's monsters become DARK if you control Level 7 LIGHT Dragon
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(0,LOCATION_MZONE)
    e2:SetCondition(s.attrcon)
    e2:SetValue(ATTRIBUTE_DARK)
    c:RegisterEffect(e2)

    --Ignition: Target 1 banished LIGHT Fairy, Special Summon or send to GY
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end
s.listed_series={0x15b}

-- Effect 1 condition target
function s.indtg(e,c)
    return c:IsFaceup()
end

-- Effect 2 condition: You control Level 7 LIGHT Dragon
function s.cfilter(c)
    return c:IsFaceup() and c:IsLevel(7) and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.attrcon(e)
    return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

-- Effect 3: Ignition condition: You control Level 7 LIGHT Dragon
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- Effect 3: Target 1 banished LIGHT Fairy
function s.spfilter(c,e,tp)
    return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsFaceup() and (c:IsAbleToGrave() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    Duel.HintSelection(Group.FromCards(tc))
    local opt=0
    if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
        opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2)) -- Special Summon or send to GY
    else
        opt=1
    end
    if opt==0 then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    else
        Duel.SendtoGrave(tc,REASON_EFFECT)
    end
end
