SMODS.Atlas {
    key = 'prismjokers',
    path = "jokers.png",
    px = 71,
    py = 95
}
SMODS.Joker({
	key = "polydactyly",
	atlas = "prismjokers",
	pos = {x=2,y=2},
	rarity = 1,
	cost = 6,
	unlocked = true,
	discovered = false,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	add_to_deck = function(self, card, from_debuff)
		G.hand.config.highlighted_limit = G.hand.config.highlighted_limit + 1
	end,
	remove_from_deck = function(self, card, from_debuff)
		G.hand.config.highlighted_limit = G.hand.config.highlighted_limit - 1
		if not G.GAME.before_play_buffer then
			G.hand:unhighlight_all()
		end
	end,
})
SMODS.Joker({
	key = "rich_joker",
	atlas = "prismjokers",
	pos = {x=0,y=12},
	rarity = 1,
	cost = 5,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = {
		odds = 2,money = 4
    },
	loc_vars = function(self, info_queue, center)
		return { vars = {
			"" .. (G.GAME and G.GAME.probabilities.normal or 1), 
			center.ability.odds,
			center.ability.money }
		}
	end,
	calculate = function(self, card, context)
		if context.selling_card and context.card ~= card and pseudorandom('rich') < G.GAME.probabilities.normal / card.ability.odds then
			ease_dollars(card.ability.money)
			card_eval_status_text(
				context.blueprint_card or card,
				"extra",
				nil,
				nil,
				nil,
				{ message = localize("$") .. card.ability.money, colour = G.C.MONEY, delay = 0.45 }
			)
			return nil,true
		end
	end,
})
SMODS.Joker({
	key = "hit_record",
	atlas = "prismjokers",
	pos = {x=0,y=11},
	rarity = 1,
	cost = 3,
	unlocked = true,
	discovered = false,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	calculate = function(self, card, context)
		if context.cardarea == G.play and context.individual then
			context.other_card.config.cycling = true
		end
	end
})

SMODS.Joker({
	key = "motherboard",
	atlas = "prismjokers",
	pos = {x=1,y=4},
	rarity = 1,
	cost = 6,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	config = {chips = 0, extra = 2},
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra, center.ability.chips} }
	end,
	calculate = function(self, card, context)
		if context.joker_main then
			return{
			chips = card.ability.chips
			}
		end
		if context.cardarea == G.play and context.individual and not context.blueprint then
			if context.other_card.ability.set ~= 'Enhanced' and not context.other_card.seal and not context.other_card.edition then
				card.ability.chips = card.ability.chips + card.ability.extra
				return {
					focus = card,
					colour = G.C.CHIPS,
					message = localize('k_upgrade_ex'),
					card = card,
				}
			end
		end
	end
})
SMODS.Joker({
	key = "ghost",
	atlas = "prismjokers",
	pos = {x=0,y=13},
	rarity = 1,
	cost = 5,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	config = {extra = {chips = 33}},
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.chips, G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.spectral * center.ability.extra.chips or 0} }
	end,
	calculate = function(self, card, context)
		if context.joker_main and G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.spectral > 0 then
			return {
				chips = G.GAME.consumeable_usage_total.spectral * card.ability.extra.chips
			}
		end
    end
	
})
SMODS.Joker({
	key = "pizza_cap",
	atlas = "prismjokers",
	pos = {x=3,y=0},
	rarity = 1,
	cost = 5,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	
	eternal_compat = false,
	perishable_compat = true,
	pools = {
		Food = true,
		Pizza = true
	},
	config = {extra = {chips = 40,uses = 15}},
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.chips,center.ability.extra.uses}}
	end,
	calculate = function(self, card, context)
        if context.cardarea == G.play and context.individual then
            if context.other_card:is_suit('Spades', nil, true) and card.ability.extra.uses > 0 then
				if not context.blueprint then card.ability.extra.uses = card.ability.extra.uses - 1 end
                return {
                    chips = card.ability.extra.chips,
                    card = card
                }
			end
        end
		if context.after and not context.blueprint and card.ability.extra.uses < 1 then
			G.PRISM.remove_joker(card)
			G.GAME.prism_pizza_lv = G.GAME.prism_pizza_lv + 1
			return {
				message = localize('k_eaten_ex'),
				colour = G.C.RED,
			}
		end
    end,
	set_ability = function(self, card, initial,delay_sprites)
		card.ability.extra.chips = card.ability.extra.chips + (40 * (G.GAME.prism_pizza_lv or 0))
	end
})
SMODS.Joker({
	key = "pizza_mar",
	atlas = "prismjokers",
	pos = {x=3,y=1},
	rarity = 1,
	cost = 5,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = false,
	perishable_compat = true,
	pools = {
		Food = true,
		Pizza = true
	},
	config = {extra = {x_mult = 1.2,uses = 15}},
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.x_mult,center.ability.extra.uses}}
	end,
	calculate = function(self, card, context)
        if context.cardarea == G.play and context.individual then
            if context.other_card:is_suit('Hearts', nil, true) and card.ability.extra.uses > 0 then
				if not context.blueprint then card.ability.extra.uses = card.ability.extra.uses - 1 end
                return {
                    xmult = card.ability.extra.x_mult,
                    card = card
                }
			end
        end
		if context.after and not context.blueprint and card.ability.extra.uses < 1 then
			G.PRISM.remove_joker(card)
			G.GAME.prism_pizza_lv = G.GAME.prism_pizza_lv + 1
			return {
				message = localize('k_eaten_ex'),
				colour = G.C.RED,
			}
		end
    end,
	set_ability = function(self, card, initial,delay_sprites)
		card.ability.extra.x_mult = card.ability.extra.x_mult + (0.2 * (G.GAME.prism_pizza_lv or 0))
	end
})
SMODS.Joker({
	key = "pizza_for",
	atlas = "prismjokers",
	pos = {x=3,y=2},
	rarity = 1,
	cost = 5,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = false,
	perishable_compat = true,
	pools = {
		Food = true,
		Pizza = true
	},
	config = {extra = {money = 2,odds = 2, uses = 15}},
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.money,center.ability.extra.uses,"" .. (G.GAME and G.GAME.probabilities.normal or 1),center.ability.extra.odds}}
	end,
	calculate = function(self, card, context)
        if context.cardarea == G.play and context.individual then
            if context.other_card:is_suit('Diamonds', nil, true) and card.ability.extra.uses > 0 then
				if not context.blueprint then card.ability.extra.uses = card.ability.extra.uses - 1 end
				if pseudorandom('4cheese') < G.GAME.probabilities.normal / card.ability.extra.odds then
					return {
						dollars = card.ability.extra.money,
						card = card
					}
				end
			end
        end
		if context.after and not context.blueprint and card.ability.extra.uses < 1 then
			G.PRISM.remove_joker(card)
			G.GAME.prism_pizza_lv = G.GAME.prism_pizza_lv + 1
			return {
				message = localize('k_eaten_ex'),
				colour = G.C.RED,
			}
		end
    end,
	set_ability = function(self, card, initial,delay_sprites)
		card.ability.extra.money = card.ability.extra.money + (2 * (G.GAME.prism_pizza_lv or 0))
	end
})
SMODS.Joker({
	key = "pizza_ruc",
	atlas = "prismjokers",
	pos = {x=3,y=3},
	rarity = 1,
	cost = 5,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = false,
	perishable_compat = true,
	pools = {
		Food = true,
		Pizza = true
	},
	config = {extra = {mult = 6,uses = 15}},
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.mult,center.ability.extra.uses}}
	end,
	calculate = function(self, card, context)
        if context.cardarea == G.play and context.individual then
            if context.other_card:is_suit('Clubs', nil, true) and card.ability.extra.uses > 0 then
				if not context.blueprint then card.ability.extra.uses = card.ability.extra.uses - 1 end
                return {
                    mult = card.ability.extra.mult,
                    card = card
                }
			end
        end
		if context.after and not context.blueprint and card.ability.extra.uses < 1 then
			G.PRISM.remove_joker(card)
			G.GAME.prism_pizza_lv = G.GAME.prism_pizza_lv + 1
			return {
				message = localize('k_eaten_ex'),
				colour = G.C.RED,
			}
		end
    end,
	set_ability = function(self, card, initial,delay_sprites)
		card.ability.extra.mult = card.ability.extra.mult + (6 * (G.GAME.prism_pizza_lv or 0))
	end
})
if G.PRISM.compat.paperback then
SMODS.Joker({
	key = "pizza_haw",
	atlas = "prismjokers",
	pos = {x=3,y=4},
	rarity = 1,
	cost = 5,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = false,
	perishable_compat = true,
	pools = {
		Food = true,
		Pizza = true
	},
	paperback = {
		requires_crowns = true
	},
	config = {extra = {min_money = -3, max_money = 5, uses = 15}},
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.min_money,center.ability.extra.max_money,center.ability.extra.uses}}
	end,
	calculate = function(self, card, context)
        if context.cardarea == G.play and context.individual then
            if context.other_card:is_suit('paperback_Crowns', nil, true) and card.ability.extra.uses > 0 then
				if not context.blueprint then card.ability.extra.uses = card.ability.extra.uses - 1 end
				local dollars = pseudorandom("hawaiian", card.ability.extra.min_money, card.ability.extra.max_money)
        		if dollars ~= 0 then
					return {
						dollars = dollars
					}
				end
			end
        end
		if context.after and not context.blueprint and card.ability.extra.uses < 1 then
			G.PRISM.remove_joker(card)
			G.GAME.prism_pizza_lv = G.GAME.prism_pizza_lv + 1
			return {
				message = localize('k_eaten_ex'),
				colour = G.C.RED,
			}
		end
    end,
	set_ability = function(self, card, initial,delay_sprites)
		card.ability.extra.min_money = card.ability.extra.min_money + (-2 * (G.GAME.prism_pizza_lv or 0))
		card.ability.extra.max_money = card.ability.extra.max_money + (5 * (G.GAME.prism_pizza_lv or 0))
	end
})
SMODS.Joker({
	key = "pizza_det",
	atlas = "prismjokers",
	pos = {x=3,y=5},
	rarity = 1,
	cost = 5,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = false,
	perishable_compat = true,
	pools = {
		Food = true,
		Pizza = true
	},
	paperback = {
		requires_stars = true
	},
	config = {extra = {x_chips = 1.2, uses = 15}},
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.x_chips,center.ability.extra.uses}}
	end,
	calculate = function(self, card, context)
        if context.cardarea == G.play and context.individual then
            if context.other_card:is_suit('paperback_Stars', nil, true) and card.ability.extra.uses > 0 then
				if not context.blueprint then card.ability.extra.uses = card.ability.extra.uses - 1 end
				return {
					x_chips = card.ability.extra.x_chips
				}
			end
        end
		if context.after and not context.blueprint and card.ability.extra.uses < 1 then
			G.PRISM.remove_joker(card)
			G.GAME.prism_pizza_lv = G.GAME.prism_pizza_lv + 1
			return {
				message = localize('k_eaten_ex'),
				colour = G.C.RED,
			}
		end
    end,
	set_ability = function(self, card, initial,delay_sprites)
		card.ability.extra.min_money = card.ability.extra.x_chips + (0.2 * (G.GAME.prism_pizza_lv or 0))
	end
})
end
if G.PRISM.compat.mintys then
	SMODS.Joker({
		key = "pizza_con",
		atlas = "prismjokers",
		pos = {x=3,y=6},
		rarity = 1,
		cost = 5,
		unlocked = true,
		discovered = false,
		blueprint_compat = true,
		eternal_compat = false,
		perishable_compat = true,
		pools = {
			Food = true,
			Pizza = true
		},
		config = {extra = {x_mult = 2.5, uses = 15,again = 0,odds = 3}},
		loc_vars = function(self, info_queue, center)
			return { vars = { center.ability.extra.x_mult,center.ability.extra.uses,
			"" .. (G.GAME and G.GAME.probabilities.normal or 1),center.ability.extra.odds}}
		end,
		calculate = function(self, card, context)
			if context.cardarea == G.play and context.individual then
				if context.other_card:is_3() and card.ability.extra.uses > 0 then
					if not context.blueprint then card.ability.extra.uses = card.ability.extra.uses - 1 end
					local trycount = context.other_card:is_3()
					local repcount = 0
					for try=1,trycount do
						if pseudorandom('cone') < G.GAME.probabilities.normal/card.ability.extra.odds then 
							repcount = repcount + 1
						end
					end
					card.ability.extra.again = repcount
					--sendDebugMessage('Count (individual): '..card.ability.extra.again)
					if card.ability.extra.again ~= 0 then
						return {
							xmult = card.ability.extra.x_mult,
							card = card
						}
					end
				end
			end
			if context.retrigger_joker_check and card.ability.extra.again ~= 0 and context.other_card == card then 
				local reps = card.ability.extra.again-1
				card.ability.extra.again = 0
				if reps >= 1 then 
					return {
						message = localize('k_again_ex'),
						message_card = card,
						repetitions = reps
					}
				end
			end
			if context.after and not context.blueprint and card.ability.extra.uses < 1 then
				G.PRISM.remove_joker(card)
				G.GAME.prism_pizza_lv = G.GAME.prism_pizza_lv + 1
				return {
					message = localize('k_eaten_ex'),
					colour = G.C.RED,
				}
			end
		end,
		set_ability = function(self, card, initial,delay_sprites)
			card.ability.extra.x_mult = card.ability.extra.x_mult + (2.5 * (G.GAME.prism_pizza_lv or 0))
		end
	})
end
SMODS.Joker({
	key = "sculptor",
	atlas = "prismjokers",
	pos = {x=1,y=3},
	rarity = 1,
	cost = 6,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = {extra = 7},
	loc_vars = function(self, info_queue, center)
		info_queue[#info_queue + 1] = G.P_CENTERS.m_stone
		return {
		vars = {center.ability.extra}
		}
	end,
	in_pool = function(self)
		for k, v in pairs(G.playing_cards) do
			if SMODS.has_enhancement(v,'m_stone') then return true end
		end
		return false
	end,
	calculate = function(self, card, context)
        if context.cardarea == G.play and context.individual then
			if SMODS.has_enhancement(context.other_card,'m_stone') then
            	context.other_card.ability.perma_mult = context.other_card.ability.perma_mult or 0
                context.other_card.ability.perma_mult = context.other_card.ability.perma_mult + card.ability.extra
                return {
                    extra = {message = localize('k_upgrade_ex'), colour = G.C.RED},
                    colour = G.C.RED,
                    card = card
                }
			end
        end
    end
	
})
if G.PRISM.config.myth_enabled then
SMODS.Joker({
	key = "happily",
	atlas = "prismjokers",
	pos = {x=1,y=12},
	rarity = 1,
	cost = 5,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	calculate = function(self, card, context)
		if context.joker_main and not context.before and not context.after and not (context.blueprint_card or card).getting_sliced and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
			local kings = 0
			local queens = 0
			for i = 1, #context.scoring_hand do
				if context.scoring_hand[i]:get_id() == 12 then queens = queens + 1 end
				if context.scoring_hand[i]:get_id() == 13 then kings = kings + 1 end
			end
			if kings >= 1 and queens >= 1 then
				G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
				play_sound("timpani")
				play_sound("polychrome1",2,0.5)
				local myth = create_card('Myth',G.consumeables, nil, nil, nil, nil, nil, 'happily')
				myth:add_to_deck()
				G.consumeables:emplace(myth)
				G.GAME.consumeable_buffer = 0
				myth:juice_up(0.3, 0.5)
				card:juice_up(0.3, 0.5)
				return nil,true
			end
		end
	end
})
SMODS.Joker({
	key = "geo_hammer",
	atlas = "prismjokers",
	pos = {x=0,y=3},
	rarity = 1,
	cost = 6,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = {extra = {"m_stone","m_prism_crystal"}},
	loc_vars = function(self, info_queue, center)
		info_queue[#info_queue + 1] = G.P_CENTERS.m_stone
		info_queue[#info_queue + 1] = G.P_CENTERS.m_prism_crystal
	end,
	calculate = function(self, card, context)
		if context.first_hand_drawn then
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
				local eligible_cards = {}
				for k, v in ipairs(G.hand.cards) do
					if v.ability.set ~= 'Enhanced' then
						table.insert(eligible_cards,v)
					end
				end
				local random_card = pseudorandom_element(eligible_cards, pseudoseed('geo'))
				local enhancement = pseudorandom_element(card.ability.extra, pseudoseed('geo'))
				if random_card then
					random_card:set_ability(G.P_CENTERS[enhancement]) 
					random_card:juice_up(0.3, 0.5)
					card:juice_up(0.3, 0.5)
				end
			return true end }))
		end
	end
})
end
SMODS.Joker({
	key = "air_balloon",
	atlas = "prismjokers",
	pos = {x=0,y=0},
	rarity = 1,
	cost = 5,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	config = {mult = 0,extra = 2},
	loc_vars = function(self, info_queue, center)
		return { vars = {center.ability.mult,center.ability.extra} }
	end,
	calculate = function(self, card, context)
		if context.joker_main then
			return {
				mult = card.ability.mult,
			}
		end
        if context.cardarea == G.jokers and context.before and not context.blueprint then
			local reset = true
			if context.scoring_name == "High Card" then
				reset = false
			end
			if reset then
				if card.ability.mult > 0 then
					card.ability.mult = 0
					return {
						card = card,
						message = localize('k_reset')
					}
				end
			else
				card.ability.mult = card.ability.mult + card.ability.extra
			end
        end
    end
})
SMODS.Joker({
	key = "metalhead",
	atlas = "prismjokers",
	pos = {x=2,y=5},
	rarity = 1,
	cost = 6,
	unlocked = true,
	discovered = false,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	in_pool = function(self)
		for k, v in pairs(G.playing_cards) do
			if SMODS.has_enhancement(v,'m_stone') then return true end
		end
		return false
	end,
	loc_vars = function(self, info_queue, center)
		info_queue[#info_queue + 1] = G.P_CENTERS.m_stone
		info_queue[#info_queue + 1] = G.P_CENTERS.m_steel
	end,
	add_to_deck = function(self, card, from_debuff)
        for _, deck_card in pairs(G.playing_cards) do
            if SMODS.has_enhancement(deck_card,"m_stone") then
                deck_card.ability.h_x_mult = (deck_card.ability.h_x_mult or 0) + G.P_CENTERS.m_steel.config.h_x_mult
            end
        end
        G.P_CENTERS.m_stone.config.h_x_mult = (G.P_CENTERS.m_stone.config.h_x_mult or 0) + G.P_CENTERS.m_steel.config.h_x_mult
    end,
    remove_from_deck = function(self, card, from_debuff)
        for _, deck_card in pairs(G.playing_cards) do
            if SMODS.has_enhancement(deck_card,"m_stone") then
                deck_card.ability.h_x_mult = (deck_card.ability.h_x_mult or G.P_CENTERS.m_steel.config.h_x_mult) - G.P_CENTERS.m_steel.config.h_x_mult
            end
        end
        G.P_CENTERS.m_stone.config.h_x_mult = (G.P_CENTERS.m_stone.config.h_x_mult or G.P_CENTERS.m_steel.config.h_x_mult) - G.P_CENTERS.m_steel.config.h_x_mult
    end
})

local orig_get_enhancements = SMODS.get_enhancements
function SMODS.get_enhancements(card, extra_only)
	local enhancements = orig_get_enhancements(card,extra_only)
	if next(find_joker("j_prism_metalhead")) and card.config.center == G.P_CENTERS.m_stone then
		enhancements["m_steel"] = true
	end
	return enhancements
end
SMODS.Joker({
	key = "exotic_card",
	atlas = "prismjokers",
	pos = {x=0,y=2},
	rarity = 2,
	cost = 6,
	pixel_size = { w = 59, h = 95},
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = {extra = 1},
	loc_vars = function(self, info_queue, center)
		return { vars = {center.ability.extra} }
	end,
	calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if context.other_card.ability.set == 'Enhanced' then
                return {
                    message = localize('k_again_ex'),
                    repetitions = card.ability.extra,
                    card = card
                }
            end
        end
    end
	
})
SMODS.Joker({
	key = "day",
	atlas = "prismjokers",
	pos = {x=2,y=7},
	rarity = 2,
	cost = 6,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = {extra = 1,trigger = false},
	yes_pool_flag = "day_can_spawn",
	loc_vars = function(self, info_queue, center)
		if not center.fake_card then info_queue[#info_queue + 1] = G.P_CENTERS.j_prism_night end
	end,
	calculate = function(self, card, context)
		if context.before then
			local right_suits, all_cards = 0, 0
			for k, v in ipairs(G.play.cards) do
				all_cards = all_cards + 1
				if v:is_suit('Hearts', nil, true) or v:is_suit('Diamonds', nil, true) then
					right_suits = right_suits + 1
				end
			end
			if right_suits == all_cards then 
				card.ability.trigger = true
			end
		end
		if context.after and card.ability.trigger then
			G.E_MANAGER:add_event(Event({
				func = function()
					play_sound('tarot2', 1.1, 0.6)
					card:set_ability(G.P_CENTERS.j_prism_night)
					return true
				end
			}))
			return {
				message = localize('k_sunset'),
				card = card
			}
		end
		if context.repetition and context.cardarea == G.play and card.ability.trigger then
			return {
				message = localize('k_again_ex'),
				repetitions = card.ability.extra,
				card = card
			}
        end
	end,
	add_to_deck = function(self, card, from_debuff)
		G.GAME.pool_flags.night_can_spawn = false
	end,
	remove_from_deck = function(self, card, from_debuff)
		G.GAME.pool_flags.night_can_spawn = true
	end
})
SMODS.Joker({
	key = "night",
	atlas = "prismjokers",
	pos = {x=2,y=8},
	rarity = 2,
	cost = 6,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = {extra = 1,trigger = false},
	yes_pool_flag = "night_can_spawn",
	loc_vars = function(self, info_queue, center)
		if not center.fake_card then info_queue[#info_queue + 1] = G.P_CENTERS.j_prism_day end
	end,
	calculate = function(self, card, context)
		if context.before then
			local right_suits, all_cards = 0, 0
			for k, v in ipairs(G.play.cards) do
				all_cards = all_cards + 1
				if v:is_suit('Clubs', nil, true) or v:is_suit('Spades', nil, true) then
					right_suits = right_suits + 1
				end
			end
			if right_suits == all_cards then 
				card.ability.trigger = true
			end
		end
		if context.after and card.ability.trigger then
			G.E_MANAGER:add_event(Event({
				func = function()
					play_sound('tarot2', 1.1, 0.6)
					card:set_ability(G.P_CENTERS.j_prism_day)
					return true
				end
			}))
			return {
				message = localize('k_sunrise'),
				card = card
			}
		end
		if context.repetition and context.cardarea == G.play and card.ability.trigger then
			return {
				message = localize('k_again_ex'),
				repetitions = card.ability.extra,
				card = card
			}
        end
	end,
	add_to_deck = function(self, card, from_debuff)
		G.GAME.pool_flags.day_can_spawn = false
	end,
	remove_from_deck = function(self, card, from_debuff)
		G.GAME.pool_flags.day_can_spawn = true
	end
})
SMODS.Joker({
	key = "whiskey",
	atlas = "prismjokers",
	pos = {x=2,y=3},
	rarity = 2,
	cost = 7,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = {required = 4,current = 0},
	loc_vars = function(self, info_queue, center)
		info_queue[#info_queue+1] = {key = 'tag_double', set = 'Tag'}
		return { vars = {center.ability.required,center.ability.current} }
	end,
	calculate = function(self, card, context)
        if context.cardarea == G.play and context.individual then
            if context.other_card:get_id() == 11 then
                card.ability.current = card.ability.current + 1
				if card.ability.current >= card.ability.required then
					card.ability.current = 0
					G.E_MANAGER:add_event(Event({
						func = (function()
							add_tag(Tag('tag_double'))
							play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
							play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
						   return true
					   end)
					}))
				end
				return {
					message = (card.ability.current == 0) and localize('k_plus_double') or (card.ability.current..'/'..card.ability.required),
					colour = G.C.FILTER,
					card = card
				}
            end
        end
    end
})
SMODS.Joker({
	key = "solo_joker",
	atlas = "prismjokers",
	pos = {x=1,y=14},
	rarity = 2,
	cost = 5,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = {extra = 4, trigger = false},
	loc_vars = function(self, info_queue, center)
		return { vars = {center.ability.extra} }
	end,
	calculate = function(self, card, context)
		if context.cardarea == G.jokers and context.before then
			if #context.full_hand == 1 then card.ability.trigger = true else card.ability.trigger = false end
		end
        if context.repetition and context.cardarea == G.play and card.ability.trigger then
			return {
				message = localize('k_again_ex'),
				repetitions = card.ability.extra,
				card = card
			}
        end
    end
})
SMODS.Joker({
	key = "cookie",
	atlas = "prismjokers",
	pos = {x=2,y=0},
	rarity = 2,
	cost = 6,
	unlocked = true,
	discovered = false,
	blueprint_compat = false,
	eternal_compat = false,
	perishable_compat = true,
	config = {extra = 100},
	loc_vars = function(self, info_queue, center)
		local active = G.STATE == G.STATES.SELECTING_HAND
		return {
			main_end = (center.area and center.area == G.jokers) and {{
				n = G.UIT.C,
				config = {
					align = "bm",
					minh = 0.4
				},
				nodes = {{
					n = G.UIT.C,
					config = {
						ref_table = center,
						align = "m", 
						colour = active and G.C.GREEN or G.C.RED,
						r = 0.05, 
						padding = 0.06,
					},
					nodes = {{
						n = G.UIT.T,
						config = {
							text = ' '..localize(active and 'k_active' or 'k_inactive')..' ',
							colour = G.C.UI.TEXT_LIGHT,
							scale = 0.32*0.9
						}
					}}
				}}
			}}
		}
	end,
	calculate = function(self, card, context)
		if context.selling_self then
			if G.STATE == G.STATES.SELECTING_HAND then
				G.GAME.prism_fortune_cookie = true
				for k, v in pairs(G.GAME.probabilities) do
					G.GAME.probabilities[k] = v * 9999
				end
			end
		end
    end
	
})
SMODS.Joker({
	key = "economics",
	atlas = "prismjokers",
	pos = {x=1,y=8},
	rarity = 2,
	cost = 8,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	config = {extra = {x_mult = 1,gain = 0.1,dollars = 2}},
	loc_vars = function(self, info_queue, center)
		return { vars = {center.ability.extra.gain,center.ability.extra.dollars,center.ability.extra.x_mult} }
	end,
	calculate = function(self, card, context)
		if context.joker_main then
			return {
				xmult = to_num(bignum(card.ability.extra.x_mult)),
			}
		end
		if context.setting_blind and not context.blueprint_card then
			local x_mult_gain = card.ability.extra.gain*math.floor((G.GAME.dollars + (G.GAME.dollar_buffer or 0))/card.ability.extra.dollars)
			ease_dollars(-G.GAME.dollars, true)
			if bignum(x_mult_gain) > bignum(0) then 
				card.ability.extra.x_mult = card.ability.extra.x_mult + to_num(bignum(x_mult_gain))
				return {
					focus = card,
					message = localize({ type = "variable", key = "a_xmult", vars = { card.ability.extra.x_mult } }),
					card = card,
				}
			end
		end
	end
})
SMODS.Joker({
	key = "patch",
	atlas = "prismjokers",
	pos = {x=2,y=6},
	rarity = 2,
	cost = 6,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	loc_vars = function(self, info_queue, center)
		info_queue[#info_queue+1] = {key = 'tag_negative', set = 'Tag'}
	end,
	calculate = function(self, card, context)
		if context.joker_main then
			local sixes = 0
			for i = 1, #context.scoring_hand do
				if context.scoring_hand[i]:get_id() == 6 then sixes = sixes + 1 end
			end
			if sixes == 3 then
				G.E_MANAGER:add_event(Event({
					trigger = 'before',
					func = (function()
						add_tag(Tag('tag_negative'))
						play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
						play_sound('negative', 1.2 + math.random()*0.1, 0.4)
					return true
				end)}))
				return {
					message = localize('k_plus_negative'),
					colour = G.C.DARK_EDITION,
					card = card,
				}
			end
		end
	end
})
if G.PRISM.config.myth_enabled then
SMODS.Joker({
	key = "elf",
	atlas = "prismjokers",
	pos = {x=1,y=13},
	rarity = 2,
	cost = 6,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = {extra = {x_mult = 2.5, active = false}},
	loc_vars = function(self, info_queue, center)
		local active = center.ability.extra.active
		return {
			vars = {center.ability.extra.x_mult},
			main_end = (center.area and center.area == G.jokers) and {{
				n = G.UIT.C,
				config = {
					align = "bm",
					minh = 0.4
				},
				nodes = {{
					n = G.UIT.C,
					config = {
						ref_table = center,
						align = "m", 
						colour = active and G.C.GREEN or G.C.RED,
						r = 0.05, 
						padding = 0.06,
					},
					nodes = {{
						n = G.UIT.T,
						config = {
							text = ' '..localize(active and 'k_active' or 'k_inactive')..' ',
							colour = G.C.UI.TEXT_LIGHT,
							scale = 0.32*0.9
						}
					}}
				}}
			}}
		}
	end,
	calculate = function(self, card, context)
        if context.using_consumeable and context.consumeable.ability.set  == 'Myth' and not context.blueprint and card.ability.extra.active == false then
            card.ability.extra.active = true
			return {
				colour = G.C.GREEN,
				message = localize('k_active_ex')
			}
        end
		if context.cardarea == G.jokers and context.end_of_round and not context.blueprint and card.ability.extra.active then
			card.ability.extra.active = false
			return {
				colour = G.C.RED,
				message = localize('k_inactive_ex')
			}
		end
		if context.joker_main and card.ability.extra.active then
			return {
				xmult = card.ability.extra.x_mult,
				card = card
			}
		end
    end
})
end
SMODS.Joker({
	key = "vaquero",
	atlas = "prismjokers",
	pos = {x=1,y=2},
	rarity = 2,
	cost = 5,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = {extra = {x_mult = 1.75}},
	loc_vars = function(self, info_queue, center)
		info_queue[#info_queue + 1] = G.P_CENTERS.m_wild
		return {
		vars = {center.ability.extra.x_mult}
		}
	end,
	in_pool = function(self)
		for k, v in pairs(G.playing_cards) do
			if SMODS.has_enhancement(v,'m_wild') then return true end
		end
		return false
	end,
	calculate = function(self, card, context)
        if context.cardarea == G.play and context.individual then
            if SMODS.has_enhancement(context.other_card,'m_wild') then
                return {
                    xmult = card.ability.extra.x_mult,
                    card = card
                }
            end
        end
    end
})
SMODS.Joker({
	key = "hopscotch",
	atlas = "prismjokers",
	pos = {x=1,y=10},
	rarity = 2,
	cost = 7,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	config = {rank = 14, mult = 0,extra = 1},
	immutable = true, --For Cryptid reasons
	loc_vars = function(self, info_queue, center)
		local rank = center.ability.rank
		if rank < 11 then rank = tostring(rank)
		elseif rank == 11 then rank = 'Jack'
		elseif rank == 12 then rank = 'Queen'
		elseif rank == 13 then rank = 'King'
		elseif rank == 14 then rank = 'Ace' 
		end
		return { vars = {center.ability.extra,center.ability.mult,localize(rank, 'ranks')} }
	end,
	calculate = function(self, card, context)
		if context.joker_main then
			return {
				mult = card.ability.mult,
			}
		end
        if context.cardarea == G.play and context.individual and not context.blueprint then
			if context.other_card:get_id() == card.ability.rank then
				card.ability.mult = card.ability.mult + card.ability.extra
				card.ability.rank = card.ability.rank == 14 and 2 or math.min(card.ability.rank + 1, 14)
				return {
					focus = card,
					colour = G.C.RED,
					message = localize('k_upgrade_ex'),
					card = card,
				}
			end
        end
    end
})
SMODS.Joker({
	key = "aces_high",
	atlas = "prismjokers",
	pos = {x=1,y=11},
	rarity = 2,
	cost = 6,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	loc_vars = function(self, info_queue, center)
		info_queue[#info_queue+1] = {key = 'tag_uncommon', set = 'Tag'}
		info_queue[#info_queue+1] = {key = 'tag_rare', set = 'Tag'}
	end,
	calculate = function(self, card, context)
		if context.joker_main then
			local aces = 0
			for i = 1, #context.scoring_hand do
				if context.scoring_hand[i]:get_id() == 14 then aces = aces + 1 end
			end
			if aces >= 1 and next(context.poker_hands["Straight"]) then
				if pseudorandom('aces high') < 1 / 3 then
					G.E_MANAGER:add_event(Event({
						trigger = 'before',
						func = (function()
							add_tag(Tag('tag_rare'))
							play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
							play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
						return true
					end)}))
					return {
						message = localize('k_plus_rare'),
						colour = G.C.RED,
						card = card,
					}
				else
					G.E_MANAGER:add_event(Event({
						trigger = 'before',
						func = (function()
							add_tag(Tag('tag_uncommon'))
							play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
							play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
						return true
					end)}))
					return {
						message = localize('k_plus_uncommon'),
						colour = G.C.GREEN,
						card = card,
					}
				end
			end
		end
    end
})
SMODS.Joker({
	key = "medusa",
	atlas = "prismjokers",
	pos = {x=0,y=6},
	rarity = 2,
	cost = 5,
	unlocked = true,
	discovered = false,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	loc_vars = function(self, info_queue, center)
		info_queue[#info_queue + 1] = G.P_CENTERS.m_stone
	end,
	calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.before then
			local faces = {}
			local has_face = false
            for k, v in ipairs(context.scoring_hand) do
				if v:is_face() then 
					faces[#faces+1] = v
					has_face = true
					v:set_ability(G.P_CENTERS.m_stone,nil,true)
					G.E_MANAGER:add_event(Event({
						func = function()
							v:juice_up()
							return true
						end
					}))
				end
			end
			if has_face then
				return {
					message = localize('k_stone'),
					colour = HEX("D0D2D6"),
					card = card,
				}
			end
		end
    end
	
})
if G.PRISM.config.myth_enabled then
SMODS.Joker({
	key = "amethyst",
	atlas = "prismjokers",
	pos = {x=1,y=7},
	rarity = 2,
	cost = 7,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	config = {x_mult = 1, extra = 0.15},
	loc_vars = function(self, info_queue, center)
		info_queue[#info_queue + 1] = G.P_CENTERS.m_prism_crystal
		return {vars = {center.ability.x_mult,center.ability.extra}}
	end,
	in_pool = function(self)
		for k, v in pairs(G.playing_cards) do
			if SMODS.has_enhancement(v,'m_prism_crystal') then return true end
		end
		return false
	end,
	calculate = function(self, card, context)
        if context.joker_main then
			return {
				xmult = card.ability.x_mult
			}
		end
		if context.end_of_round and context.individual and context.cardarea == G.hand and not context.blueprint then
			if SMODS.has_enhancement(context.other_card,'m_prism_crystal') then
				card.ability.x_mult = card.ability.x_mult + card.ability.extra
				return {
					focus = card,
					colour = G.C.RED,
					message = localize('k_upgrade_ex'),
					card = card,
				}
			end
        end
    end
	
})
SMODS.Joker({
	key = "minstrel",
	atlas = "prismjokers",
	pos = {x=1,y=0},
	rarity = 2,
	cost = 7,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	calculate = function(self, card, context)
		if context.setting_blind and not (context.blueprint_card or card).getting_sliced and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
			G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
			play_sound("timpani")
			local myth = create_card('Myth',G.consumeables, nil, nil, nil, nil, nil, 'minst')
			myth:add_to_deck()
			G.consumeables:emplace(myth)
			G.GAME.consumeable_buffer = 0
			myth:juice_up(0.3, 0.5)
			return nil,true
		end
	end
})
SMODS.Joker({
	key = "schrodinger",
	atlas = "prismjokers",
	pos = {x=2,y=12},
	rarity = 2,
	cost = 6,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = {extra = 0},
	in_pool = function(self)
		for k, v in pairs(G.playing_cards) do
			if SMODS.has_enhancement(v,'m_prism_double') then return true end
		end
		return false
	end,
	calculate = function(self, card, context)
		if context.repetition and context.cardarea == G.play then
			if context.other_card.config.center == G.P_CENTERS.m_prism_double then
				print("yes")
				card.ability.extra = card.ability.extra + 1
				return {
					message = localize('k_again_ex'),
                    repetitions = card.ability.extra,
					card = card
				}
		  	else
				card.ability.extra = 0
			end
		end
		if context.after and not context.blueprint then
		  	card.ability.extra = 0
		end
	end
})
end
SMODS.Joker({
	key = "promotion",
	atlas = "prismjokers",
	pos = {x=0,y=9},
	rarity = 2,
	cost = 7,
	unlocked = true,
	discovered = false,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	calculate = function(self, card, context)
		if context.first_hand_drawn then
			local eval = function() return G.GAME.current_round.hands_played == 0 end
			juice_card_until(card, eval, true)
		end
		if context.cardarea == G.jokers and context.before then
			if #context.full_hand == 1 and G.GAME.current_round.hands_played == 0 then
				local _card = context.full_hand[1]
				local suit = string.sub(_card.base.suit, 1, 1)..'_'
                _card:set_base(G.P_CARDS[suit..'Q'])
				G.E_MANAGER:add_event(Event({
					func = function()
						_card:juice_up(0.3, 0.5)
						return true
					end
				}))
				return {
					message = localize('k_promoted'),
					focus = _card,
					card = card,
				}
			end
		end
	end
})
SMODS.Joker({
	key = "reverse_card",
	atlas = "prismjokers",
	pos = {x=1,y=5},
	rarity = 2,
	cost = 6,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	calculate = function(self, card, context)
		if context.joker_main and not context.before and not context.after and hand_chips and mult then
			local old_chips = hand_chips
			local old_mult = mult
			hand_chips = mod_chips(old_mult)
			mult = mod_mult(old_chips)
			update_hand_text({ delay = 0 }, { mult = mult, chips = hand_chips })
			return {
				message = localize("k_uno_reverse"),
				colour = G.C.RED
			}
		end
	end
})
SMODS.Joker({
	key = "vip_pass",
	atlas = "prismjokers",
	pos = {x=1,y=6},
	rarity = 3,
	cost = 7,
	unlocked = true,
	discovered = false,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	
})
local orig_poll_rarity = SMODS.poll_rarity
function SMODS.poll_rarity(_pool_key, _rand_key)
	if not next(find_joker('j_prism_vip_pass')) then
		return orig_poll_rarity(_pool_key, _rand_key)
	end
	local rarity_poll = pseudorandom(pseudoseed(_rand_key or ('rarity'..G.GAME.round_resets.ante))) -- Generate the poll value
	local available_rarities = copy_table(SMODS.ObjectTypes[_pool_key].rarities) -- Table containing a list of rarities and their rates
    local vanilla_rarities = {["Common"] = 1, ["Uncommon"] = 2, ["Rare"] = 3, ["Legendary"] = 4}
	table.remove(available_rarities,1)
    -- Calculate total rates of rarities
    local total_weight = 0
    for _, v in ipairs(available_rarities) do
        v.mod = G.GAME[tostring(v.key):lower().."_mod"] or 1
        -- Should this fully override the v.weight calcs? 
        if SMODS.Rarities[v.key] and SMODS.Rarities[v.key].get_weight and type(SMODS.Rarities[v.key].get_weight) == "function" then
            v.weight = SMODS.Rarities[v.key]:get_weight(v.weight, SMODS.ObjectTypes[_pool_key])
        end
        v.weight = v.weight*v.mod
        total_weight = total_weight + v.weight
    end
    -- recalculate rarities to account for v.mod
    for _, v in ipairs(available_rarities) do
        v.weight = v.weight / total_weight
    end

	-- Calculate selected rarity
	local weight_i = 0
	for _, v in ipairs(available_rarities) do
		weight_i = weight_i + v.weight
		if rarity_poll < weight_i then
            if vanilla_rarities[v.key] then 
                return vanilla_rarities[v.key]
            else
			    return v.key
            end
		end
	end
	return nil
end
SMODS.Joker({
	key = "pie",
	atlas = "prismjokers",
	pos = {x=2,y=1},
	rarity = 3,
	cost = 7,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = {extra = {index = 1,x_mult = 2.5}},
	loc_vars = function(self, info_queue, center)
		local rank = string.sub(G.PRISM.PI,center.ability.extra.index,center.ability.extra.index)
		if rank == "1" then rank = "Ace" end
		return{ vars = {localize(rank,'ranks'),
		center.ability.extra.x_mult,
		string.sub(G.PRISM.PI,center.ability.extra.index + 1,center.ability.extra.index + 5)}}
	end,
	calculate = function(self, card, context)
        if context.cardarea == G.play and context.individual then
			local rank = string.sub(G.PRISM.PI,card.ability.extra.index,card.ability.extra.index)
			if rank == "1" then rank = "Ace" end
			if context.other_card.config.card.value == rank then
				card.ability.extra.index = card.ability.extra.index + 1
				if card.ability.extra.index > G.PRISM.PI:len() then card.ability.extra.index = 1 end
				return {
					xmult = card.ability.extra.x_mult,
					card = card
				}
			end
        end
    end
	
})
SMODS.Joker({
	key = "plasma_lamp",
	atlas = "prismjokers",
	pos = {x=1,y=9},
	rarity = 3,
	cost = 8,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = {poker_hand_1 = 'High Card',poker_hand_2 = 'Three of a Kind',reset = false},
	loc_vars = function(self, info_queue, center)
		return {vars = {localize(center.ability.poker_hand_1, 'poker_hands'),localize(center.ability.poker_hand_2, 'poker_hands')}}
	end,
	add_to_deck = function(self, card, from_debuff)
		card.ability.reset = false
		local _poker_hands = {}
		for k, v in pairs(G.GAME.hands) do
			if v.visible then _poker_hands[#_poker_hands+1] = k end
		end
		card.ability.poker_hand_1 = pseudorandom_element(_poker_hands, pseudoseed('plasma'))
		_poker_hands = {}
		for k, v in pairs(G.GAME.hands) do
			if v.visible and k ~= card.ability.poker_hand_1 then _poker_hands[#_poker_hands+1] = k end
		end
		card.ability.poker_hand_2 = pseudorandom_element(_poker_hands, pseudoseed('plasma'))
	end,
	calculate = function(self, card, context)
		if context.cardarea == G.jokers and ((context.end_of_round and not context.blueprint) or (context.after and card.ability.reset)) then
			card.ability.reset = false
			local _poker_hands = {}
			for k, v in pairs(G.GAME.hands) do
				if v.visible and k ~= card.ability.poker_hand_1 and k ~= card.ability.poker_hand_2 then _poker_hands[#_poker_hands+1] = k end
			end
			card.ability.poker_hand_1 = pseudorandom_element(_poker_hands, pseudoseed('plasma'))
			_poker_hands = {}
			for k, v in pairs(G.GAME.hands) do
				if v.visible and k ~= card.ability.poker_hand_1 and k ~= card.ability.poker_hand_2 then _poker_hands[#_poker_hands+1] = k end
			end
			card.ability.poker_hand_2 = pseudorandom_element(_poker_hands, pseudoseed('plasma'))
			return {
				message = localize('k_reset')
			}
		end
		if context.joker_main then
			if context.scoring_name == card.ability.poker_hand_1 or context.scoring_name == card.ability.poker_hand_2 then
				local tot = hand_chips + mult
				hand_chips = math.floor(tot/2)
				mult = math.floor(tot/2)
				update_hand_text({delay = 0}, {mult = mult, chips = hand_chips})
				card.ability.reset = true
				return {
					message = localize("k_balanced"),
					colour = { 0.8, 0.45, 0.85, 1 },
				}
			end
		end
	end
})
SMODS.Joker({
	key = "razor_blade",
	atlas = "prismjokers",
	pos = {x=0,y=10},
	rarity = 3,
	cost = 6,
	pixel_size = { w = 47, h = 91},
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = {extra = 1},
	loc_vars = function(self, info_queue, center)
		local x_mult = 1
		if G.GAME.prism_start_deck_ranks then
			for k, v in pairs(G.GAME.prism_start_deck_ranks) do
				local is_present = false
				for _k, _v in pairs(G.playing_cards) do
					if not is_present and _v:get_id() == v then is_present = true end
				end
				if not is_present then
					x_mult = x_mult + center.ability.extra 
				end
			end
		end
		return {vars = {center.ability.extra, x_mult}}
	end,
	calculate = function(self, card, context)
		local x_mult = 1
		for k, v in pairs(G.GAME.prism_start_deck_ranks) do
			local is_present = false
			for _k, _v in pairs(G.playing_cards) do
				if not is_present and _v.base.id == v then is_present = true end
			end
			if not is_present then
				x_mult = x_mult + card.ability.extra 
			end
		end
		if context.joker_main then
			return {
				xmult = x_mult
			}
		end
	end
})

SMODS.Joker({
	key = "shork",
	atlas = "prismjokers",
	pos = {x=2,y=4},
	rarity = 3,
	cost = 7,
	unlocked = true,
	discovered = false,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
})

local orig_set_edition = Card.set_edition
function Card.set_edition(self,edition, immediate, silent)
	if next(find_joker("j_prism_shork")) and edition and not (type(edition) == "table" and next(edition) == nil) and edition ~= {polychrome = true} then
		orig_set_edition(self,{polychrome = true}, immediate, silent)
	else
		orig_set_edition(self,edition, immediate, silent)
	end

end
SMODS.Joker({
	key = "hypercube",
	atlas = "prismjokers",
	pos = {x=2,y=10},
	soul_pos = {x=2,y=11},
	rarity = 3,
	cost = 8,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = {e_mult = 1.33},
	loc_vars = function(self, info_queue, center)
		return { vars = {center.ability.e_mult} }
	end,
	calculate = function(self, card, context)
        if context.joker_main then
			local hands = evaluate_poker_hand(G.hand.cards)
      		local amount = #hands["Four of a Kind"]
			if amount > 0 then
				return {
					emult = card.ability.e_mult
				}
			end
		end
	end
}) 

SMODS.Joker({
	key = "prism",
	atlas = "prismjokers",
	pos = {x=0,y=14},
	rarity = 3,
	cost = 8,
	unlocked = true,
	discovered = false,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
})

local orig_is_suit = Card.is_suit
function Card.is_suit(self, suit, bypass_debuff, flush_calc)
    local is_numbered = type(self:get_id()) == 'number' and (self:get_id() >= 2 and self:get_id() <= 10) or false
	if not (self.debuff and not bypass_debuff) and (next(SMODS.find_card('j_prism_prism'))) and is_numbered then
        if SMODS.find_card('j_prism_prism') then
            return true
        end
	end
    return orig_is_suit(self, suit, bypass_debuff, flush_calc)
end

SMODS.Joker({
	key = "harlequin",
	atlas = "prismjokers",
	pos = { x = 0, y = 4 },
	soul_pos = { x = 0, y = 5 },
	rarity = 4,
	cost = 20,
	unlocked = false,
	unlock_condition = {hidden = true},
	discovered = false,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = { extra = { bonus = 0.1, x_mult = 1}, first_s=false,first_h=false,first_c=false,first_d=false},
	loc_vars = function(self, info_queue, center)
		return { vars = {center.ability.extra.bonus,center.ability.extra.x_mult} }
	end,
	calculate = function(self, card, context)
		if context.cardarea == G.jokers and context.before then
			card.ability.first_s = false
			card.ability.first_h = false
			card.ability.first_c = false
			card.ability.first_d = false
		end
		if context.joker_main then
			return {
				xmult = card.ability.extra.x_mult,
			}
		end
		local upgrade = false
		if context.cardarea == G.play and context.individual and not context.blueprint then
			if context.other_card:is_suit('Spades') and card.ability.first_s == false then
				card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.bonus
				card.ability.first_s = true
				upgrade = true
			end
			if context.other_card:is_suit('Hearts') and card.ability.first_h == false then
				card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.bonus
				card.ability.first_h = true
				upgrade = true
			end
			if context.other_card:is_suit('Clubs') and card.ability.first_c == false then
				card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.bonus
				card.ability.first_c = true
				upgrade = true
			end
			if context.other_card:is_suit('Diamonds') and card.ability.first_d == false then
				card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.bonus
				card.ability.first_d = true
				upgrade = true
			end
			if upgrade == true then
				return {
					focus = card,
					message = localize({ type = "variable", key = "a_xmult", vars = { card.ability.extra.x_mult } }),
					card = card,
				}
			end
		end
	end,
	
})

SMODS.Joker({
	key = "rigoletto",
	atlas = "prismjokers",
	pos = { x = 0, y = 7 },
	soul_pos = { x = 0, y = 8 },
	rarity = 4,
	cost = 20,
	unlocked = false,
	unlock_condition = {hidden = true},
	discovered = false,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	config = { extra = 1, hand_size = 0},
	loc_vars = function(self, info_queue, center)
		return { vars = {center.ability.extra,center.ability.hand_size} }
	end,
	remove_from_deck = function(self, card, from_debuff)
		G.hand:change_size(-card.ability.hand_size)
	end,
	calculate = function(self, card, context)
		if (context.cardarea == G.jokers and context.before) or context.discard and context.other_card == context.full_hand[1] then
			card.ability.hand_size = card.ability.hand_size + card.ability.extra
			G.hand:change_size(card.ability.extra)
			return {
				message = localize('k_upgrade_ex'),
				card = card,
			}
		end
		if context.cardarea == G.jokers and context.end_of_round then
			G.hand:change_size(-card.ability.hand_size)
			card.ability.hand_size = 0
			return {
				card = card,
				message = localize('k_reset')
			}
		end
	end,
})