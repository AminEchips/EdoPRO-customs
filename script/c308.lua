--Azazel, Darklord of Lost Paradise
local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
    c:EnableReviveLimit()
    Fusion.AddProcMixN(c,true,true,s.matfilter,3)

    -- ATK Boost for all DARK Fairy monsters
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_FAIRY))
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)

    -- Send all opponent's monsters to GY if "Darklord" Spell/Trap is shuffled
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_DECK)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.tgcon)
    e2:SetTarget(s.tgtg)
    e2:SetOperation(s.tgop)
    c:RegisterEffect(e2)

    -- Quick Effect: Tag out and summon a Level 10 or lower Darklord
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e3:SetCountLimit(1,{id,1})
    e3:SetCondition(s.sscon)
    e3:SetCost(s.sscost)
    e3:SetTarget(s.sstg)
    e3:SetOperation(s.ssop)
    c:RegisterEffect(e3)
end
s.listed_names={313}
s.listed_series={0xef}

function s.matfilter(c)
    return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_DARK)
end

function s.atkval(e,c)
    return Duel.GetMatchingGroupCount(Card.IsAttribute,c:GetControler(),LOCATION_GRAVE,0,nil,ATTRIBUTE_DARK)*100
end

function s.tgfilter(c,tp)
    return c:IsPreviousLocation(LOCATION_GRAVE) and c:IsSetCard(0xef) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsControler(tp)
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.tgfilter,1,nil,tp)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,nil) end
    local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end

function s.sscon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetMaterial():IsExists(Card.IsCode,1,nil,313)
end
function s.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,1000) end
    Duel.PayLPCost(tp,1000)
end
function s.ssfilter(c,e,tp)
    return c:IsSetCard(0xef) and c:IsLevelBelow(10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) and e:GetHandler():IsAbleToExtra() end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)>0 then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end
