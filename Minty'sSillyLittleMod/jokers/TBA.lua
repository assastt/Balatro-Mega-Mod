SMODS.Joker {
    key = "TBA",
    name = "TBA",
    atlas = 'mintyjokerplaceholder',
    pos = {
        x = 0,
        y = 0
    },
    soul_pos = {
        x = 1,
        y = 0
    },
    rarity = 4,
    cost = 20,
    unlocked = false,
    discovered = false,
    eternal_compat = true,
    perishable_compat = false,
    blueprint_compat = true,
    pools = {["kity"] = true},
    config = {
        extra = {
            xmult = 1,
            xmultgain = 1,
            found = false
        }
    },
    loc_vars = function(self, info_queue, card)
        local key = self.key
        if minty_config.flavor_text then
            key = self.key.."_flavor"
        end
        return {
            key = key,
            vars = {
                card.ability.extra.xmult,
                card.ability.extra.xmultgain,
            }
        }
    end,
    calculate = function(self, card, context)
        -- Calculation goes here
        if context.cardarea == G.play and context.individual then
            sendDebugMessage("[Minty] Observing card")
            if context.other_card:is_3() then
                sendDebugMessage("[Minty] 3 detected!")
                card.ability.extra.found = true
            end
        end

        if context.joker_main and context.scoring_hand then
            sendDebugMessage("[Minty] xMult time :3")
            return {
                    xmult = card.ability.extra.xmult
            }
        end

        if context.destroy_card and card.ability.extra.found == true then
            sendDebugMessage("[Minty] Attempting to destroy card")
            local scored = false
			for k, v in ipairs(context.scoring_hand) do
                if v == context.destroying_card then 
                    scored = true
                end
			end
            if scored or (context.destroying_card.ability.eternal)
            then 
                sendDebugMessage("[Minty] Card was scored, no destruaction")
                return false 
            end
            sendDebugMessage("[Minty] Card was not scored, destruaction time >:3")
            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmultgain
            return {
                remove = true,
                message = localize('k_nommed_ex'),
                card = card,
                extra = {
                    delay = 0,
                    colour = G.C.RED,
                    message = localize {
                        type = 'variable',
                        key = 'x_mult',
                        vars = { card.ability.extra.xmultgain },
                    },
                    message_card = card 
                }
            }
        end

        if context.after then
            sendDebugMessage("[Minty] 3 forgotten")
            card.ability.extra.found = false
        end

    end
}

--[[
["j_minty_TBA"] = {
    ["unlock"] = {
        "Find this Joker",
        "from the {C:spectral}Soul{} card",
    },
    ["name"] = "TBA",
    ["text"] = {
        "If {C:attention}scored hand{} contains any",
        "{C:minty_3s}3s{}, {C:attention}destroy{} all {C:attention}unscored{}",
        "cards and gain {X:mult,C:white}X#2#{} Mult",
        "for each destroyed card",
        "{C:inactive}Currently {X:mult,C:white}X#1#{}"
    },
},
["j_minty_TBA_flavor"] = {
    ["unlock"] = {
        "Find this Joker",
        "from the {C:spectral}Soul{} card",
    },
    ["name"] = "TBA",
    ["text"] = {
        "If {C:attention}scored hand{} contains any",
        "{C:minty_3s}3s{}, {C:attention}destroy{} all {C:attention}unscored{}",
        "cards and gain {X:mult,C:white}X#2#{} Mult",
        "for each destroyed card",
        "{C:inactive}Currently {X:mult,C:white}X#1#{}",
        " ",
        "{C:inactive,s:0.8}"
    },
},
]]