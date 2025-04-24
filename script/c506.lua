--Altergeist Critial Error
local s,id=GetID()
function s.initial_effect(c)
    --Activate and send 1 Link to GY, then summon equal Link Rating
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.tgtg)
    e1:SetOperation(s.tgop)
    c:RegisterEffect(e1)

    -- GY effect: negate + nuke
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_NEGATE+CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.negcon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)
end

s.listed_series={0x103}

-- First Effect: Send 1 Altergeist Link and Summon equal Link value
function s.tgfilter(c,tp)
    return c:IsFaceup() and c:IsSetCard(0x103) and c:IsType(TYPE_LINK) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,c:GetLink())
end
function s.spfilter(c,linkval)
    return c:IsSetCard(0x103) and c:IsType(TYPE_LINK) and c:GetLink()<=3 and c:IsCanBeSpecialSummoned(nil,0,tp,false,false)
        and linkval>=c:GetLink()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsType(TYPE_LINK) then
        local lvr=tc:GetLink()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,function(c) return s.spfilter(c,lvr) end,tp,LOCATION_GRAVE,0,1,lvr,nil)
        if #g>0 then
            local ct=0
            for sc in g:Iter() do
                ct=ct+sc:GetLink()
            end
            if ct==lvr then
                Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
            end
        end
    end
end

-- Second Effect: GY Negate + Field Send
function s.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x103) and c:IsType(TYPE_LINK) and c:GetLink()>=4
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsBattlePhase() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
        and ep~=tp and Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) then
        local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
        if #g>0 then
            Duel.SendtoGrave(g,REASON_EFFECT)
        end
    end
end
