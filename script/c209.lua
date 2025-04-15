-- Elemental HERO Titantron
local s,id=GetID()
function s.initial_effect(c)
    -- Set 1 Spell that mentions "Elemental HERO" in its text
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_LEAVE_GRAVE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_REMOVE)
    e1:SetRange(LOCATION_REMOVED)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.setcon)
    e1:SetTarget(s.settg)
    e1:SetOperation(s.setop)
    c:RegisterEffect(e1)

    -- Special Summon itself, then if banished for HERO Fusion, add 1 banished HERO to hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_REMOVE)
    e2:SetRange(LOCATION_REMOVED)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end
s.listed_series={0x8}

-- Effect 1: Set Spell from GY
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsContains(e:GetHandler())
end
function s.setfilter(c)
    return c:IsType(TYPE_SPELL) and c:IsSSetable() and c:IsAbleToSet() and c:CheckText("Elemental HERO")
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SSet(tp,g:GetFirst())
    end
end

-- Effect 2: Special Summon and optional add
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsContains(e:GetHandler())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.thfilter(c)
    return c:IsSetCard(0x8) and c:IsAbleToHand() and c:IsFaceup()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) > 0 then
        -- Only check for fusion summon with HERO monster
        if bit.band(r,REASON_FUSION)~=0 and re and re:GetHandler():IsSetCard(0x8) then
            local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_REMOVED,0,nil)
            if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
                local sg=g:Select(tp,1,1,nil)
                Duel.SendtoHand(sg,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,sg)
            end
        end
    end
end


