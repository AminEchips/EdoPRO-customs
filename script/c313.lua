--The Darklord Azazel
local s,id=GetID()
function s.initial_effect(c)
    -- Xyz Summon procedure
    Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xef),8,2)
    c:EnableReviveLimit()

    -- Detach and target to send opponent's monster to GY (targeting is part of cost)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.tgcost)
    e1:SetTarget(s.tgtg)
    e1:SetOperation(s.tgop)
    c:RegisterEffect(e1)

    -- If LP paid for Darklord effect: target, then Fusion Summon using hand/field
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_CHAIN_SOLVED)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.fuscon)
    e2:SetCost(s.fuscost)
    e2:SetOperation(s.fusop)
    c:RegisterEffect(e2)

    -- If destroyed or tributed: return to Extra Deck
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCondition(s.recon)
    e3:SetOperation(s.retop)
    c:RegisterEffect(e3)
end
s.listed_series={0xef}

-- Effect 1: Detach and target to send to GY
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
        and Duel.IsExistingTarget(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,nil) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.Target(tp,Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,1,nil)
    e:SetLabelObject(g:GetFirst())
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk) return true end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoGrave(tc,REASON_EFFECT)
    end
end

-- Effect 2: LP paid, retrieve Darklord + Fusion Summon
function s.fuscon(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    return rc and rc:IsSetCard(0xef) and rc:IsMonster()
        and re:IsActivated() and Duel.GetLP(tp)<Duel.GetLP(tp)+1000
end
function s.fusfilter(c)
    return c:IsSetCard(0xef) and c:IsAbleToHand()
end
function s.fuscost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingTarget(s.fusfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.fusfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    e:SetLabelObject(g:GetFirst())
end
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if tc and tc:IsAbleToHand() then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local fusion=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_EXTRA,0,1,1,nil,TYPE_FUSION):GetFirst()
    if fusion then
        local mat=Duel.SelectTarget(tp,aux.FilterBoolFunction(Card.IsType,TYPE_MONSTER),tp,LOCATION_HAND+LOCATION_MZONE,0,2,2,nil)
        if #mat==2 then
            Duel.SendtoGrave(mat,REASON_MATERIAL+REASON_FUSION)
            Duel.SpecialSummon(fusion,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
            fusion:CompleteProcedure()
        end
    end
end

-- Effect 3: return to Extra Deck if destroyed or tributed
function s.recon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsReason(REASON_BATTLE+REASON_EFFECT+REASON_RELEASE) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKTOP,REASON_EFFECT)
end
