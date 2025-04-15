--Elemental HERO Titantron
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon or Set Spell on banish (choice effect)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_LEAVE_GRAVE+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_REMOVE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.bantg)
    e1:SetOperation(s.banop)
    c:RegisterEffect(e1)
end

-- Check if a spell with "Elemental HERO" in text is settable or if self is summonable
function s.spellfilter(c)
    return c:IsType(TYPE_SPELL) and c:IsSSetable() and c:ListsArchetype(0x3008)
end
function s.ehero_filter(c)
    return c:IsFaceup() and c:IsSetCard(0x8) and c:IsAbleToHand()
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local b1=Duel.IsExistingMatchingCard(s.spellfilter,tp,LOCATION_DECK,0,1,nil)
    local b2=c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    if chk==0 then return b1 or b2 end
    local op=0
    if b1 and b2 then
        op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
    elseif b1 then
        op=0
        Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))
    else
        op=1
        Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
    end
    e:SetLabel(op)
    if op==0 then
        Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_DECK)
    else
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    end
end

function s.banop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local op=e:GetLabel()
    if op==0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
        local g=Duel.SelectMatchingCard(tp,s.spellfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SSet(tp,g:GetFirst())
        end
    else
        if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and c:IsPreviousLocation(LOCATION_GRAVE+LOCATION_HAND+LOCATION_DECK) then
            -- Fusion summon check
            local rc=c:GetReasonCard()
            if rc and rc:IsType(TYPE_FUSION) and rc:IsSetCard(0x8) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
                local g=Duel.SelectMatchingCard(tp,s.ehero_filter,tp,LOCATION_REMOVED,0,1,1,nil)
                if #g>0 then
                    Duel.SendtoHand(g,nil,REASON_EFFECT)
                    Duel.ConfirmCards(1-tp,g)
                end
            end
        end
    end
end
