--Salamangreat Salamandra
local s,id=GetID()
function s.initial_effect(c)
    s.listed_series={0x119}

    -- Reveal this card in hand to summon another Salamangreat
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.hspcost)
    e1:SetTarget(s.hsptg)
    e1:SetOperation(s.hspop)
    c:RegisterEffect(e1)

    -- On Special Summon: Increase/Decrease Level by 2
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+100)
    e2:SetOperation(s.lvop)
    c:RegisterEffect(e2)

    -- If FIRE Link leaves field by opponent, revive + negate others
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,id+200)
    e3:SetCondition(s.negcon)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)
end

-- Effect 1: Reveal as cost
function s.hspcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return not e:GetHandler():IsPublic() end
    Duel.ConfirmCards(1-tp,e:GetHandler())
end

function s.hspfilter(c,e,tp,lr)
    return c:IsSetCard(0x119) and c:IsLevelBelow(lr) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local lr=0
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    for tc in g:Iter() do
        if tc:IsType(TYPE_LINK) then lr=lr+tc:GetLink() end
    end
    if chk==0 then return Duel.IsExistingMatchingCard(s.hspfilter,tp,LOCATION_HAND,0,1,nil,e,tp,lr) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

function s.hspop(e,tp,eg,ep,ev,re,r,rp)
    local lr=0
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    for tc in g:Iter() do
        if tc:IsType(TYPE_LINK) then lr=lr+tc:GetLink() end
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,s.hspfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,lr)
    if #sg>0 then
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- Effect 2: Level change on Special Summon
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
    local op=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5)) -- 0 = +2, 1 = -2
    local val = (op==0) and 2 or -2
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_LEVEL)
    e1:SetValue(val)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
    c:RegisterEffect(e1)
end

-- Effect 3: Trigger on FIRE Link monster leaving field
function s.cfilter(c,tp)
    return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
        and c:IsType(TYPE_LINK) and c:IsAttribute(ATTRIBUTE_FIRE)
        and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()~=tp
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp)
end

function s.negfilter(c,e,tp,maxlink)
    return c:IsSetCard(0x119) and c:IsType(TYPE_LINK) and c:IsLinkBelow(maxlink)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local maxlink = 0
    for tc in eg:Iter() do
        if tc:IsPreviousControler(tp) and tc:IsType(TYPE_LINK) and tc:IsAttribute(ATTRIBUTE_FIRE)
            and tc:IsPreviousLocation(LOCATION_MZONE) and tc:IsReason(REASON_EFFECT) and tc:GetReasonPlayer()~=tp then
            maxlink = math.max(maxlink, tc:GetLink())
        end
    end
    e:SetLabel(maxlink)
    if chk==0 then
        return e:GetHandler():IsAbleToRemoveAsCost()
            and Duel.IsExistingMatchingCard(s.negfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,maxlink)
    end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local link=e:GetLabel()
    if not Duel.Remove(c,POS_FACEUP,REASON_EFFECT) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.negfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,link)
    local tc=g:GetFirst()
    if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
        local g2=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,tc)
        for mc in g2:Iter() do
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            mc:RegisterEffect(e1)
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            mc:RegisterEffect(e2)
        end
    end
end
