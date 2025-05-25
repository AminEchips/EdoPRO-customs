--Pendulum Effect: Optional once-per-turn effect damage prevention
function s.initial_effect(c)
	Pendulum.AddProcedure(c)

	-- Optional damage prevention
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_PZONE)
	e1:SetOperation(s.ask_protect)
	c:RegisterEffect(e1)

	-- Apply damage prevention
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(1,1)
	e2:SetValue(s.damval)
	c:RegisterEffect(e2)

	local e3=e2:Clone()
	e3:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e3)
end

-- Store protection flag
function s.ask_protect(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>0 then return end
	if Duel.GetCurrentPhase()==PHASE_DAMAGE or Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL then return end
	local ex,_,_,cp,val=Duel.GetOperationInfo(ev,CATEGORY_DAMAGE)
	if not ex or val<=0 then return end

	-- Ask if you want to protect
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3)) -- Choose who to protect
	local sel=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5)) -- 0 = you, 1 = opponent
	local protect_p=(sel==0) and tp or 1-tp
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)

	-- Store temporary protection tied to chain and player
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(id)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetLabel(cid,protect_p)
	e1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e1,tp)

	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end

-- Cancel damage if matches stored protection
function s.damval(e,re,val,r,rp,rc)
	if (r & REASON_EFFECT)==0 then return val end
	local cid=Duel.GetCurrentChain()
	for _,eff in ipairs({Duel.GetPlayerEffect(e:GetHandlerPlayer(),id)}) do
		local ecid,eplayer=eff:GetLabel()
		if ecid==cid and eplayer==e:GetHandlerPlayer() then
			return 0
		end
	end
	return val
end
