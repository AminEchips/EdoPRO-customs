--Noble Knight Raidan
local s,id=GetID()
function s.initial_effect(c)
    -- Attribute copy effect (continuous)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e0:SetRange(LOCATION_MZONE)
    e0:SetValue(s.attval)
    c:RegisterEffect(e0)

    -- Special Summon and equip a Warrior from hand (Quick Effect)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Search 1 "Noble Knight" monster when equipped
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_EQUIP)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

s.listed_series={0x107a}

-- EFFECT 0: Attribute becomes the same as the monster it's equipped with (if exactly 1)
function s.attval(e,c)
    local eg=c:GetEquipGroup()
    local mg=eg:Filter(Card.IsType,nil,TYPE_MONSTER)
    if #mg==1 then return ATTRIBUTE_FIRE end
    return 0
end

-- EFFECT 1: When your opponent activates a monster effect (Quick), Special Summon + Equip from hand
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end

    -- Equip 1 Warrior from hand (optional)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    if not Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_HAND,0,1,nil,c,tp) then return end
    if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
        local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_HAND,0,1,1,nil,c,tp)
        local ec=g:GetFirst()
        if ec and Duel.Equip(tp,ec,c) then
            -- Treat as Equip Spell + ATK boost
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_EQUIP)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(500)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            ec:RegisterEffect(e1)

            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_EQUIP_LIMIT)
            e2:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            e2:SetValue(function(e,mc) return mc==e:GetOwner() end)
            ec:RegisterEffect(e2)
        end
    end
end
function s.eqfilter(c,mc,tp)
    return c:IsRace(RACE_WARRIOR) and not c:IsForbidden()
end

-- EFFECT 2: If this card becomes equipped, search 1 Noble Knight monster
function s.thfilter(c)
    return c:IsSetCard(0x107a) and c:IsMonster() and c:IsAbleToHand()
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
