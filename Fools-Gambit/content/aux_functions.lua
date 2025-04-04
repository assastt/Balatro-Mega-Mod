function FG.is_alternate(card,table)
    for k, v in pairs(table) do
        if card == v then
            return "v"
		elseif card == tostring(k) then
			return "k"
        end
    end
    return "no"
end


--[[
key is the provided card key.
table is the reference table to look up.
passing key or value, and returns the other.
]]
function FG.get_equivalent(key,table,passing)
	local _passing = passing or FG.is_alternate(key,table)
	if _passing == "k" then -- passing key, returning value
		for k,v in pairs(table) do
			if k == key then return v end
		end
	elseif _passing == "v" then -- passing value, returning key
		for k,v in pairs(table) do
			if v == key then return k end
		end
	end
end

-- Alternates between this card and the associated alternative card.
-- key is the provided card key.
-- card is the card instance you are dealing with. 99% of the time it will be just card (the one provided you by the function)
-- table is the reference table to look up and compare.
function FG.alternate_card(key,card,table)
	local convert_to = FG.get_equivalent(key,table,FG.is_alternate(key,table))
	local new_card = SMODS.add_card({
		set = 'Joker',
		skip_materialize = true,
		key = tostring(convert_to),
	})
	if card.edition then
		new_card:set_edition(tostring(card.edition.key),true,true)
	else
		new_card:set_edition(nil,true,true)
	end
	card:start_dissolve(nil,false,0,true)
end

function FG.flip_editions(card)
	if card.edition then
		if card.edition.negative then
			card:set_edition(nil, true)
		elseif card.edition.polychrome then
			card:set_edition("e_fg_polished", true)
		elseif card.edition.fg_polished then
			card:set_edition("e_polychrome", true)
		elseif card.edition.holo then
			card:set_edition("e_foil", true)
		elseif card.edition.foil then
			card:set_edition("e_holo", true)
		end							
	else
		card:set_edition("e_negative", true)
	end
end

-- UNFINISHED !!!
function FG.change_pace()
	if common_alt.default_weight > 0 then
		sendInfoMessage("Regular", "MyInfoLogger")
	common_alt.default_weight = 0
	uncommon_alt.default_weight = 0
	rare_alt.default_weight= 0
	else
		sendInfoMessage("Alternate", "MyInfoLogger")
		common_alt.default_weight = .70
		uncommon_alt.default_weight = .25
		rare_alt.default_weight= .05
	end
end
