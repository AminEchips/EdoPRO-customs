--Elemental HERO Titantron
local s,id=GetID()
function s.initial_effect(c)
  -- Limit: Only one of either effect per turn (once each effect per turn, but not both in the same turn)
  -- Effect 1: Set 1 "Elemental HERO" Spell from GY when banished
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_LEAVE_GRAVE)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetRange(LOCATION_REMOVED)       -- activated from banished zone
  e1:SetCountLimit(1,id)             -- once per turn, shared with other effect
  e1:SetTarget(s.settg)
  e1:SetOperation(s.setop)
  c:RegisterEffect(e1)
  -- Effect 2: Special Summon self from banish, then optionally add banished "Elemental HERO"
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetRange(LOCATION_REMOVED)       -- activated from banished zone
  e2:SetCountLimit(1,id)             -- once per turn, shared (same id as e1)
  e2:SetTarget(s.sptg)
  e2:SetOperation(s.spop)
  c:RegisterEffect(e2)
  -- Continuous effect to flag if used as Fusion material for a HERO monster (while banished)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
  e3:SetCode(EVENT_BE_MATERIAL)
  e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
  e3:SetCondition(s.regcon)
  e3:SetOperation(s.regop)
  c:RegisterEffect(e3)
end

-- Filter for Spell in GY that mentions "Elemental HERO" in its text
function s.setfilter(c)
  return c:IsType(TYPE_SPELL) and c:IsSSetable() 
    and (aux.IsCodeListed(c,21844576) or aux.IsCodeListed(c,58932615))  -- mentions "Elemental HERO Avian" or "Burstinatrix" in text&#8203;:contentReference[oaicite:11]{index=11}
end

-- Target: choose 1 appropriate Spell in GY to Set
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then 
    return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.setfilter(chkc) 
  end
  if chk==0 then 
    return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) 
  end
  -- Select target Spell from GY
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
  local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)  -- indicate card leaving GY
end

-- Operation: Set the targeted Spell to the field
function s.setop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then
    Duel.SSet(tp, tc)               -- Set the Spell to your Spell/Trap zone&#8203;:contentReference[oaicite:12]{index=12}
    -- (No further restrictions; the card can be activated if its type allows)
  end
end

-- Target: prepare to Special Summon Titantron from banished zone
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
  local c=e:GetHandler()
  if chk==0 then
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
      and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
  end
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)  -- Titantron will be Special Summoned from banish
  -- We don't target the banished "Elemental HERO" to add here, as that happens on resolution if applicable
end

-- Operation: Special Summon Titantron, then optionally add banished "Elemental HERO" monster to hand
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
  if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
    -- Successfully Special Summoned from banish
    if c:GetFlagEffect(id)>0 then  -- check if it was banished for a HERO Fusion Summon (flag set)
      -- Filter for banished "Elemental HERO" monsters that can be added
      local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_REMOVED,0,nil)
      if #g>0 and Duel.SelectYesNo(tp, aux.Stringid(id,2)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=g:Select(tp,1,1,nil)      -- select 1 banished Elemental HERO
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp, sg)
      end
    end
  end
end

-- Filter for banished Elemental HERO monsters that can be added to hand
function s.thfilter(c)
  return c:IsFaceup() and c:IsSetCard(0x3008) and c:IsAbleToHand()    -- Elemental HERO archetype monsters banished&#8203;:contentReference[oaicite:13]{index=13}
end

-- Condition: Titantron used as material for a HERO Fusion
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
  return (r & REASON_FUSION)~=0 and eg and eg:IsExists(Card.IsSetCard,1,nil,0x8)
        -- ^ Titantron became material for a Fusion Summon (r includes REASON_FUSION) 
        -- and the Fusion monster is a "HERO" (has set code 0x8)&#8203;:contentReference[oaicite:14]{index=14}.
end

-- Operation: register a flag if banished for HERO Fusion (so we know to allow the add-back)
function s.regop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  -- Only set flag if this card itself is banished as a result of the Fusion (i.e. left the field/GY)
  if c:IsLocation(LOCATION_REMOVED) then
    c:RegisterFlagEffect(id, RESET_EVENT+RESETS_STANDARD, 0, 0)
  end
end
