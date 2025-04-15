-- HERO Enforcement
local s,id=GetID()
function s.initial_effect(c)
    -- Target and destroy monsters (based on different HERO attributes)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- GY effect: Quick Effect to add Polymerization or Miracle Fusion from GY to hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(aux.bfgcost)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetTarget(s.gytg)
    e2:SetOperation(s.gyop)
    c:RegisterEffect(e2)
end

s.listed_names={24094653, 45906428}
s.listed_series={0x8}

function s.attrfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER)
end

function s.countAttributes(tp)
    local g=Duel.GetMatchingGroup(s.attrfilter,tp,LOCATION_MZONE,0,nil)
    local attrs={}
    local count=0
    for tc in aux.Next(g) do
        local attr=tc:GetAttribute()
        if not attrs[attr] then
            attrs[attr]=true
            count=count+1
        end
    end
    return count
end

function s.monfilter(c)
    return c:IsMonster()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local ct=s.countAttributes(tp)
    if chkc then return chkc:IsOnField() and s.monfilter(chkc) end
    if chk==0 then return ct>0 and Duel.IsExistingTarget(s.monfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,s.monfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end

function s.thfilter(c)
    return c:IsAbleToHand() and (c:IsCode(24094653) or c:IsCode(45906428))
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.thfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    end
end

s.listed_series={0x3008}
