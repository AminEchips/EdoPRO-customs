--Evil Awakening
local s,id=GetID()
function s.initial_effect(c)
    --Activate and Special Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

s.listed_series={0x6008}
s.listed_names={94820406} -- Dark Fusion

function s.spfilter(c,e,tp)
    return c:IsSetCard(0x6008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.thfilter(c)
    return c:IsCode(94820406) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
        local dg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
        if #dg>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local tg=dg:Select(tp,1,1,nil)
            Duel.SendtoHand(tg,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,tg)
        end
    end
end
