--Raidraptor - Virus Vulture
local s,id=GetID()
function s.initial_effect(c)
    -- Effect 1: If a Raidraptor (not itself) is sent to GY, SS this and optionally get Fusion Parasite
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_TO_GRAVE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Effect 2: If this card is sent to the GY, SS 1 DARK from hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)
end
s.listed_series={0xba} -- Raidraptor
s.listed_names={06205579} -- Fusion Parasite

-- EFFECT 1: Trigger when a "Raidraptor" (not itself) you control is sent to GY
function s.cfilter(c,tp)
    return c:IsSetCard(0xba) and c:IsMonster() and c:IsControler(tp)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.fusionfilter(c,e,tp)
    return c:IsCode(06205579) and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end

    -- Optional: add/summon Fusion Parasite
    if Duel.IsExistingMatchingCard(s.fusionfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
        and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
        local g=Duel.SelectMatchingCard(tp,s.fusionfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
        local tc=g:GetFirst()
        if tc then
            local op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4)) -- 0 = Add, 1 = Summon
            if op==0 then
                Duel.SendtoHand(tc,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,tc)
            else
                Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
            end
        end
    end
end

-- EFFECT 2: If sent to GY, SS 1 DARK from hand
function s.handfilter(c,e,tp)
    return c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.handfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.handfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
