--Chapel Legacy of the Noble Arms
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.desfilter(c,e)
    return c:IsFaceup() and c:IsSetCard(0x207a) and c:IsDestructable() and c~=e:GetHandler()
end

function s.artorigusfilter(c)
    return c:IsSetCard(0xa7) and c:IsType(TYPE_MONSTER)
end

function s.thfilter(c)
    return c:IsCode(46008667) and c:IsAbleToHand() -- Noble Arms - Excaliburn
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_SZONE,0,nil,e)
    if #g==0 or not Duel.IsPlayerCanDraw(tp,2) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local dg=g:Select(tp,1,1,nil)
    if Duel.Destroy(dg,REASON_EFFECT)>0 then
        Duel.Draw(tp,2,REASON_EFFECT)

        if Duel.IsExistingMatchingCard(s.artorigusfilter,tp,LOCATION_GRAVE,0,1,nil)
            and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
            and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local thg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
            if #thg>0 then
                Duel.SendtoHand(thg,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,thg)
            end
        end
    end
end
