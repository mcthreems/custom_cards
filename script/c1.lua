--Junior Journey Format
--Scripted by threems
--note: Card Advance seems to let you get a regular normal summon with this active
local s,id=GetID()

function s.initial_effect(c)
	aux.EnableExtraRules(c,s,s.init)
end
function s.init(c)
	--Tribute Summon Optional
	local limeff=Effect.CreateEffect(c)
	limeff:SetDescription(aux.Stringid(57,0))
	limeff:SetType(EFFECT_TYPE_FIELD)
	limeff:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	limeff:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	limeff:SetCondition(s.ntcon)
	--summon any level
	for _,proc in ipairs({EFFECT_SET_PROC,EFFECT_SUMMON_PROC}) do
		local leff=limeff:Clone()
		leff:SetCode(proc)
		Duel.RegisterEffect(leff,0)
	end
	limeff:Reset()
	--prevent tribute summons except for monsters whose effects explicitly allow/require it
	local notribsum=Effect.CreateEffect(c)
	notribsum:SetType(EFFECT_TYPE_FIELD)
	notribsum:SetCode(EFFECT_CANNOT_SUMMON)
	notribsum:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	notribsum:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	notribsum:SetTarget(s.sumtg)
	Duel.RegisterEffect(notribsum,0)
	--same but for tribute sets
	local notribset=notribsum:Clone()
	notribset:SetCode(EFFECT_CANNOT_MSET)
	notribset:SetTarget(s.settg)
	Duel.RegisterEffect(notribset,0)
	--Limit 1 Spell Activation
	local e1=Effect.GlobalEffect()
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(1,1)
	e1:SetValue(s.aclimit)
	Duel.RegisterEffect(e1,0)
	local e2=Effect.GlobalEffect()
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAINING)
	e2:SetOperation(s.aclimit1)
	Duel.RegisterEffect(e2,0)
	--Limit 1 Trap Activation
	local e4=e1:Clone()
	e4:SetValue(s.aclimit3)
	Duel.RegisterEffect(e4,0)
	local e5=e2:Clone()
	e5:SetOperation(s.aclimit4)
	Duel.RegisterEffect(e5,0)
	--Limit 1 Set S/T per turn
	local e7=Effect.GlobalEffect()
	e7:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e7:SetCode(EVENT_SSET)
	e7:SetOperation(s.checkop)
	Duel.RegisterEffect(e7,0)
	local e8=Effect.GlobalEffect()
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetCode(EFFECT_CANNOT_SSET)
	e8:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_IGNORE_IMMUNE)
	e8:SetTargetRange(1,1)
	e8:SetTarget(s.setlimit)
	Duel.RegisterEffect(e8,0)
	--No Hand Size Limit
	local e9=Effect.GlobalEffect()
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetCode(EFFECT_HAND_LIMIT)
	e9:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_IGNORE_IMMUNE)
	e9:SetTargetRange(1,1)
	e9:SetValue(999)
	Duel.RegisterEffect(e9,0)
	--No First Turn Draw
	local e10=e9:Clone()
	e10:SetCode(EFFECT_DRAW_COUNT)
	e10:SetTargetRange(1,1)
	e10:SetCondition(s.nodraw)
	e10:SetValue(0)
	Duel.RegisterEffect(e10,0)
	--Cannot Activate Quick-Play Spells outside of own MP or as Chain Link 2 or Higher
	local e11=Effect.GlobalEffect()
	e11:SetType(EFFECT_TYPE_FIELD)
	e11:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_IGNORE_IMMUNE)
	e11:SetCode(EFFECT_CANNOT_ACTIVATE)
	e11:SetTargetRange(1,1)
	e11:SetValue(s.quicklimit)
	Duel.RegisterEffect(e11,0)
	--Cannot respond with quick-plays (in progress)
	local reseff=Effect.CreateEffect(c)
	reseff:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	reseff:SetOperation(s.sumsuc)
	for _,event in ipairs({EVENT_SUMMON_SUCCESS,EVENT_DAMAGE}) do
		local reff=reseff:Clone()
		reseff:SetCode(event)
		Duel.RegisterEffect(reff,0)
	end
	reseff:Reset()
end
function s.ntcon(e,c,minc)
	if c==nil then return true end
	local _,max=c:GetTributeRequirement()
	return max>0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.advf_filter(c,tp) --filter for Advance Force functionality
	return c:IsLevelAbove(5) and (c:IsControler(tp) or c:IsFaceup())
end
function s.sumtg(e,c,tp,sumtp)
	for _,exceps in ipairs({75285069,22996376,36354007,95701283,51192573,
	                   40921744,6849042,58554959,5186893,70969517,
	                   6614221,55690251,88071625,72258771,78651105,
	                   10026986,81254059,3825890,41753322,10060427,
	                   5186893,20003527,42685062,15605085,28348537,
	                   53199020,58494728,15545291,61231400,25524823,
	                   23689697,96470883,69327790,69230391,87602890,
	                   87288189,96570609,23064604,42880485,3912064,
	                   76930964,30907810,5008836,61391302,53318263}) do --listing card ids for cards like Moisture Creature
		if c:IsCode(exceps) then return false end
	end

	if c:IsHasEffect(EFFECT_LIMIT_SUMMON_PROC) then return false end

	--Code for Advance Force
	local tploc=c:GetControler()
	if c:IsLevelAbove(7) and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,38589847),tploc,LOCATION_SZONE,0,1,nil) then
		local mg=Duel.GetMatchingGroup(s.advf_filter,tploc,LOCATION_MZONE,LOCATION_MZONE,nil,tploc)
		if Duel.CheckTribute(c,1,1,mg) then return false end
	end

	return (sumtp&SUMMON_TYPE_TRIBUTE)==SUMMON_TYPE_TRIBUTE
end
function s.settg(e,c,tp,sumtp)
	for _,exceps in ipairs({22996376}) do --listing card ids for cards like Moisture Creature, but for sets
		if c:IsCode(exceps) then return false end
	end

	if c:IsHasEffect(EFFECT_LIMIT_SET_PROC) then return false end

	return (sumtp&SUMMON_TYPE_TRIBUTE)==SUMMON_TYPE_TRIBUTE
end
function s.acfilter(c)
	return c:GetFlagEffect(EFFECT_TYPE_ACTIVATE+TYPE_SPELL)>0 or c:GetFlagEffect(EFFECT_TYPE_ACTIVATE+TYPE_PENDULUM)>1
end
function s.acfilterpend(c)
	return c:GetFlagEffect(EFFECT_TYPE_ACTIVATE+TYPE_PENDULUM)>1
end
function s.aclimit(e,re,tp)
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	local tpe=re:GetActiveType()
	if tpe==TYPE_SPELL or tpe==TYPE_SPELL+TYPE_QUICKPLAY or tpe==TYPE_SPELL+TYPE_CONTINUOUS or tpe==TYPE_SPELL+TYPE_EQUIP or tpe==TYPE_SPELL+TYPE_FIELD or tpe==TYPE_SPELL+TYPE_RITUAL then --and re:GetHandler():IsLocation(LOCATION_HAND)
		return Duel.IsExistingMatchingCard(s.acfilter,tp,0xff,0,1,nil)
	elseif re:IsActiveType(TYPE_SPELL) then
		return Duel.IsExistingMatchingCard(s.acfilterpend,tp,0xff,0,1,nil)
	end
	return false
end
function s.aclimit1(e,tp,eg,ep,ev,re,r,rp)
	local tpe=re:GetActiveType()
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and (tpe==TYPE_SPELL or tpe==TYPE_SPELL+TYPE_QUICKPLAY or tpe==TYPE_SPELL+TYPE_CONTINUOUS or tpe==TYPE_SPELL+TYPE_EQUIP or tpe==TYPE_SPELL+TYPE_FIELD or tpe==TYPE_SPELL+TYPE_RITUAL) then --and re:GetHandler():IsPreviousLocation(LOCATION_HAND)
		re:GetHandler():RegisterFlagEffect(EFFECT_TYPE_ACTIVATE+TYPE_SPELL,RESET_PHASE+PHASE_END,0,1)
	elseif re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) then
		re:GetHandler():RegisterFlagEffect(EFFECT_TYPE_ACTIVATE+TYPE_PENDULUM,RESET_PHASE+PHASE_END,0,1)
	end
end
function s.acfilter2(c)
	return c:GetFlagEffect(EFFECT_TYPE_ACTIVATE+TYPE_TRAP)>0
end
function s.aclimit3(e,re,tp)
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	if re:IsActiveType(TYPE_TRAP) then --and re:GetHandler():IsLocation(LOCATION_HAND)
		return Duel.IsExistingMatchingCard(s.acfilter2,tp,0xff,0,1,nil)
	end
	return false
end
function s.aclimit4(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP) then --and re:GetHandler():IsPreviousLocation(LOCATION_HAND)
		re:GetHandler():RegisterFlagEffect(EFFECT_TYPE_ACTIVATE+TYPE_TRAP,RESET_PHASE+PHASE_END,0,1)
	end
end
function s.aclimit5(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP) then --and re:GetHandler():IsPreviousLocation(LOCATION_HAND)
		re:GetHandler():ResetFlagEffect(EFFECT_TYPE_ACTIVATE+TYPE_TRAP)
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if re~=nil then
		if re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	end
	local hg=eg:Filter(Card.IsPreviousLocation,nil,LOCATION_HAND)
	if #hg>0 then
		if hg:IsExists(Card.IsType,1,nil,TYPE_SPELL) then
			Duel.RegisterFlagEffect(rp,TYPE_SPELL,RESET_PHASE+PHASE_END,0,1)
		end
		if hg:IsExists(Card.IsType,1,nil,TYPE_TRAP) then
			Duel.RegisterFlagEffect(rp,TYPE_TRAP,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
function s.setlimit(e,c,tp)
	--If it's not a main phase no need to restrict sets
	if Duel.GetCurrentPhase()~=PHASE_MAIN1 and Duel.GetCurrentPhase()~=PHASE_MAIN2 then return false end

	--similarly, if the current chain is above 0 no need to restrict sets
	if Duel.GetCurrentChain()>0 then return false end

	return c:IsLocation(LOCATION_HAND) and (Duel.GetFlagEffect(tp,TYPE_SPELL)>0
		or Duel.GetFlagEffect(tp,TYPE_TRAP)>0)
end
function s.nodraw(e,c,tp)
	return Duel.GetTurnCount()==1
end
function s.quicklimit(e,re,tp)
	if re:GetHandler():GetOriginalType()==TYPE_SPELL+TYPE_QUICKPLAY and re:IsHasType(EFFECT_TYPE_ACTIVATE) then

		--if the current chain is above 0 no quick-play can activate
		if Duel.GetCurrentChain()>0 then return true end

		--If it's not a main phase no quick-play can activate
		if Duel.GetCurrentPhase()~=PHASE_MAIN1 and Duel.GetCurrentPhase()~=PHASE_MAIN2 then return true end

		--only turn player can activate
		return Duel.GetTurnPlayer()~=tp
	end
	return false
end
function s.resplimit(e,re,tp)
	if e:GetHandler():GetOriginalType()==TYPE_SPELL+TYPE_QUICKPLAY and e:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	return true
end
function s.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetChainLimitTillChainEnd(s.resplimit)
end
