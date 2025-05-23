local unstbex = SMODS.current_mod
local filesystem = NFS or love.filesystem
local path = unstbex.path
local unstbex_config = unstbex.config

--Global Table
unstbex_global = {}
unstbex_global.config = unstbex.config

unstbex_lib = {}

--Library
SMODS.load_file("/lib/suit_compat.lua")()

--Localization Messages
--local loc = filesystem.load(path..'localization.lua')()

-- Debug message

local function print(message)
    sendDebugMessage('[UnstableEX] - '..(tostring(message) or '???'))
end

print("Starting UnstableEX")

--Compat List

unstbex_global.compat = {
	Bunco = (SMODS.Mods["Bunco"] or {}).can_load,
	Familiar = (SMODS.Mods["familiar"] or {}).can_load,
	Ortalab = (SMODS.Mods["ortalab"] or {}).can_load,
	Six_Suit = (SMODS.Mods["SixSuits"] or {}).can_load,
	Inks_Color = (SMODS.Mods["InkAndColor"] or {}).can_load,
	Cryptid = (SMODS.Mods["Cryptid"] or {}).can_load,
	CustomCards = (SMODS.Mods["CustomCards"] or {}).can_load,
	Pokermon = (SMODS.Mods["Pokermon"] or {}).can_load,
	KCVanilla = (SMODS.Mods["kcvanilla"] or {}).can_load,
	DnDJ = (SMODS.Mods["dndj"] or {}).can_load,
	MtJ = (SMODS.Mods["magic_the_jokering"] or {}).can_load,
	Minty = (SMODS.Mods["MintysSillyMod"] or {}).can_load,
	Cardsauce = (SMODS.Mods["Cardsauce"] or {}).can_load,
	Showdown = (SMODS.Mods["showdown"] or {}).can_load,
	Paperback = (SMODS.Mods["paperback"] or {}).can_load,
}

local function check_mod_active(mod_id)
	return unstbex_global.compat[mod_id]
end

--Config Stuff

function unstbex.save_config(self)
    SMODS.save_mod_config(self)
end

local unstbex_config_tab = function()
	--Dynamically Building Config Based on loaded mods
	--I'll figure out how to make paginations later
	
	local mod_config_ui_tables = {}
	local function create_mod_config(mod_name, conf_list)
		if not check_mod_active(mod_name.key) then return end

		local ui_nodes = {}
		ui_nodes[1] = {n=G.UIT.R, config={align = "cm"}, nodes={{n = G.UIT.T, config = {text = mod_name.name or mod_name.key, colour = G.C.ORANGE, scale = 0.5}}}}
		
		for k,v in pairs(conf_list) do
			ui_nodes[#ui_nodes+1] = create_toggle({label = v.label, ref_table = unstbex.config[v.ref_table], ref_value = k, callback = function() unstbex:save_config() end})
		end
		
		mod_config_ui_tables[#mod_config_ui_tables+1] = {n=G.UIT.R, config={align = "cl"}, nodes = ui_nodes }
	end


	local function mod_config_ui_init()
		
		--List of ALL possible mod config
		
		create_mod_config({key=  "DnDJ", name = "DnDJ"}, {
		keep_sprite = {label = "Keep Rank Sprites", ref_table = "dndj"},
		})
		
		create_mod_config({key=  "Showdown", name = "Showdown"}, {
		use_decimal = {label = "Use Decimal Mechanics", ref_table = "showdown"},
		replace_zero = {label = "Replace Rank 0", ref_table = "showdown"},
		})
	end

	mod_config_ui_init();

	--Rendering
	local render_table = {}
	local restart_header = nil
	
	if #mod_config_ui_tables > 0 then
		for i=1, #mod_config_ui_tables do
			render_table[#render_table+1] = mod_config_ui_tables[i]
		end
		
		restart_header = {n=G.UIT.R, config={align = "cm"}, nodes={{n = G.UIT.T, config = {text = localize("unstb_config_requires_restart"), colour = G.C.RED, scale = 0.4}}}}
	else
		render_table = {{n=G.UIT.R, config={align = "cl"}, nodes={
						
						{n=G.UIT.R, config={align = "cm"}, nodes={{n = G.UIT.T, config = {text = "No configurable options found for the current modlist", scale = 0.5}}}},
						}}}
	end
	
	
	return{
		{
		label = "Config",
		chosen = true,
		tab_definition_function = function()
		return {
			n = G.UIT.ROOT,
				config = {
					emboss = 0.05,
					minh = 6,
					r = 0.1,
					minw = 10,
					align = "cm",
					padding = 0.2,
					colour = G.C.BLACK,
				},
				nodes = {
				
					{n=G.UIT.R, config={align = "cm"}, nodes= {restart_header} },
				
					{n=G.UIT.R, config={align = "cm"}, nodes={ --Base Box containing everything
		
					-- Left Side Column
					{n=G.UIT.C, config={align = "cl", padding = 0.2}, nodes = render_table }, 
					
					-- Right Side Column
					--{n=G.UIT.C, config={align = "cl"}, nodes = render_table}, 
				
				}}
				},
		}
		end
		},
		
		--[[{ --Reserved Tab, in case the settings are expended in the future
		label = localize("unstb_config_header_joker_settings"),
		tab_definition_function = function()
		return {
			n = G.UIT.ROOT,
				config = {
					emboss = 0.05,
					minh = 6,
					r = 0.1,
					minw = 10,
					align = "cm",
					padding = 0.2,
					colour = G.C.BLACK,
				},
				nodes = {
				
				},
			
		
		}
		end
		}]]
	}
end

unstbex.extra_tabs = unstbex_config_tab

--Just so the gear icon shows up
unstbex.config_tab = true

--Map config value with a single string keyword
local config_value = {
    --["rank_21"] = unstb_config.rank.rank_21,
    
}

--Utility

--Auto event scheduler, based on Bunco
local function event(config)
    local e = Event(config)
    G.E_MANAGER:add_event(e)
    return e
end

local function big_juice(card)
    card:juice_up(0.7)
end

local function extra_juice(card)
    card:juice_up(0.6, 0.1)
end

local function play_nope_sound()
	--Copied from Wheel of Fortune lol
	event({trigger = 'after', delay = 0.06*G.SETTINGS.GAMESPEED, blockable = false, blocking = false, func = function()
           play_sound('tarot2', 0.76, 0.4);return true end})
    play_sound('tarot2', 1, 0.4)
end

local function forced_message(message, card, color, delay, juice)
    if delay == true then
        delay = 0.7 * 1.25
    elseif delay == nil then
        delay = 0
    end

    event({trigger = 'before', delay = delay, func = function()

        if juice then big_juice(juice) end

        card_eval_status_text(
            card,
            'extra',
            nil, nil, nil,
            {message = message, colour = color, instant = true}
        )
        return true
    end})
end

-- Index-based coordinates generation

local function get_coordinates(position, width)
    if width == nil then width = 10 end -- 10 is default for Jokers
    return {x = (position) % width, y = math.floor((position) / width)}
end

--Mod Icon
SMODS.Atlas {
  -- Key for code to find it with
  key = "modicon",
  -- The name of the file, for the code to pull the atlas from
  path = "modicon.png",
  -- Width of each sprite in 1x size
  px = 32,
  -- Height of each sprite in 1x size
  py = 32
}

--Creates an atlas for cards to use
--[[SMODS.Atlas {
  -- Key for code to find it with
  key = "unstbEX_jokers",
  -- The name of the file, for the code to pull the atlas from
  path = "unstbEX_jokers.png",
  -- Width of each sprite in 1x size
  px = 71,
  -- Height of each sprite in 1x size
  py = 95
}]]

--Updated Enhancement atli to include modded suits
SMODS.Atlas {
  key = "enh_slop",
  path = "enh_slop.png",
  px = 71,
  py = 95
}

SMODS.Atlas {
  key = "enh_slop_hc",
  path = "enh_slop_hc.png",
  px = 71,
  py = 95
}

SMODS.Atlas {
  key = "enh_res",
  path = "enh_res.png",
  px = 71,
  py = 95
}

--Fallback atlas for extra ranks

SMODS.Atlas {
  key = "rank_ex_default",
  path = "rank_ex/default/rank_ex.png",
  px = 71,
  py = 95
}

SMODS.Atlas {
  key = "rank_ex2_default",
  path = "rank_ex/default/rank_ex2.png",
  px = 71,
  py = 95
}

--Bunco's resprites suit colours
SMODS.Atlas {
  key = "rank_ex_hc_b",
  path = "rank_ex/bunco/rank_ex_hc_b.png",
  px = 71,
  py = 95
}

SMODS.Atlas {
  key = "rank_ex2_hc_b",
  path = "rank_ex/bunco/rank_ex2_hc_b.png",
  px = 71,
  py = 95
}

SMODS.Atlas {
  key = "enh_slop_hc_b",
  path = "enh_slop_hc_b.png",
  px = 71,
  py = 95
}

--Cardsauce Skin

local use_cardsauce_skin = false

if check_mod_active("Cardsauce") then

use_cardsauce_skin = csau_enabled['enableSkins']

SMODS.Atlas {
  key = "rank_ex_cs",
  path = "rank_ex/cardsauce/rank_ex_cs.png",
  px = 71,
  py = 95
}

SMODS.Atlas {
  key = "rank_ex2_cs",
  path = "rank_ex/cardsauce/rank_ex2_cs.png",
  px = 71,
  py = 95
}

end

--Familiar's Multi-Suit Cards Fallback
--(I don't think it is possible to make all combinations by myself, especially to account for modded suits)
SMODS.Atlas {
  key = "rank_ex_multi",
  path = "rank_ex_multi.png",
  px = 71,
  py = 95
}

SMODS.Atlas {
  key = "rank_ex2_multi",
  path = "rank_ex2_multi.png",
  px = 71,
  py = 95
}

--Map new atlas to the rank - new ranks now used more than 1 atlas (split off for maintenance reason)
local rank_atlas_map = {['unstb_0'] = 1,
						['unstb_0.5'] = 1,
						['unstb_1'] = 1,
						['unstb_r2'] = 1,
						['unstb_e'] = 1,
						['unstb_Pi'] = 1,
						['unstb_21'] = 1,
						['unstb_???'] = 1,
						
						['unstb_11'] = 2,
						['unstb_12'] = 2,
						['unstb_13'] = 2,
						['unstb_25'] = 2,
						['unstb_161'] = 2,}
						
local rank_atlas_name = {'unstbex_rank_ex', 'unstbex_rank_ex2'}

--Swap the hc atli with bunco resprites version to match suit colours
local using_bunco_resprites = false
if check_mod_active("Bunco") then
	if BUNCOMOD and BUNCOMOD.content and BUNCOMOD.content.config then
		using_bunco_resprites = BUNCOMOD.content.config.fixed_sprites
	end
end

local vanilla_suits = {Hearts = true,
							Clubs = true,
							Diamonds = true,
							Spades = true,
}

unstbex_lib.extra_suits = {}

--Init extra suits information based on loaded mod

if check_mod_active("Bunco") then
	unstbex_lib.init_suit_compat('bunc_Fleurons', 'bunco')
	unstbex_lib.init_suit_compat('bunc_Halberds', 'bunco')
end

if check_mod_active("Six_Suit") then
	unstbex_lib.init_suit_compat('six_Stars', 'sixsuits', true)
	unstbex_lib.init_suit_compat('six_Moons', 'sixsuits', true)
end

if check_mod_active("Inks_Color") then
	unstbex_lib.init_suit_compat('ink_Inks', 'inkscolor', true)
	unstbex_lib.init_suit_compat('ink_Colors', 'inkscolor', true)
end

if check_mod_active("MtJ") then
	unstbex_lib.init_suit_compat('mtg_Clovers', 'mtj')
end

if check_mod_active("Minty") then
	unstbex_lib.init_suit_compat('minty_3s', 'minty', true)
end

if check_mod_active("Paperback") then
	unstbex_lib.init_suit_compat('paperback_Stars', 'paperback')
	unstbex_lib.init_suit_compat('paperback_Crowns', 'paperback')
end

--Suit injection code based on Showdown by Mistyk__
local function inject_p_card_suit_compat(suit, rank)
	local card = {
		name = rank.key .. ' of ' .. suit.key,
		value = rank.key,
		suit = suit.key,
		pos = { x = rank.pos.x, y = rank.suit_map[suit.key] or suit.pos.y },
		lc_atlas = rank.suit_map[suit.key] and rank.lc_atlas or suit.lc_atlas,
		hc_atlas = rank.suit_map[suit.key] and rank.hc_atlas or suit.hc_atlas,
	}
	if not vanilla_suits[card.suit] then
		if not unstbex_lib.extra_suits[card.suit] then
			print("Warning: Unknown suit for "..card.name)
			card.lc_atlas = rank_atlas_name[rank_atlas_map[rank.key]]..'_default'
			card.hc_atlas = rank_atlas_name[rank_atlas_map[rank.key]]..'_default'
			card.pos.y = 0
		else
			card.lc_atlas = unstbex_lib.extra_suits[card.suit].lc_atlas[rank_atlas_map[rank.key]]
			card.hc_atlas = unstbex_lib.extra_suits[card.suit].hc_atlas[rank_atlas_map[rank.key]]
		end
	end
	G.P_CARDS[suit.card_key .. '_' .. rank.card_key] = card
end

local function rank_injection(self)
	print("Performing extra rank injection")
	for _, suit in pairs(SMODS.Suits) do
		inject_p_card_suit_compat(suit, self)
	end
end

local function inject_rank_atlas(prefix)
	for k,v in pairs(SMODS.Ranks) do
		if k:find(prefix) then
			local rank = SMODS.Ranks[k]
			
			rank.inject = rank_injection
			
			if use_cardsauce_skin then
				rank.lc_atlas = rank_atlas_name[rank_atlas_map[k]]..'_cs'
				rank.hc_atlas = rank_atlas_name[rank_atlas_map[k]]..'_cs'
			end
			
			if using_bunco_resprites then
				rank.hc_atlas = rank_atlas_name[rank_atlas_map[k]]..'_hc_b'
			end
			
			--[[rank.lc_atlas = rank_atlas_map[k]
			rank.hc_atlas = using_bunco_resprites and rank_atlas_map[k]..'_hc_b' or rank_atlas_map[k]..'_hc'
			rank.suit_map = unstbex_global.rank_suit_map]]

			print("Injecting the graphic for rank "..rank.key)
		end
	end
end

inject_rank_atlas('unstb_')

--Register Suits for UnStable suit system

--Modded Suits Code in UnStableEX

--Bunco
--[[register_suit_group("suit_black", "bunc_Halberds")
register_suit_group("suit_red", "bunc_Fleurons")

register_suit_group("suit_black", "six_Moons")
register_suit_group("suit_red", "six_Stars")

register_suit_group("no_smear", "Inks_Inks")
register_suit_group("no_smear", "Inks_Color")]]

--Update extended atlas for Slop and Resource Cards

--Separated from rank suit map now
local enhancement_suit_map = {
	Hearts = 0,
	Clubs = 1,
	Diamonds = 2,
	Spades = 3,
	
	bunc_Fleurons = 4,
	bunc_Halberds = 5,
	
	six_Stars = 6,
	six_Moons = 7,
	
	ink_Inks = 8,
	ink_Colors = 9,
}

local center_unstb_slop = SMODS.Centers['m_unstb_slop'] or {}
center_unstb_slop.suit_map = enhancement_suit_map
center_unstb_slop.atlas = 'unstbex_enh_slop'
center_unstb_slop.lc_atlas = 'unstbex_enh_slop'
center_unstb_slop.hc_atlas = using_bunco_resprites and 'unstbex_enh_slop_hc_b' or 'unstbex_enh_slop_hc'

local center_unstb_resource = SMODS.Centers['m_unstb_resource'] or {}
center_unstb_resource.suit_map = enhancement_suit_map
center_unstb_resource.atlas = 'unstbex_enh_res'

--Generic Rank Replacement Utility

--A map of orignal mod's rank, to new rank, and the mod's tag to check if the config is enabled or not
local replace_rank_map = {}

function register_rank_replacement(originalrank, newrank, keepsprite)
	replace_rank_map[originalrank] = {new_rank = newrank, keep_sprite = keepsprite}
end

local ref_card_set_base = Card.set_base
function Card:set_base(card, initial)
    card = card or {}
	
	ref_card_set_base(self, card, initial)
	
	--Only run this piece of codes when inside the run (so, menu animations aren't interrupted)
	if G.GAME and G.GAME.blind then
		if self.base and self.base.value and replace_rank_map[self.base.value] then
		
			local replace_rank_data = replace_rank_map[self.base.value]
		
			if replace_rank_data.keep_sprite and vanilla_suits[self.base.suit] then
				--Re-assign the rank to UnStable's equivalent
				--Doing it this way should keep the sprites unchanged
				
				--Automatically replaced it completely if the suit isn't vanilla for stable reasons
				
				self.base.value = replace_rank_data.new_rank
				
				local rank = SMODS.Ranks[self.base.value] or {}
				self.base.nominal = rank.nominal or 0
				self.base.face_nominal = rank.face_nominal or 0
				self.base.id = rank.id
			else
				SMODS.change_base(self, nil, replace_rank_map[self.base.value].new_rank)
			end
			
			
		end
	end
end


--Blacklist "top" ranks for many jokers
local top_rank_blacklist = {
	['Ace'] = true,
	['unstb_21'] = true,
	['unstb_25'] = true,
	['unstb_161'] = true,
	['unstb_???'] = true,
}

if check_mod_active("Bunco") then

print("Inject Bunco Jokers")

local bunc_pawn = SMODS.Centers['j_bunc_pawn'] or {}

--Blacklist ranks for Pawn

bunc_pawn.loc_vars = function(self, info_queue, card)
	if G.playing_cards and #G.playing_cards > 0 then
		local rank = math.huge
		local target_rank = 'unstb_???';
		for _, deck_card in ipairs(G.playing_cards) do
			local newrank = deck_card.base.nominal + (deck_card.base.face_nominal or 0)
			if newrank < rank and (not deck_card.config.center.no_rank or deck_card.config.center ~= G.P_CENTERS.m_stone) then
				rank = newrank
				target_rank = deck_card.base.value
			end
		end
		return {vars = {localize(target_rank, 'ranks')}}
	end
	return {vars = {localize('2', 'ranks')}}
end

bunc_pawn.calculate = function(self, card, context)
	if context.after and context.scoring_hand and not context.blueprint then
		for i = 1, #context.scoring_hand do
			local condition = false
			local other_card = context.scoring_hand[i]
			local rank = math.huge
			local target_rank = 'unstb_???';
			for _, deck_card in ipairs(G.playing_cards) do
				local newrank = deck_card.base.nominal + (deck_card.base.face_nominal or 0)
				if newrank < rank and (not deck_card.config.center.no_rank or deck_card.config.center ~= G.P_CENTERS.m_stone) then
					rank = newrank
					target_rank = deck_card.base.value
				end
			end
			if other_card.base.value == target_rank and not top_rank_blacklist[other_card.base.value] then
				condition = true
				event({trigger = 'after', delay = 0.15, func = function() other_card:flip(); play_sound('card1', 1); other_card:juice_up(0.3, 0.3); return true end })
				event({
					trigger = 'after',
					delay = 0.1,
					func = function()
						local new_rank = get_next_x_rank(other_card.base.value, 1)
						assert(SMODS.change_base(other_card, nil, new_rank))
						return true
					end
				})
				event({trigger = 'after', delay = 0.15, func = function() other_card:flip(); play_sound('tarot2', 1, 0.6); big_juice(card); other_card:juice_up(0.3, 0.3); return true end })
			end
			if condition then delay(0.7 * 1.25) end
		end
	end
end

local bunc_zero_shapiro = SMODS.Centers['j_bunc_zero_shapiro'] or {}

local zeroshapiro_zerorank = {
	['unstb_0'] = true,
	['unstb_???'] = true,
	['Jack'] = true,
	['Queen'] = true,
	['King'] = true,
	
	['showdown_Butler'] = true,
	['showdown_Princess'] = true,
	['showdown_Lord'] = true,
	['showdown_Zero'] = true,
}

bunc_zero_shapiro.calculate = function(self, card, context)
	if context.individual and context.cardarea == G.play then
		if context.other_card.config.center.no_rank or zeroshapiro_zerorank[context.other_card.base.value] then
			if pseudorandom('zero_shapiro'..G.SEED) < G.GAME.probabilities.normal / card.ability.extra.odds then
				return {
					extra = {message = '+'..localize{type = 'name_text', key = 'tag_d_six', set = 'Tag'}, colour = G.C.GREEN},
					card = card,
					func = function()
						event({func = function()
							add_tag(Tag('tag_d_six'))
							return true
						end})
					end
				}
			end
		end
	end
end

local bunc_crop_circles = SMODS.Centers['j_bunc_crop_circles'] or {}

local crop_circles_rank_mult = {
	['unstb_0'] = 1,
	['unstb_0.5'] = 1,
	['6'] = 1,
	['8'] = 2,
	['9'] = 1,
	['10'] = 1,
	['Queen'] = 1,
	
	['unstb_161'] = 1,
	
	['showdown_8.5'] = 2,
	--['showdown_Butler'] = 2,
	--['showdown_Princess'] = 1,
	['showdown_Zero'] = 1,
}

--Implemented differently than in Bunco, but should yield the same result
bunc_crop_circles.calculate = function(self, card, context)
	if context.individual and context.cardarea == G.play then
		local other_card = context.other_card
		local total_mult = 0
		
		--Check suit
		if not other_card.config.center.no_suit then
			if other_card.base.suit == 'bunc_Fleurons' then
				total_mult = total_mult + 4
			elseif other_card.base.suit == 'Clubs' then
				total_mult = total_mult + 3
			elseif other_card.base.suit == 'mtg_Clovers' then
				total_mult = total_mult + 4
			end			
		end
		
		--Check rank
		if not other_card.config.center.no_rank then
			if crop_circles_rank_mult[other_card.base.value] then
				total_mult = total_mult + crop_circles_rank_mult[other_card.base.value]
			end
		end
		
		--If the amount is greater than 0, grant the bonus w/ animation
		if total_mult > 0 then
			return {
				mult = total_mult,
				card = card
            }
		end
	end
end

end


--Hook to Familiar's set_sprite_suits to account for new ranks
local unstb_ranks_pos = {['unstb_0'] = 6,
						['unstb_0.5'] = 2,
						['unstb_1'] = 5,
						['unstb_r2'] = 7,
						['unstb_e'] = 3,
						['unstb_Pi'] = 4,
						['unstb_21'] = 0,
						['unstb_???'] = 1,
						
						['unstb_11'] = 0,
						['unstb_12'] = 1,
						['unstb_13'] = 2,
						['unstb_25'] = 3,
						['unstb_161'] = 4,}

if check_mod_active("Familiar") then

print('Inject Familiar set_sprite_suits')

local ref_set_sprite_suits = set_sprite_suits

function set_sprite_suits(card, juice)
	ref_set_sprite_suits(card, juice)
	
	--If the rank is one of the UnStable Rank, and has one of the ability
	if unstb_ranks_pos[card.base.value] and (card.ability.is_spade or card.ability.is_heart or card.ability.is_club or card.ability.is_diamond or card.ability.suitless) then
		--print('UnstbEX Set Sprite Suit Hook Active')
	
		local suit_check = {card.base.suit == 'Spades' or card.ability.is_spade or false,
							card.base.suit == 'Hearts' or card.ability.is_heart or false,
							card.base.suit == 'Clubs' or card.ability.is_club or false,
							card.base.suit == 'Diamonds' or card.ability.is_diamond or false}
							
		local suit_count = 0
		for i=1, #suit_check do
			if suit_check[i] then
				suit_count = suit_count+1
			end
		end
		
		--Suitless, or has more than 1 suits
		if card.ability.suitless or suit_count>1 then
			--Technically, if anyone wants to make it works properly, this would be where to check
			--Unfortunately, I don't think I can write them all because there's a lot of combination + lots of graphic to make
			--Hopefully there is a more elegant solution found in the future.
		
			card.children.front.atlas = G.ASSET_ATLAS[rank_atlas_name[rank_atlas_map[card.base.value]]..'_multi']
			card.children.front:set_sprite_pos({x = unstb_ranks_pos[card.base.value], y = 0})
		end
		
	end
end

print("Inject Familiar Vigor Fortune Card")

local familiar_vigor = SMODS.Centers['c_fam_vigor'] or {}

--Reimplemented Familiar Vigor Fortune Card to use get_next_x_rank instead
familiar_vigor.use = function(self, card)
	for i = 1, #G.hand.highlighted do
		for j = 1, 3 do
			G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
				local card = G.hand.highlighted[i]
				local new_rank = get_next_x_rank(card.base.value, 1)
				assert(SMODS.change_base(card, nil, new_rank))
				card:juice_up(0.3, 0.5)
			return true end }))
		end
	end  
end
	
end


--Re-implementation of Ortalab's Index Card functions to support UNSTB Ranks

--Notice: this rank changes the behavior from vanilla slightly, where rank 0 and 1 is immediately available
local main_rankList = {'unstb_0', 'unstb_1', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace'}

--Special UNSTB Rank is pre-defined
local rankMap = { 	['unstb_0.5'] = {UP = 'unstb_1', MID = 'unstb_0.5' , DOWN = 'unstb_0'},
					['unstb_r2'] = {UP = '2', MID = 'unstb_r2' , DOWN = 'unstb_1'},
					unstb_e = {UP = '3', MID = 'unstb_e' , DOWN = '2'},
					unstb_Pi = {UP = '4', MID = 'unstb_Pi' , DOWN = '3'},
					unstb_21 = {UP = 'unstb_21', MID = 'unstb_21' , DOWN = 'unstb_21'},
					
					unstb_11 = {UP = 'unstb_12', MID = 'unstb_11' , DOWN = '10'},
					unstb_12 = {UP = 'unstb_13', MID = 'unstb_12' , DOWN = 'unstb_11'},
					unstb_13 = {UP = 'Ace', MID = 'unstb_13' , DOWN = 'unstb_12'},
					
					unstb_25 = {UP = 'unstb_25', MID = 'unstb_25' , DOWN = 'unstb_25'},
					unstb_161 = {UP = 'unstb_161', MID = 'unstb_161' , DOWN = 'unstb_161'},
					
					['unstb_???'] = {UP = 'unstb_???', MID = 'unstb_???' , DOWN = 'unstb_???'},
					
					['showdown_2.5'] = {UP = '3', MID = 'showdown_2.5' , DOWN = '2'},
					['showdown_5.5'] = {UP = '6', MID = 'showdown_5.5' , DOWN = '5'},
					['showdown_8.5'] = {UP = '9', MID = 'showdown_8.5' , DOWN = '8'},
					
					['showdown_Butler'] = {UP = 'Queen', MID = 'showdown_Butler' , DOWN = 'Jack'},
					['showdown_Princess'] = {UP = 'King', MID = 'showdown_Princess' , DOWN = 'Queen'},
					['showdown_Lord'] = {UP = 'Ace', MID = 'showdown_Lord' , DOWN = 'King'},
					
					['showdown_Zero'] = {UP = 'unstb_1', MID = 'showdown_Zero' , DOWN = 'Ace'},
}

for i=1, #main_rankList do
	rankMap[main_rankList[i]] = {UP = main_rankList[i+1] or main_rankList[1], MID = main_rankList[i], DOWN = main_rankList[i-1] or main_rankList[#main_rankList]}
end

--print(inspectDepth(rankMap))

if check_mod_active("Ortalab") then

print('Inject Ortalab Index Card')

--Inject new property into Ortalab index card
local ortalab_index = SMODS.Centers['m_ortalab_index'] or {}

ortalab_index.set_ability = function(self, card, initial, delay_sprites)
		print('call set ability')

		if card.base and card.ability and card.ability.extra and type(card.ability.extra) == 'table' then
			if card.ability.extra.index_state == 'MID' then
				card.ability.extra.mainrank = card.base.value
            elseif card.ability.extra.index_state == 'UP' then
				card.ability.extra.mainrank = rankMap[card.base.value]['DOWN']
            elseif card.ability.extra.index_state == 'DOWN' then
				card.ability.extra.mainrank = rankMap[card.base.value]['UP']
			end
		end
    end

ortalab_index.set_sprites = function(self, card, front)
        if card.ability and card.ability.extra and type(card.ability.extra) == 'table' then 
			
            if card.ability.extra.index_state == 'MID' then
				card.children.center:set_sprite_pos({x = 2, y = 0}) 
            elseif card.ability.extra.index_state == 'UP' then
				--card.ability.extra.mainrank = rankMap[card.base.value]['DOWN']
				card.children.center:set_sprite_pos({x = 1, y = 2}) 
            elseif card.ability.extra.index_state == 'DOWN' then
				card.children.center:set_sprite_pos({x = 0, y = 2})
			end
			
			--print('main card value is '.. card.ability.extra.mainrank)
        end
end

ortalab_index.update = function(self, card)
		--Jank, handles special case where Tarot like Strength was used
		if (card.VT.w <= 0) then
			local isCollection = (card.area and card.area.config.collection) or false
		
			if not isCollection then
				if card.ability.extra.index_state == 'MID' then
					card.ability.extra.mainrank = card.base.value
				elseif card.ability.extra.index_state == 'UP' then
					card.ability.extra.mainrank = rankMap[card.base.value]['DOWN']
				elseif card.ability.extra.index_state == 'DOWN' then
					card.ability.extra.mainrank = rankMap[card.base.value]['UP']
				end
			end
			
			--print('main card value changed to '.. card.ability.extra.mainrank)
		end
    end

G.FUNCS.increase_index = function(e, mute, nosave)
	--print('using unstbex implementation of func')

    e.config.button = nil
    local card = e.config.ref_table
    local area = card.area
    local change = 1
    if card.ability.extra.index_state == 'DOWN' then change = 2 end
    card.ability.extra.index_state = 'UP'
    card.children.center:set_sprite_pos({x = 1, y = 2})
	
    SMODS.change_base(card, nil, rankMap[card.ability.extra.mainrank] and rankMap[card.ability.extra.mainrank]['UP'] or 'unstb_???')
end

G.FUNCS.mid_index = function(e, mute, nosave)
	--print('using unstbex implementation of func')

    e.config.button = nil
    local card = e.config.ref_table
    local area = card.area
    local change = 1
    if card.ability.extra.index_state == 'UP' then change = -1 end
    card.ability.extra.index_state = 'MID'
    card.children.center:set_sprite_pos({x = 2, y = 0})
    --card.base.id = card.base.id + change
    SMODS.change_base(card, nil, rankMap[card.ability.extra.mainrank] and rankMap[card.ability.extra.mainrank]['MID'] or 'unstb_???')
end

G.FUNCS.decrease_index = function(e, mute, nosave)
	--print('using unstbex implementation of func')

    e.config.button = nil
    local card = e.config.ref_table
    local area = card.area
    local change = 1
    if card.ability.extra.index_state == 'UP' then change = 2 end
    card.ability.extra.index_state = 'DOWN'
    card.children.center:set_sprite_pos({x = 0, y = 2}) 
    --card.base.id = card.base.id - change
	
    SMODS.change_base(card, nil, rankMap[card.ability.extra.mainrank] and rankMap[card.ability.extra.mainrank]['DOWN'] or 'unstb_???')
end

--More safety check
--[[
G.FUNCS.index_card_increase = function(e)
	
	if not e.config.ref_table.ability.extra or type(e.config.ref_table.ability.extra) ~= 'table' then
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
		
		return
	end
	
    if e.config.ref_table.ability.extra.index_state ~= 'UP' then 
        e.config.colour = G.C.RED
        e.config.button = 'increase_index'
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end

G.FUNCS.index_card_mid = function(e)
	if not e.config.ref_table.ability.extra or type(e.config.ref_table.ability.extra) ~= 'table' then
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
		return
	end
	
    if e.config.ref_table.ability.extra.index_state ~= 'MID' then 
        e.config.colour = G.C.RED
        e.config.button = 'mid_index'
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end

G.FUNCS.index_card_decrease = function(e)
	if not e.config.ref_table.ability.extra or type(e.config.ref_table.ability.extra) ~= 'table' then
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
		
		return
	end
	
    if e.config.ref_table.ability.extra.index_state ~= 'DOWN' then 
        e.config.colour = G.C.RED
        e.config.button = 'decrease_index'
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end]]

print("Inject Ortalab Flag Loteria")

local ortalab_lot_flag = SMODS.Centers['c_ortalab_lot_flag'] or {}

--Reimplementation to use UnStable version of get_next_x_rank
ortalab_lot_flag.use = function(self, card, area, copier)
	--print("UnStbEX version")

	track_usage(card.config.center.set, card.config.center_key)
	local options = {}
	for i=1, card.ability.extra.rank_change do
		table.insert(options, i)
	end
	for i=1, #G.hand.highlighted do
		local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
		G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
	end
	for _, card in pairs(G.hand.highlighted) do
		local sign = pseudorandom(pseudoseed('flag_sign')) > 0.5 and 1 or -1
		local change = pseudorandom_element(options, pseudoseed('flag_change'))
		for i=1, change do
			G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.4,func = function()	
				local new_rank = get_next_x_rank(card.base.value, sign)
				assert(SMODS.change_base(card, nil, new_rank))
			return true end }))
		end
		-- card_eval_status_text(card, 'extra', nil, nil, nil, {message = tostring(sign*change), colour = G.ARGS.LOC_COLOURS.loteria, delay = 0.4})
	end
	for i=1, #G.hand.highlighted do
		local percent = 0.85 + (i-0.999)/(#G.hand.highlighted-0.998)*0.3
		G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('tarot2', percent, 0.6);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
	end
	G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
	delay(0.5)
end

--Inject Ortalab Joker code

--Mathmagician
--Now used the same check from UnStable like Odd Todd and Even Steven
local ortalab_mathmagician = SMODS.Centers['j_ortalab_mathmagician'] or {}
ortalab_mathmagician.calculate = function(self, card, context) --Mathmagician logic
	if context.discard and context.other_card == context.full_hand[#context.full_hand] then
		local numbered_even = 0
		local numbered_odd = 0
		for _, v in ipairs(context.full_hand) do
		
			--Hardcoded check for ??? rank
			--For that, it counts as both. So it increments whatever needed left
			if v.base.value == 'unstb_???' then
				if numbered_odd < 2 then
					numbered_odd = numbered_odd + 1
				else
					numbered_even = numbered_even + 1 
				end
			else
				--General case, use modulo check from UnStable
				if unstb_global.modulo_check(v, 2, 1) then 
					numbered_odd = numbered_odd + 1 
				elseif unstb_global.modulo_check(v, 2, 0) then 
					numbered_even = numbered_even + 1 
				end
			end
		end
		if numbered_even >= 2 and numbered_odd >= 2 and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
			local choice = pseudorandom('mathmagician') > 0.5 and 'Loteria' or 'Zodiac'
			G.E_MANAGER:add_event(Event({
				func = (function()
					G.E_MANAGER:add_event(Event({
						func = function() 
							local card = create_card(choice, G.consumeables)
							card:add_to_deck()
							G.consumeables:emplace(card)
							G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
							return true
					end}))   
					card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('ortalab_'..string.lower(choice)..'_add'), colour = G.C.SET.Loteria})
					return true
			end)}))
		end
	end
end


end

--Cryptid Compat

if check_mod_active("Cryptid") then

--Special interaction w/ Plagiarism and rigged
--[[
local j_plagiarism = SMODS.Centers['j_unstb_plagiarism']

if j_plagiarism then

local ref_j_plagiarism_calculate = j_plagiarism.calculate

j_plagiarism.calculate = function(self, card, context)
	--Alternate function entirely if it's rigged
	if card.ability.cry_rigged then
		--Code based on Familiar's Crimsonotype
		
		--This bit of code runs before hand played, cannot copyable by other blueprint
		if context.before and not context.blueprint and not context.repetition and not context.repetition_only then
			forced_message('Both', card, G.C.ORANGE, true)
		end
		
		local other_joker = nil
		for i = 1, #G.jokers.cards do
			if G.jokers.cards[i] == card then
				other_joker = {G.jokers.cards[i - 1], G.jokers.cards[i + 1]}
			end
		end
		
		if other_joker then
			for i = 1, #other_joker do
				if other_joker[i] and other_joker[i] ~= self then 
					--local newcontext = context
					context.blueprint = (context.blueprint and (context.blueprint + 1)) or 1
					context.blueprint_card = context.blueprint_card or card

					if context.blueprint > #G.jokers.cards + 1 then
						return
					end

					local other_joker_ret, trig = other_joker[i]:calculate_joker(context)
					
					--Context needs resetting afterwards, otherwise this value keeps persisting
					context.blueprint = nil
					
					local eff_card = context.blueprint_card or card
					context.blueprint_card = nil
					
					if other_joker_ret or trig then
						if not other_joker_ret then
							other_joker_ret = {}
						end
						
						other_joker_ret.card = eff_card
						other_joker_ret.colour = G.C.GREEN
						other_joker_ret.no_callback = true
						
						if other_joker_ret then 
							--Jank, might result in message appear at wrong place idk but at least it should be executed properly
							SMODS.calculate_effect(other_joker_ret, context.individual and context.other_card or eff_card)
							--return other_joker_ret
						end
					end
				end
			end
		end
		
	else
		return ref_j_plagiarism_calculate(self, card, context)
	end
	
end

end]]


--Add appropiate Jokers to the pool

local function inject_cryptid_pool(joker_key, pool_list)
	local joker = SMODS.Centers[joker_key]
	
	if not joker then return end
	
	joker.pools = joker.pools or {}
	
	for i=1, #pool_list do
		joker.pools[pool_list[i]] = true
	end
end

--Placeholder, there's no food jokers yet in UNSTB and/or EX
--[[
if Cryptid.food then
	local food_jokers = {
	
	}
	
	for i = 1, #meme_jokers do
	  Cryptid.food[#Cryptid.food+1] = food_jokers[i]
	end
end]]

if Cryptid.memepack then
	--Adds pretty much most shitpost-centric Joker onto it
	local meme_jokers = {
		"j_unstb_joker2", --Joker 2
		"j_unstb_joker_stairs", --Joker Stairs
		"j_unstb_plagiarism", --Plagiarism
		"j_unstb_prssj", --prssj
		"j_unstb_the_jolly_joker", --The Jolly too just because
		"j_unstb_what", --69, 420. Unsure if this would break the in_pool tho
	}
	
	for i = 1, #meme_jokers do
	  --Cryptid.memepack[#Cryptid.memepack+1] = meme_jokers[i]
	  inject_cryptid_pool(meme_jokers[i], {"Meme"});
	end
end

end

-- Hook for is_suit, in case other mods injected into it and it got caught early by the UnStable's hook
-- Currently only used by CustomCards

if check_mod_active("CustomCards") then

local ref_card_is_suit = Card.is_suit

function Card:is_suit(suit, bypass_debuff, flush_calc, bypass_seal)

	local result = ref_card_is_suit(self, suit, bypass_debuff, flush_calc, bypass_seal)

	--Return early if true (suit seal case)
	if result then 
		return result
	end

	--If it is a trading card, check its own value
	if self.ability and self.ability.trading then
        local eval = self:calculate_exotic({bypass_debuff = bypass_debuff, flush_calc = flush_calc, is_suit = suit})
        if eval then
            return eval
        end
    end

	--Should only return false here at this point?
	return result
end

end

--Pokermon Compat
if check_mod_active("Pokermon") then

--Use get_next_x_rank instead
local ref_poke_vary_rank = poke_vary_rank
poke_vary_rank = function(card, decrease, seed)
	local new_rank
	if decrease then
		new_rank = get_next_x_rank(card.base.value, -1)
	elseif seed then
		new_rank = pseudorandom_element(SMODS.Ranks, pseudoseed(seed)).key
	else
		new_rank = get_next_x_rank(card.base.value, 1)
	end
	G.E_MANAGER:add_event(Event({
	  func = function()
		  SMODS.change_base(card, nil, new_rank)
		  return true
	  end
	})) 
end

--Inject Jokers Code
--Oddish and Bellsprout Lines now used UnStable method of checking odd and even numbers (same as Odd Todd and Even Steven)

--Oddish Line
local poke_oddish = SMODS.Centers['j_poke_oddish'] or {}
poke_oddish.calculate = function(self, card, context)
	if context.individual and context.cardarea == G.play and not context.other_card.debuff then
		if unstb_global.modulo_check(context.other_card, 2, 1) then
			local value
			if pseudorandom('oddish') < .50 then
				value = card.ability.extra.mult
			else
				value = card.ability.extra.mult2
			end
			return {
				message = localize{type = 'variable', key = 'a_mult', vars = {value}}, 
				colour = G.C.MULT,
				mult = value, 
				card = card
			}
		end
	end
	return level_evo(self, card, context, "j_poke_gloom")
end

local poke_gloom = SMODS.Centers['j_poke_gloom'] or {}
poke_gloom.calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play and not context.other_card.debuff then
      if unstb_global.modulo_check(context.other_card, 2, 1) then
          local value
          if pseudorandom('gloom') < .50 then
            value = card.ability.extra.mult
          else
            value = card.ability.extra.mult2
          end
          return {
            message = localize{type = 'variable', key = 'a_mult', vars = {value}}, 
            colour = G.C.MULT,
            mult = value,
            card = card
          }
      end
    end
    return item_evo(self, card, context)
end

local poke_vileplume = SMODS.Centers['j_poke_vileplume'] or {}
poke_vileplume.calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play and not context.other_card.debuff then
      if unstb_global.modulo_check(context.other_card, 2, 1) then
          if pseudorandom('vileplume') < .50 then
            return { 
              x_mult = card.ability.extra.Xmult_multi,
              card = card
            }
          else
            return { 
              mult = card.ability.extra.mult,
              card = card
            }
          end
      end
    end
  end

local poke_bellossom = SMODS.Centers['j_poke_bellossom'] or {}
poke_bellossom.calculate = function(self, card, context)
    if context.before and context.cardarea == G.jokers and not context.blueprint then
      local odds = {}
      for k, v in ipairs(context.scoring_hand) do
          local upgrade = pseudorandom(pseudoseed('bellossom'))
          if (unstb_global.modulo_check(v, 2, 1)) and upgrade > .50 then
              odds[#odds+1] = v
              if v.ability.name == 'Wild Card' and not v.edition then
                local edition = {polychrome = true}
                v:set_edition(edition, true, true)
              end
              v:set_ability(G.P_CENTERS.m_wild, nil, true)
              G.E_MANAGER:add_event(Event({
                  func = function()
                      v:juice_up()
                      return true
                  end
              })) 
          else
            v.bellossom_score = true
          end
      end
      if #odds > 0 then 
          return {
            message = localize("poke_petal_dance_ex"),
              colour = G.C.MULT,
              card = card
          }
      end
    end
    if context.individual and context.cardarea == G.play and not context.other_card.debuff then
      if unstb_global.modulo_check(context.other_card, 2, 1) then
          if context.other_card.bellossom_score then
            context.other_card.bellossom_score = nil
            return {
              message = localize{type = 'variable', key = 'a_mult', vars = {card.ability.extra.mult}}, 
              colour = G.C.MULT,
              mult = card.ability.extra.mult,
              card = card
            }
          end
      end
    end
end

local poke_bellsprout = SMODS.Centers['j_poke_bellsprout'] or {}
poke_bellsprout.calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play and not context.other_card.debuff then
      if unstb_global.modulo_check(context.other_card, 2, 0) then
          return {
            message = localize{type = 'variable', key = 'a_chips', vars = {card.ability.extra.chips}}, 
            colour = G.C.CHIPS,
            chips = card.ability.extra.chips,
            card = card
          }
      end
    end
    return level_evo(self, card, context, "j_poke_weepinbell")
end

local poke_weepinbell = SMODS.Centers['j_poke_weepinbell'] or {}
poke_weepinbell.calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play and not context.other_card.debuff then
      if unstb_global.modulo_check(context.other_card, 2, 0) then
          return {
            message = localize{type = 'variable', key = 'a_chips', vars = {card.ability.extra.chips}}, 
            colour = G.C.CHIPS,
            chips = card.ability.extra.chips,
            card = card
          }
      end
    end
    return item_evo(self, card, context, "j_poke_victreebel")
end

local poke_victreebel = SMODS.Centers['j_poke_victreebel'] or {}
poke_victreebel.calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play and not context.other_card.debuff then
      if unstb_global.modulo_check(context.other_card, 2, 0) then
          return {
            message = localize{type = 'variable', key = 'a_chips', vars = {card.ability.extra.chips}}, 
            colour = G.C.CHIPS,
            chips = card.ability.extra.chips,
            card = card
          }
      end
    end
    if context.repetition and context.cardarea == G.play and not context.other_card.debuff then
		if unstb_global.modulo_check(context.other_card, 2, 0) then
		  return {
			message = localize('k_again_ex'),
			repetitions = card.ability.extra.retriggers,
			card = card
		  }
		end
    end
  end

end

--KCVanilla Compat
if check_mod_active("KCVanilla") then

print("Inject KCVanilla Joker")

--Five Days Forecast, now used get_next_x_rank properly

local function unstb_kcv_rank_up_discreetly(card)
    -- local newcard = kcv_get_rank_up_pcard(card)
    card.kcv_ignore_debuff_check = true
    card.kcv_ranked_up_discreetly = true
    -- card:set_base(newcard)

    local old_rank = SMODS.Ranks[card.base.value]
    local new_rank = get_next_x_rank(card.base.value, 1)
    card.kcv_display_rank = card.kcv_display_rank and card.kcv_display_rank or old_rank

    SMODS.change_base(card, card.base.suit, new_rank) -- Should respect "kcv_ranked_up_discreetly" as it uses card:set_base
end

local kc_5day = SMODS.Centers['j_kcvanilla_5day'] or {}
kc_5day.calculate = function(self, card, context)
	if context.kcv_forecast_event and context.scoring_hand then
		if next(context.poker_hands["Straight"]) then
			for i, other_c in ipairs(context.scoring_hand) do
				if not top_rank_blacklist[other_c.base.value] then
					unstb_kcv_rank_up_discreetly(other_c)
				end
			end
		end
	end
	if context.before and context.scoring_hand then
		if next(context.poker_hands["Straight"]) then
			local targets = {}
			for i, other_c in ipairs(context.scoring_hand) do
				if other_c.kcv_ranked_up_discreetly then
					table.insert(targets, other_c)
				end
			end

			card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {
				message = localize('k_active_ex'),
				colour = G.C.FILTER,
				card = context.blueprint_card or card
			});

			for i_2, other_c_2 in ipairs(targets) do
				local percent = 1.15 - (i_2 - 0.999) / (#context.scoring_hand - 0.998) * 0.3
				G.E_MANAGER:add_event(Event({
					func = function()
						if not other_c_2.kcv_ranked_up_discreetly then
							-- was complete, but another 5-day joker is targeting this card
							return true
						end
						play_sound('card1', percent)
						other_c_2:flip()
						return true
					end
				}))
				delay(0.15)
			end
			delay(0.3)
			for i_3, other_c_3 in ipairs(targets) do
				local percent = 0.85 + (i_3 - 0.999) / (#context.scoring_hand - 0.998) * 0.3
				G.E_MANAGER:add_event(Event({
					func = function()
						if not other_c_3.kcv_ranked_up_discreetly then
							-- was complete, but another 5-day joker is targeting this card
							return true
						end
						-- kcv_log(other_c_3.base.id .. ' - ' .. other_c_3.kcv_display_rank)
						other_c_3.kcv_display_rank = SMODS.Ranks[get_next_x_rank(other_c_3.kcv_display_rank.key, 1)]

						-- Copying method SMODs uses
						local card_suit = SMODS.Suits[other_c_3.base.suit].card_key
						local card_rank = other_c_3.kcv_display_rank.card_key
						local newcard = G.P_CARDS[('%s_%s'):format(card_suit, card_rank)]
						
						-- set_base again to update sprites that were postponed by kcv_ranked_up_discreetly
						other_c_3:set_sprites(nil, newcard)
						play_sound('tarot2', percent, 0.6)
						other_c_3:flip()
						if other_c_3.kcv_display_rank.card_key == SMODS.Ranks[other_c_3.base.value].card_key then
							-- cleanup
							other_c_3.kcv_ranked_up_discreetly = nil
							other_c_3.kcv_ignore_debuff_check = nil
							other_c_3.kcv_display_rank = nil
						end
						return true
					end
				}))
				delay(0.15)
			end
			delay(0.5)
		end
	end
end

end

--DnDJ Compat
if check_mod_active("DnDJ") then

--TO DO: Make it a toggle setting if the card from DnDJ contraband pack would keep its rank graphic or not
local dndj_keep_sprite = unstbex.config.dndj.keep_sprite

local dndj_rank_map = {['dndj_0'] = 'unstb_0',
					['dndj_0.5'] = 'unstb_0.5',
					['dndj_1'] = 'unstb_1',
					['dndj_Pi'] = 'unstb_Pi',
					['dndj_11'] = 'unstb_11',
					['dndj_12'] = 'unstb_12',
					['dndj_13'] = 'unstb_13',
					['dndj_21'] = 'unstb_21'}

for k, v in pairs(dndj_rank_map) do
	register_rank_replacement(k, v, dndj_keep_sprite)
end

end

--Showdown compat
if check_mod_active("Showdown") then

unstb_global.register_face_rank({'showdown_Butler', 'showdown_Princess', 'showdown_Lord'})

local enable_unstable_decimal = unstbex.config.showdown.use_decimal
local replace_zero = unstbex.config.showdown.replace_zero

if replace_zero then
	register_rank_replacement('showdown_Zero', 'unstb_0')
end

--Adds "decimal" compat to all counterpart ranks
local rank_sh_two_half = SMODS.Ranks['showdown_2.5']
rank_sh_two_half.decimal_compat = true

local rank_sh_five_half = SMODS.Ranks['showdown_5.5']
rank_sh_five_half.decimal_compat = true

local rank_sh_eight_half = SMODS.Ranks['showdown_8.5']
rank_sh_eight_half.decimal_compat = true

local rank_sh_butler = SMODS.Ranks['showdown_Butler']
rank_sh_butler.decimal_compat = true

local rank_sh_princess = SMODS.Ranks['showdown_Princess']
rank_sh_princess.decimal_compat = true

local rank_sh_lord = SMODS.Ranks['showdown_Lord']
rank_sh_lord.decimal_compat = true

--Additional information so UnStable's Engineer can work with them
unstb_global.register_decimal_rank_map('showdown_2.5', '3')
unstb_global.register_decimal_rank_map('showdown_5.5', '6')
unstb_global.register_decimal_rank_map('showdown_8.5', '9')
unstb_global.register_decimal_rank_map('showdown_Butler', 'Queen')
unstb_global.register_decimal_rank_map('showdown_Princess', 'King')
unstb_global.register_decimal_rank_map('showdown_Lord', 'Ace')

--If the setting is enabled, add proper UnStable decimal rank mechanics onto the ranks
if enable_unstable_decimal then

--Hook into get_counterpart to erase the UI display for them
local ref_getCounterPart = get_counterpart
function get_counterpart(rank, onlyCounterpart)

	--onlyCounterpart is used for UI
	if onlyCounterpart then
		return nil
	end

	return ref_getCounterPart(rank, onlyCounterpart)
end

local max_rank_id_number = -1

for _, v in pairs(SMODS.Ranks) do
	if v.id > 0 and v.id > max_rank_id_number then
		max_rank_id_number = v.id
	end
end

rank_sh_two_half.is_decimal = true
rank_sh_two_half.rank_act = {'2', '2.5', '3'}
rank_sh_two_half.next = { 'unstb_e', '3', 'unstb_Pi', '4' }
rank_sh_two_half.prev = { '2' }
rank_sh_two_half.strength_effect = {
            fixed = 2,
            random = false,
            ignore = false
        }
rank_sh_two_half.id = max_rank_id_number + 1
		
rank_sh_five_half.is_decimal = true
rank_sh_five_half.rank_act = {'5', '5.5', '6'}
rank_sh_five_half.next = { '6', '7'}
rank_sh_five_half.prev = { '5' }
rank_sh_five_half.id = max_rank_id_number + 2

rank_sh_eight_half.is_decimal = true
rank_sh_eight_half.rank_act = {'8', '8.5', '9'}
rank_sh_eight_half.next = { '9', '10'}
rank_sh_eight_half.prev = { '8' }
rank_sh_eight_half.id = max_rank_id_number + 3

rank_sh_butler.is_decimal = true
rank_sh_butler.rank_act = {'Jack', 'Butler', 'Queen'}
rank_sh_butler.next = {'Queen', 'showdown_Princess', 'King'}
rank_sh_butler.prev = { 'Jack' }
rank_sh_butler.id = max_rank_id_number + 4

rank_sh_princess.is_decimal = true
rank_sh_princess.rank_act = {'Queen', 'Princess', 'King'}
rank_sh_princess.next = {'King', 'showdown_Lord', 'Ace'}
rank_sh_princess.prev = { 'Queen' }
rank_sh_princess.id = max_rank_id_number + 5

rank_sh_lord.is_decimal = true
rank_sh_lord.rank_act = {'King', 'Lord'}
rank_sh_lord.next = {'Ace'}
rank_sh_lord.prev = { 'King' }
rank_sh_lord.id = max_rank_id_number + 6

--Jank, mostly bc Showdown's rank id is forced to be negative for the counterparts, thus ended up mess with the total rank ID orders
SMODS.Rank.max_id.value = rank_sh_lord.id

--Changes to existing ranks to allow Straight in numerical order
SMODS.Ranks['2'].strength_effect = {
            fixed = 3,
            random = false,
            ignore = false
        }
SMODS.Ranks['2'].next = {'showdown_2.5', 'unstb_e', '3', 'unstb_Pi'}

SMODS.Ranks['5'].strength_effect = {
            fixed = 2,
            random = false,
            ignore = false
        }
SMODS.Ranks['5'].next = {'showdown_5.5', '6'}

SMODS.Ranks['8'].strength_effect = {
            fixed = 2,
            random = false,
            ignore = false
        }
SMODS.Ranks['8'].next = {'showdown_8.5', '9'}

SMODS.Ranks['10'].next = {'Jack', 'showdown_Butler', 'unstb_11'}

SMODS.Ranks['Jack'].strength_effect = {
            fixed = 2,
            random = false,
            ignore = false
        }
SMODS.Ranks['Jack'].next = {'showdown_Butler', 'Queen', 'showdown_Princess'}

SMODS.Ranks['Queen'].strength_effect = {
            fixed = 2,
            random = false,
            ignore = false
        }
SMODS.Ranks['Queen'].next = {'showdown_Princess', 'King', 'showdown_Lord'}

SMODS.Ranks['King'].strength_effect = {
            fixed = 2,
            random = false,
            ignore = false
        }
SMODS.Ranks['King'].next = {'showdown_Lord', 'Ace'}

end

end

--Hook for the game's splash screen, to initialize any data that is sensitive to the mod's order (mainly rank stuff)

local ref_gamesplashscreen = Game.splash_screen

function Game:splash_screen()
 	ref_gamesplashscreen(self)
	
	--Cryptid stuff has to be done on Splash Screen because of its high priority
	if check_mod_active("Cryptid") then
		print("Inject new nominal code override for Cryptid")
		
		--Make a dedicated table of rank id and the nominal order
		--This is because Cryptid randomize nominal chips in Misprint Deck and Glitched Edition
		
		local rank_nominal_order = {}
		
		for key, rank in pairs(SMODS.Ranks) do
			rank_nominal_order[key] = rank.nominal
		end
		
		--Basically the same code from the basegame, but swap nominal out with the new rank_nominal_order property
		function Card:get_nominal(mod)
			local mult = 1
			local rank_mult = 1
			if mod == 'suit' then mult = 30000 end
			if self.ability.effect == 'Stone Card' or (self.config.center.no_suit and self.config.center.no_rank) then 
				mult = -10000
			elseif self.config.center.no_suit then
				mult = 0
			elseif self.config.center.no_rank then
				rank_mult = 0
			end
			--Temporary fix so the card with the lowest nominal can still be sorted properly
			local nominal = rank_nominal_order[self.base.value] or 0
			
			if self.base.value == 'unstb_???' then
				nominal = 0.3
			elseif nominal < 0.4 then
				nominal = 0.31 + nominal*0.1
			end
			
			--Hardcode this so it's sorted properly
			if self.base.value == 'unstb_161' then
				nominal = 30
			end
			
			return 10*(nominal)*rank_mult + self.base.suit_nominal*mult + (self.base.suit_nominal_original or 0)*0.0001*mult + 10*self.base.face_nominal*rank_mult + 0.000001*self.unique_val
		end
		
		--Secret interaction: The "Jolly Joker" (UnStable Joker) counts as Jolly as well
		local ref_card_is_jolly = Card.is_jolly
		function Card:is_jolly()
			if self.config.center.key == 'j_unstb_the_jolly_joker' then
				return true
			end
			
			return ref_card_is_jolly(self)
		end
		
		--Inject Blinds effect
		
		print("Inject Blind effects for Cryptid")
		
		local blind_hammer = SMODS.Blinds['bl_cry_hammer'] or {}
		
		blind_hammer.recalc_debuff = function(self, card, from_blind)
			if card.area ~= G.jokers and not G.GAME.blind.disabled then
				if
					card.ability.effect ~= "Stone Card"
					and (
						card.base.value == "3"
						or card.base.value == "5"
						or card.base.value == "7"
						or card.base.value == "9"
						or card.base.value == "Ace"
						or card.base.value == "unstb_1"
						or card.base.value == "unstb_21"
						
						or card.base.value == "unstb_11"
						or card.base.value == "unstb_13"
						or card.base.value == "unstb_25"
						or card.base.value == "unstb_161"
						
						or card.base.value == "unstb_???"
					)
				then
					return true
				end
				return false
			end
		end
		
		local blind_magic = SMODS.Blinds['bl_cry_magic'] or {}
		
		blind_magic.recalc_debuff = function(self, card, from_blind)
			if card.area ~= G.jokers and not G.GAME.blind.disabled then
				if
					card.ability.effect ~= "Stone Card"
					and (
						card.base.value == "2"
						or card.base.value == "4"
						or card.base.value == "6"
						or card.base.value == "8"
						or card.base.value == "10"
						or card.base.value == "unstb_0"
						or card.base.value == "unstb_12"
						or card.base.value == "unstb_???"
						
						or card.base.value == "showdown_Zero"
					)
				then
					return true
				end
				return false
			end
		end
	
		--Override ://VARIABLE Code card's code
		--Because the original code has problem with the card with modded rank
		--Also, switch over to SMODS.change_base instead of manually building card key,
		--which was the cause of the problem
		
		unstbex_global.cryptid_variable_rank = {'', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace', '', '', '', 'unstb_0', 'unstb_21', 'unstb_0.5', 'unstb_r2', 'unstb_e', 'unstb_Pi', 'unstb_1', 'unstb_11', 'unstb_12', 'unstb_13', 'unstb_25', 'unstb_161', 'unstb_???'}
		
		G.FUNCS.variable_apply = function()
			local rank_table = {
				{},
				{ "2", "Two", "II" },
				{ "3", "Three", "III" },
				{ "4", "Four", "IV" },
				{ "5", "Five", "V" },
				{ "6", "Six", "VI" },
				{ "7", "Seven", "VII" },
				{ "8", "Eight", "VIII" },
				{ "9", "Nine", "IX" },
				{ "10", "1O", "Ten", "X", "T" },
				{ "J", "Jack" },
				{ "Q", "Queen" },
				{ "K", "King" },
				{ "A", "Ace"}, --Notably, 1 is now 1 and not Ace :P
				{ "M" },
				{ "nil" },
				{}, --Not sure if I should left it blank but its used for a cheat check below??
				
				--UNSTB Rank
				{"0", "O", "Zero"},
				{"21", "Twenty-One", "TwentyOne", "XXI", "BJ"},
				{"0.5", "O.5", "Half"},
				{"1.4", "1.41", "Root2", "Sqrt2", "Root", "Sqrt", "r", "sq"},
				{"2.7", "2.71","e", "Euler"},
				{"3.1", "3.14", "22/7", "Pi", "P"},
				{"1", "One", "I"},
				
				{"11", "Eleven", "XI"},
				{"12", "Twelve", "XII"},
				{"13", "Thirteen", "XIII"},
				
				{"25", "Twenty-Five", "TwentyFive", "XXV", "quad"},
				
				{"161", "OneHundredSixtyOne", "OneSixOne", "CLXI", "abomination"},
				
				{"?", "???", "Question", "idk"},
			}

			local rank_suffix = nil

			for i, v in pairs(rank_table) do
				for j, k in pairs(v) do
					if string.lower(G.ENTERED_RANK) == string.lower(k) then
						rank_suffix = i
					end
				end
			end

			if rank_suffix then
				G.PREVIOUS_ENTERED_RANK = G.ENTERED_RANK
				G.GAME.USING_CODE = false
				if rank_suffix == 15 then
					check_for_unlock({ type = "cheat_used" })
					local card = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_jolly")
					card:add_to_deck()
					G.jokers:emplace(card)
				elseif rank_suffix == 16 then
					check_for_unlock({ type = "cheat_used" })
					local card = create_card("Code", G.consumeables, nil, nil, nil, nil, "c_cry_crash")
					card:add_to_deck()
					G.consumeables:emplace(card)
				elseif rank_suffix == 17 then
					check_for_unlock({ type = "cheat_used" })
					G.E_MANAGER:add_event(Event({
						trigger = "after",
						delay = 0.4,
						func = function()
							play_sound("tarot1")
							return true
						end,
					}))
					for i = 1, #G.hand.highlighted do
						local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
						G.E_MANAGER:add_event(Event({
							trigger = "after",
							delay = 0.15,
							func = function()
								G.hand.highlighted[i]:flip()
								play_sound("card1", percent)
								G.hand.highlighted[i]:juice_up(0.3, 0.3)
								return true
							end,
						}))
					end
					delay(0.2)
					for i = 1, #G.hand.highlighted do
						local CARD = G.hand.highlighted[i]
						local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
						G.E_MANAGER:add_event(Event({
							trigger = "after",
							delay = 0.15,
							func = function()
								CARD:flip()
								CARD:set_ability(
									G.P_CENTERS[pseudorandom_element(G.P_CENTER_POOLS.Consumeables, pseudoseed("cry_variable")).key],
									true,
									nil
								)
								play_sound("tarot2", percent)
								CARD:juice_up(0.3, 0.3)
								return true
							end,
						}))
					end
				else
					G.E_MANAGER:add_event(Event({
						trigger = "after",
						delay = 0.4,
						func = function()
							play_sound("tarot1")
							return true
						end,
					}))
					for i = 1, #G.hand.highlighted do
						local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
						G.E_MANAGER:add_event(Event({
							trigger = "after",
							delay = 0.15,
							func = function()
								G.hand.highlighted[i]:flip()
								play_sound("card1", percent)
								G.hand.highlighted[i]:juice_up(0.3, 0.3)
								return true
							end,
						}))
					end
					delay(0.2)
					for i = 1, #G.hand.highlighted do
						G.E_MANAGER:add_event(Event({
							trigger = "after",
							delay = 0.1,
							func = function()
								local card = G.hand.highlighted[i]								
								local new_rank = unstbex_global.cryptid_variable_rank[rank_suffix]
								
								--Fallback
								if not new_rank or new_rank == '' then
									new_rank = 'unstb_???'
								end
								
								SMODS.change_base(card, nil, new_rank)
								return true
							end,
						}))
					end
					for i = 1, #G.hand.highlighted do
						local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
						G.E_MANAGER:add_event(Event({
							trigger = "after",
							delay = 0.15,
							func = function()
								G.hand.highlighted[i]:flip()
								play_sound("tarot2", percent, 0.6)
								G.hand.highlighted[i]:juice_up(0.3, 0.3)
								return true
							end,
						}))
					end
					G.E_MANAGER:add_event(Event({
						trigger = "after",
						delay = 0.2,
						func = function()
							G.hand:unhighlight_all()
							return true
						end,
					}))
					delay(0.5)
				end
				G.CHOOSE_RANK:remove()
			end
		end
	
	end
end