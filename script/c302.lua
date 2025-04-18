--Darklord Sammael
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon restriction
    c:SetSPSummonOnce(id)

    -- Search "Darklord Morningstar" or card that mentions it
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.thcost)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- Copy "Darklord" Spell/Trap in GY (Ixchel style)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.cpcost)
    e2:SetTarget(s.cptg)
    e2:SetOperation(s.cpop)
    c:RegisterEffect(e2)
end
s.listed_names={25451652} -- Darklord Morningstar
s.listed_series={0xef} -- Darklord

-- Discard this card as cost
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsDiscardable() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end

-- Search filter: "Morningstar" or cards that list it (not self)
function s.thfilter(c)
    return (c:IsCode(25451652) or c:ListsCode(25451652)) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- Copy cost
function s.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,1000) end
    Duel.PayLPCost(tp,1000)
end

-- Copy target
function s.cpfilter(c)
    return c:IsSetCard(0xef) and c:IsSpellTrap() and c:IsAbleToDeck() and c:CheckActivateEffect(false,true,false)~=nil
end

function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.cpfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.cpfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end

-- Copy operation (Ixchel-style)
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
    if not te then return end
    local tg=te:GetTarget()
    local op=te:GetOperation()

    if tg then tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,1) end
    Duel.BreakEffect()
    tc:CreateEffectRelation(te)
    Duel.BreakEffect()
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    for etc in aux.Next(g) do
        etc:CreateEffectRelation(te)
    end
    if op then op(te,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,1) end
    tc:ReleaseEffectRelation(te)
    for etc in aux.Next(g) do
        etc:ReleaseEffectRelation(te)
    end
    Duel.BreakEffect()
    Duel.SendtoDeck(te:GetHandler(),nil,2,REASON_EFFECT)
end


