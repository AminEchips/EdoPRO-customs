--Raidraptor - Virus Vulture
local s,id=GetID()
function s.initial_effect(c)
    -- Effect 1: If RR sent to GY you control (not during Damage Step), SS this and optionally add/summon Fusion Parasite
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_TO_GRAVE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon1)
    e1:SetTarget(s.sptg1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)

    -- Effect 2: If this card is sent to GY, SS 1 DARK from hand
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

-- Effect 1: Condition - a Raidraptor you controlled was sent to GY (not during damage step)
function s.cfilter(c,tp)
    return c:IsPreviousControler(tp) and c:IsSetCard(0xba) and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
    return not Duel.IsDamageStep() and eg:IsExists(s.cfilter,1,nil,tp)
end

function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.fusionfilter(c,e,tp)
    return c:IsCode(06205579) and c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spop1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        -- Optional: Add/Summon Fusion Parasite
        if Duel.IsExistingMatchingCard(s.fusionfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
            and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
            local g=Duel.SelectMatchingCard(tp,s.fusionfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
            local tc=g:GetFirst()
            if tc then
                local op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4)) -- Add or Special Summon
                if op==0 then
                    Duel.SendtoHand(tc,nil,REASON_EFFECT)
                    Duel.ConfirmCards(1-tp,tc)
                else
                    Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
                end
            end
        end
    end
end

-- Effect 2: If this card is sent to the GY, Special Summon 1 DARK from hand
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
