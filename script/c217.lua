--Elemental HERO Surge Breaker
local s,id=GetID()
function s.initial_effect(c)
    --Must be Fusion Summoned
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,21844576,20721928,86188410) -- Avian + Sparkman + Wildheart

    -- Search O - Oversoul and maybe Hero Flash!!
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.thcon)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- Tribute to summon E-HERO Normal and prevent response to direct attacks
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end
s.listed_names={63703130,22020907} -- O - Oversoul, Hero Flash!!

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    -- Add "O - Oversoul"
    local g1=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_DECK,0,nil,63703130)
    if #g1>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=g1:Select(tp,1,1,nil)
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sg)
    end
    -- If 3 or more non-Polymerization/Fusion spells in GY with different names
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil)
    local names={}
    for tc in g:Iter() do
        names[tc:GetCode()]=true
    end
    if table.getn(names)>=3 then
        local flash=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,00191749)
        if #flash>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local f=flash:Select(tp,1,1,nil)
            Duel.SendtoHand(f,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,f)
        end
    end
end

function s.spfilter(c)
    return c:IsType(TYPE_SPELL) and c:IsType(TYPE_NORMAL) and not c:IsCode(24094653)
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end

function s.spfilter2(c,e,tp)
    return c:IsRace(RACE_WARRIOR) and c:IsSetCard(0x3008) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        -- Opponent cannot activate cards/effects when your monster attacks directly
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_ACTIVATE)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(0,1)
        e1:SetValue(function(e,re,tp) return re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) end)
        e1:SetCondition(function(e) return Duel.GetAttacker():IsControler(tp) and Duel.GetAttackTarget()==nil end)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end
