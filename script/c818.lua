--Raider's Emblem
local s,id=GetID()
function s.initial_effect(c)
    -- This card is always treated as "Rank-Up-Magic"
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_SETCODE)
    e0:SetValue(0x95) -- Rank-Up-Magic
    c:RegisterEffect(e0)

    -- Activate effect: Xyz Summon Dark Requiem using 2 targets
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- If destroyed by card effect: search Memory of Requiem
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

-- Valid first target (must control it)
function s.mainfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_XYZ) and (
        c:IsSetCard(0xba) or      -- Raidraptor
        c:IsSetCard(0x10db) or    -- The Phantom Knights
        c:IsSetCard(0x2073))      -- Xyz Dragon
end

-- Second target: any Xyz Monster owned (field or GY)
function s.extra_filter(c,tp)
    return c:IsType(TYPE_XYZ) and c:IsControler(tp)
end

-- Targeting
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    if chk==0 then
        return Duel.IsExistingTarget(s.mainfilter,tp,LOCATION_MZONE,0,1,nil)
            and Duel.IsExistingTarget(s.extra_filter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil,tp)
            and Duel.IsExistingMatchingCard(s.drfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g1=Duel.SelectTarget(tp,s.mainfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g2=Duel.SelectTarget(tp,s.extra_filter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,1,g1:GetFirst(),tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

-- Summon target filter
function s.drfilter(c,e,tp)
    return c:IsCode(1621413) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end

-- Activation
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    if #g<2 then return end
    local tc1,tc2=g:GetFirst(),g:GetNext()
    if not (tc1:IsRelateToEffect(e) and tc2:IsRelateToEffect(e)) then return end
    if tc1:IsControler(1-tp) then tc1,tc2=tc2,tc1 end
    if not (tc1:IsControler(tp) and tc2:IsControler(tp)) then return end

    local xyz=Duel.GetFirstMatchingCard(s.drfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
    if xyz then
        local gmat=Group.FromCards(tc1,tc2)
        local mats=Group.CreateGroup()
        for mc in aux.Next(gmat) do
            local og=mc:GetOverlayGroup()
            mats:Merge(og)
        end
        xyz:SetMaterial(gmat)
        Duel.Overlay(xyz,mats)
        Duel.Overlay(xyz,gmat)

        if Duel.SpecialSummon(xyz,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
            xyz:CompleteProcedure()

            -- While it's on field: restrict attacks
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_CANNOT_ATTACK)
            e1:SetTargetRange(LOCATION_MZONE,0)
            e1:SetTarget(function(e,c)
                return not (c:IsRankAbove(5) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_XYZ))
            end)
            e1:SetLabelObject(xyz)
            e1:SetCondition(function(e) return e:GetLabelObject():IsOnField() end)
            e1:SetReset(RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD)
            Duel.RegisterEffect(e1,tp)
        end
    end
end

-- If this card is destroyed by a card effect
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return r&REASON_EFFECT~=0
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thfilter(c)
    return c:IsCode(841) and c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFirstMatchingCard(s.thfilter,tp,LOCATION_DECK,0,nil)
    if g then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
