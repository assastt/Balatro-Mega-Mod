return {
    descriptions = {
        Joker = {
            j_betm_jokers_jjookkeerr = {
                name = "JJookkeerr",
                text = {
                    "Jokers with \"Joker\"",
                    "in their name",
                    "each give {X:mult,C:white} X#1# {} Mult",
                }
            },
            j_betm_jokers_ascension = {
                name = "Ascension",
                text = {
                    "Played poker hand counts",
                    "as next higher poker hand",
                    "(ex. High Card counts as One Pair)",
                }
            },
            j_betm_jokers_hasty = {
                name = "Hasty Joker",
                text = {
                    "Earn {C:money}$#1#{} if round",
                    "ends after first hand",
                }
            },
            j_betm_jokers_errorr = {
                name = "ERRORR",
                text = {
                    "Discarded cards have a",
                    "{C:green}#1# in #2#{} chance to",
                    "become random rank"
                }
            },
            j_betm_jokers_piggy_bank = {
                name = " Piggy Bank ", -- space is intentional to prevent same name with other mod jokers
                text = {
                    "Put half of earned money",
                    "into this Joker",
                    "{C:red}+#2#{} Mult for",
                    "each {C:money}$1{} inside",
                    "{C:inactive}(Currently {C:red}+#1#{C:inactive} Mult)"
                }
            },
            j_betm_jokers_housing_choice = {
                name = "Housing Choice",
                text = {
                    "Once per Ante, get a random",
                    "{C:attention}Voucher{} if played hand",
                    "contains a {C:attention}Full House{}",
                    "{C:inactive}(#1#)"
                }
            },
            j_betm_jokers_jimbow = {
                name = "Jimbow",
                text = {
                    "This Joker gains {C:chips}+#2#{}",
                    "Chips {C:attention}#3#{},",
                    "context changes when achieved",
                    "{C:inactive}(Currently {C:chips}#1#{C:inactive} Chips)",
                    
                }
            },
            j_betm_jokers_gameplay_update = {
                name = "Gameplay Update",
                text = {
                    "If played hand has exactly",
                    "{C:attention}2 Diamonds{}, {C:attention}0 Spades{},",
                    "{C:attention}2 Hearts{} or {C:attention}5 Clubs{},",
                    "increase value of joker to its right",
                    "by {C:attention}#1#% for each condition satisfied",
                }
            },
            j_betm_jokers_flying_cards = {
                name = "Flying Cards",
                text = {
                    "This Joker gains {X:mult,C:white} X(n+#2#)^-#1# {} Mult",
                    "per {C:attention}card{} scored or discarded, where",
                    "{C:attention}n{} equals number of cards left in deck",
                    "{C:inactive}(Currently {X:mult,C:white} X#3# {C:inactive} Mult)",
                }
            },
            j_betm_jokers_friends_of_jimbo = {
                name = "Friends of Jimbo",
                text = {
                    "For each {C:spades}King of Spades{}, {C:diamonds}Queen of Diamonds{},",
                    "{C:hearts}Jack of Hearts{} or {C:clubs}King of Clubs{} scored,",
                    "generate a {C:attention}Jimbo{}",
                    "{C:inactive}(No need to have room)",
                }
            },
            j_betm_jokers_balatro_mobile = {
                name = "Balatro Mobile",
                text = {
                    "This Joker is {C:attention}mobile{} and can be put anywhere.",
                    "#2#",
                    "#3#",
                    "{C:inactive}(Drag it around to see its effects)",
                }
            },
        }
    }
}