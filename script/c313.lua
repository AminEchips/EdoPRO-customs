--The Darklord Azazel
local s,id=GetID()
function s.initial_effect(c)
    -- Xyz Summon procedure
    Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xef),8,2)
    c:EnableReviveLimit()

    -- Detach and target to send opponent's monster to GY
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1)
    e1:SetCost(s.tgcost)
    e1:SetTarget(s.tgtg)
    e1:SetOperation(s.tgop)
    c:RegisterEffect(e1)

    -- If LP paid for Darklord effect: target in GY, add to hand, then Fusion Summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_CHAIN_SOLVED)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.fuscon)
    e2:SetTarget(s.fustg)
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

-- EFFECT 1: Send to GY
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
    return chk==false or e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToGrave() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,nil) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoGrave(tc,REASON_EFFECT)
    end
end

-- EFFECT 2: Add target from GY then Fusion Summon
function s.fuscon(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    return rc and rc:IsSetCard(0xef) and rc:IsMonster() and re:IsActivated()
end
function s.fusfilter(c)
    return c:IsSetCard(0xef) and c:IsAbleToHand() and c:IsMonster()
end
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.fusfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.fusfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,s.fusfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end

    if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,tc)
        Duel.BreakEffect()

        -- Select a Fusion Monster from Extra Deck
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local fusion=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_EXTRA,0,1,1,nil,TYPE_FUSION):GetFirst()
        if not fusion then return end

        local chkf=tp
        local mg=Duel.GetFusionMaterial(tp)
        local matg=Duel.SelectFusionMaterial(tp,fusion,mg,nil)
        if #matg==0 then return end

        fusion:SetMaterial(matg)
        Duel.SendtoGrave(matg,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
        Duel.SpecialSummon(fusion,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
        fusion:CompleteProcedure()
    end
end

-- EFFECT 3: Return to Extra Deck
function s.recon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsReason(REASON_BATTLE+REASON_RELEASE) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKTOP,REASON_EFFECT)
end
