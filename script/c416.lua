--Starry Knight Sabatiel
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Fusion Material Check
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_MATERIAL_CHECK)
    e0:SetValue(function(e,c)
        local mat=c:GetMaterial()
        e:GetHandler():SetMaterial(mat)
    end)
    c:RegisterEffect(e0)

    -- Fusion Summon procedure: 1 Level 7 LIGHT Dragon + 1 or more LIGHT Fairy
    Fusion.AddProcMixRep(c,true,true,s.fairyfilter,1,99,s.dragonfilter)

    -- On Special Summon: Send 1 LIGHT Fairy or Dragon to GY
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.tgtg)
    e1:SetOperation(s.tgop)
    c:RegisterEffect(e1)

    -- Quick Effect: Tribute this card to destroy all cards + set 1 from GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.setcon)
    e2:SetCost(s.setcost)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)
end

s.listed_series={0x15b}

-- Fusion Material Filters
function s.dragonfilter(c)
    return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(7)
end
function s.fairyfilter(c)
    return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT)
end

-- Effect 1: Send LIGHT Fairy or Dragon to GY
function s.tgfilter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and (c:IsRace(RACE_FAIRY) or c:IsRace(RACE_DRAGON)) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end

-- Effect 2: Fusion Summoned using 4 materials with different names
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local mat=c:GetMaterial()
    if not mat then return false end
    local codes={}
    for tc in aux.Next(mat) do
        local code=tc:GetCode()
        if codes[code] then return false end
        codes[code]=true
    end
    return #codes>=4
end

function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsReleasable() end
    Duel.Release(c,REASON_COST)
end

function s.setfilter(c)
    return c:IsSetCard(0x15b) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    if Duel.Destroy(g,REASON_EFFECT)~=0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
        local sc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
        if sc then Duel.SSet(tp,sc) end

        -- Cannot Special Summon Sabatiel again this turn
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTarge
