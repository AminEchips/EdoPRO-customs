--Elemental HERO Titantron
local s,id=GetID()
function s.initial_effect(c)
    -- Trigger on banish: Choose 1 effect
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_LEAVE_GRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_REMOVE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.tg)
    e1:SetOperation(s.op)
    c:RegisterEffect(e1)
end

-- Spell that mentions "Elemental HERO" and is Settable
function s.spellfilter(c)
    return c:IsType(TYPE_SPELL) and c:IsSSetable() and c:ListsArchetype(0x3008)
end

-- Banished E-HERO that can be returned to hand
function s.hero_filter(c)
    return c:IsFaceup() and c:IsSetCard(0x8) and c:IsAbleToHand()
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local b1=Duel.IsExistingMatchingCard(s.spellfilter,tp,LOCATION_GRAVE,0,1,nil)
    local b2=c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    if chk==0 then return b1 or b2 end
    local op=0
    if b1 and b2 then
        op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
    elseif b1 then
        op=0
        Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
    else
        op=1
        Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
    end
    e:SetLabel(op)
    if op==0 then
        Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
    else
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    end
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local op=e:GetLabel()
    if op==0 then
        -- Set 1 Spell from GY
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
        local g=Duel.SelectMatchingCard(tp,s.spellfilter,tp,LOCATION_GRAVE,0,1,1,nil)
        if #g>0 then
            Duel.SSet(tp,g:GetFirst())
        end
    else
        -- Special Summon self
        if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
            -- If banished for Fusion Summon of HERO
            local rc=c:GetReasonCard()
            if rc and rc:IsType(TYPE_FUSION) and rc:IsSetCard(0x8) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
                local g=Duel.SelectMatchingCard(tp,s.hero_filter,tp,LOCATION_REMOVED,0,1,1,nil)
                if #g>0 then
                    Duel.SendtoHand(g,nil,REASON_EFFECT)
                    Duel.ConfirmCards(1-tp,g)
                end
            end
        end
    end
end
