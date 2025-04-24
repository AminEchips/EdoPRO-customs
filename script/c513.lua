--Altergeist Halbenkaia
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Link Summon
    Link.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x103),2,nil,s.lcheck)
    
    -- Extra attacks based on unique "Altergeist" Traps in GY
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EXTRA_ATTACK)
    e1:SetValue(s.extraval)
    c:RegisterEffect(e1)

    -- Destroy a card if a Trap is sent to GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.descon)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)

    -- Set 1 Altergeist Trap when sent from field to GY
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end)
    e3:SetTarget(s.settg)
    e3:SetOperation(s.setop)
    c:RegisterEffect(e3)
end
s.listed_series={0x103}

function s.lcheck(g,lc,sumtype,tp)
    return g:IsExists(Card.IsSetCard,1,nil,0x103)
end

-- Extra attacks
function s.extraval(e,c)
    local g=Duel.GetMatchingGroup(Card.IsSetCard,c:GetControler(),LOCATION_GRAVE,0,nil,0x103)
    local codes={}
    local count=0
    for tc in aux.Next(g) do
        if tc:IsType(TYPE_TRAP) and not codes[tc:GetCode()] then
            codes[tc:GetCode()] = true
            count = count + 1
        end
    end
    return math.max(0,count-1)
end

-- Destroy condition
function s.cfilter(c,tp)
    return c:IsType(TYPE_TRAP) and c:IsPreviousControler(tp) and not c:IsReason(REASON_REPLACE)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp) and not Duel.CheckEvent(EVENT_DAMAGE_STEP)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
    if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end

-- Set trap
function s.setfilter(c)
    return c:IsSetCard(0x103) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD,0,1,nil)
    end
    Duel.SetOperationInfo(0,0,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD,0,1,1,nil)
    if #g>0 then
        Duel.SSet(tp,g)
    end
end
