SpectrumAPI = SMODS.current_mod
SMODS.Atlas {key = "modicon",path = "icon.png",px = 34,py = 34,}:register()

-- Additionally loc_key can be provided to override the name the hand displays as
SpectrumAPI.configuration = {
    hand_values = {
        spa_Spectrum = {c=45, m=5, l_c=20,l_m=3},
        spa_Straight_Spectrum = {c=115, m=9, l_c=50,l_m=5},
        spa_Spectrum_House = {c=150, m=15, l_c=50,l_m=5},
        spa_Spectrum_Five = {c=170, m=18, l_c=65,l_m=4},
        -- Optional Hand Types
        spa_Flush_Spectrum = {c=115, m=9, l_c=50,l_m=5},
        spa_Straight_Flush_Spectrum = {c=150, m=15, l_c=50,l_m=5},
        spa_Flush_Spectrum_House = {c=170, m=18, l_c=50,l_m=5},
        spa_Flush_Spectrum_Five = {c=200, m=20, l_c=70,l_m=6},
    },
    misc = {
        four_fingers_spectrums = false,
        spectrums_visible = false,
        spectrum_example_suit = "m_wild",
        royal_spectrums = true,
        specflush_over_spectrum_flush = false
    },
    -- Hand types like Specflush which *require* wild cards will be here
    -- Every other Hand Type will be standard
    hand_types = {
        spa_Flush_Spectrum = false,
        spa_Straight_Flush_Spectrum = false,
        spa_Flush_Spectrum_House = false,
        spa_Flush_Spectrum_Five = false,
    }
}

-- Card Tables should be passed here from helper functions in the place of SMODS.Joker or SMODS.Planet
-- Card Tables may have an object_type in the center definition which is needed for the other table but is otherwise auto-generated
-- An example of this would be object_type = "Joker" or object_type = "Planet" which matches the SMODS.X{} functions
SpectrumAPI.content = {
    mult_handtype_jokers = {

    },
    chips_handtype_jokers = {

    },
    xmult_handtype_jokers = {

    },
    planets = {
    },
    other = {
        -- Tables here should have specific keys to represent content
        -- For example if more than 1 mod wanted to add Cryptid Suit planets for spectrum
        --[[
        ["suit_planets"] = {
            -- Your Card Table Here
        }
        ]]
    }
}

function SpectrumAPI.add_content(table, ctype, id_override)
    table.loaded_by = table.loaded_by or SMODS.Mods[id_override or "Nuh Uh"] or SMODS.current_mod or {}
    if type(ctype) == "table" then
        table.object_type = "Planet"
        SpectrumAPI.content["planets"][ctype.hand] = SpectrumAPI.content["planets"][ctype.hand] or {}
        SpectrumAPI.content["planets"][ctype.hand][#SpectrumAPI.content["planets"][ctype.hand]+1] = table
    else
        table.object_type = table.object_type or "Joker"
        if SpectrumAPI.content[ctype] then
            SpectrumAPI.content[ctype][#SpectrumAPI.content[ctype]+1] = table
        else
            SpectrumAPI.content["other"][ctype] = SpectrumAPI.content["other"][ctype] or {}
            SpectrumAPI.content["other"][ctype][#SpectrumAPI.content["other"][ctype]+1] = table
        end
    end
end

local loadmodsref = SMODS.injectItems
function SMODS.injectItems(...)
    SpectrumAPI.load_content()
    loadmodsref(...)
    SpectrumAPI.post_load()
end

SMODS.PokerHandPart({
	key = "spectrum_part",
	func = function(hand)
		local eligible_cards = {}
        local suits = {}
        local num_suits = 0
		for i, card in ipairs(hand) do
			if not suits[SpectrumAPI.get_suit(card)] and not SMODS.has_no_suit(card) then --card.ability.name ~= "Gold Card"
                suits[SpectrumAPI.get_suit(card)] = true
                num_suits = num_suits + 1
			end
            eligible_cards[#eligible_cards + 1] = card
		end
        local num = 5
        if SpectrumAPI.configuration.misc.four_fingers_spectrums then
            num = SMODS.four_fingers() or 5
        end
		if num_suits >= num then
			return { eligible_cards }
		end
		return {}
	end,
})

function SpectrumAPI.get_suit(card)
    if card.config.center.specific_suit then
        return card.config.center.specific_suit
    end
    if card:is_suit("not a suit") or card.config.center.effect == "Wild Card" then
        -- Returning a random number here makes them always count for spectrums
        -- They will also always score in spectrums
        return math.random(1, 1000000)
    end
    return card.base.suit
end

function SpectrumAPI.load_content()
    local suit = SpectrumAPI.configuration.misc.spectrum_example_suit
    SMODS.PokerHand{
        key = "spa_Spectrum",
        visible = SpectrumAPI.configuration.misc.spectrums_visible,
        l_chips = SpectrumAPI.configuration.hand_values.spa_Spectrum.l_c,
        l_mult = SpectrumAPI.configuration.hand_values.spa_Spectrum.l_m,
        chips = SpectrumAPI.configuration.hand_values.spa_Spectrum.c,
        mult = SpectrumAPI.configuration.hand_values.spa_Spectrum.m,
        example = {
            { "S_A", true },
            { "C_T", true },
            { "D_7", true },
            { "H_5", true },
            { (suit ~= "m_wild" and suit or "S").."_3", true, enhancement = suit == "m_wild" and suit or nil},
        },
        evaluate = function(parts, hand)
            if next(parts.spa_spectrum_part) then
                return { SMODS.merge_lists(parts.spa_spectrum_part) }
            end
            return {}
        end
    }

    SMODS.PokerHand{
        key = "spa_Straight_Spectrum",
        visible = SpectrumAPI.configuration.misc.spectrums_visible,
        l_chips = SpectrumAPI.configuration.hand_values.spa_Straight_Spectrum.l_c,
        l_mult = SpectrumAPI.configuration.hand_values.spa_Straight_Spectrum.l_m,
        chips = SpectrumAPI.configuration.hand_values.spa_Straight_Spectrum.c,
        mult = SpectrumAPI.configuration.hand_values.spa_Straight_Spectrum.m,
        example = {
            { "S_J", true },
            { "C_T", true },
            { "D_9", true },
            { "H_8", true },
            { (suit ~= "m_wild" and suit or "S").."_7", true, enhancement = suit == "m_wild" and suit or nil},
        },
        evaluate = function(parts, hand)
            if next(parts.spa_spectrum_part) and next(parts._straight) then
                return { SMODS.merge_lists(parts.spa_spectrum_part, parts._straight) }
            end
            return {}
        end,
        modify_display_text = function(self, cards, scoring_hand) 
            if not SpectrumAPI.configuration.misc.royal_spectrums then return end
            local royal = true
            for j = 1, #scoring_hand do
                local rank = SMODS.Ranks[scoring_hand[j].base.value]
                royal = royal and (rank.key == 'Ace' or rank.key == '10' or rank.face)
            end
            if royal then
                return "spa_Royal_Spectrum"
            end
        end
    }


    SMODS.PokerHand{
        key = "spa_Spectrum_House",
        visible = SpectrumAPI.configuration.misc.spectrums_visible,
        l_chips = SpectrumAPI.configuration.hand_values.spa_Spectrum_House.l_c,
        l_mult = SpectrumAPI.configuration.hand_values.spa_Spectrum_House.l_m,
        chips = SpectrumAPI.configuration.hand_values.spa_Spectrum_House.c,
        mult = SpectrumAPI.configuration.hand_values.spa_Spectrum_House.m,
        example = {
            { "S_K", true },
            { "C_K", true },
            { "D_K", true },
            { "H_2", true },
            { (suit ~= "m_wild" and suit or "S").."_2", true, enhancement = suit == "m_wild" and suit or nil},
        },
        evaluate = function(parts, hand)
            if #parts._3 < 1 or #parts._2 < 2 then return {} end
            if next(parts.spa_spectrum_part) then
                return { SMODS.merge_lists(parts.spa_spectrum_part, parts._all_pairs) }
            end
            return {}
        end
    }

    SMODS.PokerHand{
        key = "spa_Spectrum_Five",
        visible = SpectrumAPI.configuration.misc.spectrums_visible,
        l_chips = SpectrumAPI.configuration.hand_values.spa_Spectrum_Five.l_c,
        l_mult = SpectrumAPI.configuration.hand_values.spa_Spectrum_Five.l_m,
        chips = SpectrumAPI.configuration.hand_values.spa_Spectrum_Five.c,
        mult = SpectrumAPI.configuration.hand_values.spa_Spectrum_Five.m,
        example = {
            { "S_A", true },
            { "C_A", true },
            { "D_A", true },
            { "H_A", true },
            { (suit ~= "m_wild" and suit or "S").."_A", true, enhancement = suit == "m_wild" and suit or nil},
        },
        evaluate = function(parts, hand)
            if next(parts.spa_spectrum_part) and next(parts._5) then
                return { SMODS.merge_lists(parts.spa_spectrum_part, parts._5) }
            end
            return {}
        end
    }

    -- Optional hand types will be kept around to prevent crashes even if they never show up when disabled
    SMODS.PokerHand{
        key = "spa_Flush_Spectrum",
        visible = SpectrumAPI.configuration.misc.spectrums_visible,
        l_chips = SpectrumAPI.configuration.hand_values.spa_Flush_Spectrum.l_c,
        l_mult = SpectrumAPI.configuration.hand_values.spa_Flush_Spectrum.l_m,
        chips = SpectrumAPI.configuration.hand_values.spa_Flush_Spectrum.c,
        mult = SpectrumAPI.configuration.hand_values.spa_Flush_Spectrum.m,
        example = {
            { "S_A", true },
            { "S_T", true, enhancement = "m_wild"},
            { "S_7", true, enhancement = "m_wild"},
            { "S_5", true, enhancement = "m_wild"},
            { "S_3", true, enhancement = "m_wild"},
        },
        evaluate = function(parts, hand)
            if not SpectrumAPI.configuration.hand_types.spa_Flush_Spectrum then return end
            if next(parts.spa_spectrum_part) and next(parts._flush) then
                return { SMODS.merge_lists(parts.spa_spectrum_part, parts._flush) }
            end
            return {}
        end
    }

    SMODS.PokerHand{
        key = "spa_Straight_Flush_Spectrum",
        visible = SpectrumAPI.configuration.misc.spectrums_visible,
        l_chips = SpectrumAPI.configuration.hand_values.spa_Straight_Flush_Spectrum.l_c,
        l_mult = SpectrumAPI.configuration.hand_values.spa_Straight_Flush_Spectrum.l_m,
        chips = SpectrumAPI.configuration.hand_values.spa_Straight_Flush_Spectrum.c,
        mult = SpectrumAPI.configuration.hand_values.spa_Straight_Flush_Spectrum.m,
        example = {
            { "S_J", true },
            { "S_T", true, enhancement = "m_wild"},
            { "S_9", true, enhancement = "m_wild"},
            { "S_8", true, enhancement = "m_wild"},
            { "S_7", true, enhancement = "m_wild"},
        },
        evaluate = function(parts, hand)
            if not SpectrumAPI.configuration.hand_types.spa_Straight_Flush_Spectrum then return end
            if next(parts.spa_spectrum_part) and next(parts._flush) and next(parts._straight) then
                return { SMODS.merge_lists(parts.spa_spectrum_part, parts._flush, parts._straight) }
            end
            return {}
        end,
        modify_display_text = function(self, cards, scoring_hand) 
            if not SpectrumAPI.configuration.misc.royal_spectrums then return end
            local royal = true
            for j = 1, #scoring_hand do
                local rank = SMODS.Ranks[scoring_hand[j].base.value]
                royal = royal and (rank.key == 'Ace' or rank.key == '10' or rank.face)
            end
            if royal then
                return "spa_Royal_Flush_Spectrum"
            end
        end
    }


    SMODS.PokerHand{
        key = "spa_Flush_Spectrum_House",
        visible = SpectrumAPI.configuration.misc.spectrums_visible,
        l_chips = SpectrumAPI.configuration.hand_values.spa_Flush_Spectrum_House.l_c,
        l_mult = SpectrumAPI.configuration.hand_values.spa_Flush_Spectrum_House.l_m,
        chips = SpectrumAPI.configuration.hand_values.spa_Flush_Spectrum_House.c,
        mult = SpectrumAPI.configuration.hand_values.spa_Flush_Spectrum_House.m,
        example = {
            { "S_K", true },
            { "S_K", true, enhancement = "m_wild"},
            { "S_K", true, enhancement = "m_wild"},
            { "S_2", true, enhancement = "m_wild"},
            { "S_2", true, enhancement = "m_wild"},
        },
        evaluate = function(parts, hand)
            if not SpectrumAPI.configuration.hand_types.spa_Flush_Spectrum_House then return end
            if #parts._3 < 1 or #parts._2 < 2 then return {} end
            if next(parts.spa_spectrum_part) and next(parts._flush) then
                return { SMODS.merge_lists(parts.spa_spectrum_part, parts._flush, parts._all_pairs) }
            end
            return {}
        end
    }

    SMODS.PokerHand{
        key = "spa_Flush_Spectrum_Five",
        visible = SpectrumAPI.configuration.misc.spectrums_visible,
        l_chips = SpectrumAPI.configuration.hand_values.spa_Flush_Spectrum_Five.l_c,
        l_mult = SpectrumAPI.configuration.hand_values.spa_Flush_Spectrum_Five.l_m,
        chips = SpectrumAPI.configuration.hand_values.spa_Flush_Spectrum_Five.c,
        mult = SpectrumAPI.configuration.hand_values.spa_Flush_Spectrum_Five.m,
        example = {
            { "S_A", true },
            { "S_A", true, enhancement = "m_wild"},
            { "S_A", true, enhancement = "m_wild"},
            { "S_A", true, enhancement = "m_wild"},
            { "S_A", true, enhancement = "m_wild"},
        },
        evaluate = function(parts, hand)
            if not SpectrumAPI.configuration.hand_types.spa_Straight_Flush_Spectrum_Five then return end
            if next(parts.spa_spectrum_part) and next(parts._flush) and next(parts._5) then
                return { SMODS.merge_lists(parts.spa_spectrum_part, parts._flush, parts._5) }
            end
            return {}
        end
    }

    local order = {
        "mult_handtype_jokers",
        "chips_handtype_jokers",
        "xmult_handtype_jokers"
    }

    local order_j = {
        mult_handtype_jokers=true,
        chips_handtype_jokers=true,
        xmult_handtype_jokers=true
    }

    local c_mod = SMODS.current_mod
    for i, v in pairs(SpectrumAPI.content) do
        if i ~= "other" then
            local tbl = v
            table.sort(tbl, function(a, b)
                return (a.priority or 0) < (b.priority or 0)
            end)
            SpectrumAPI.content[i] = tbl
        end
    end
    for i, v in pairs(SpectrumAPI.content.other) do
        local tbl = v
        table.sort(tbl, function(a, b)
            return (a.priority or 0) < (b.priority or 0)
        end)
        SpectrumAPI.content["other"][i] = tbl
    end
    for i, v in pairs(SpectrumAPI.content.planets) do
        local tbl = v
        table.sort(tbl, function(a, b)
            return (a.priority or 0) < (b.priority or 0)
        end)
        SpectrumAPI.content["planets"][i] = tbl
    end
    for i, v in pairs(SpectrumAPI.content) do
        if i ~= "other" and i ~= "planets" then
            local top
            local max_prio = -9999
            for j, k in pairs(v) do
                if k.priority > max_prio then
                    max_prio = k.priority
                    top = k
                end
            end
            if top then
                SMODS.current_mod = top.loaded_by
                if not order_j[i] then
                    local res = SMODS[top.object_type](top)
                end
                SpectrumAPI.content[i].top = top
            end
        end
    end
    for i, v in pairs(order) do
        if SpectrumAPI.content[v] and SpectrumAPI.content[v].top then
            local top = SpectrumAPI.content[v].top
            local res = SMODS[top.object_type](top)
        end
    end
    for i, v in pairs(SpectrumAPI.content.other) do
        local top
        local max_prio = -9999
        for j, k in pairs(v) do
            if k.priority > max_prio then
                max_prio = k.priority
                top = k
            end
        end
        if top and SMODS[top.object_type] then
            SMODS.current_mod = top.loaded_by
            local res = SMODS[top.object_type](top)
            SpectrumAPI.content.other[i].top = top
        end
    end
    local planets = {
        "spa_Spectrum",
        "spa_Straight_Spectrum",
        "spa_Spectrum_House",
        "spa_Spectrum_Five"
    }
    for i, v in pairs(SpectrumAPI.content.planets) do
        local top
        local max_prio = -9999
        for j, k in pairs(v) do
            if k.priority > max_prio then
                max_prio = k.priority
                top = k
            end
        end
        if top and SMODS[top.object_type] then
            SMODS.current_mod = top.loaded_by
            --local res = SMODS[top.object_type](top)
            SpectrumAPI.content.planets[i].top = top
        end
    end
    for i, v in pairs(planets) do
        if SpectrumAPI.content.planets and SpectrumAPI.content.planets[v] and SpectrumAPI.content.planets[v].top then
            local top = SpectrumAPI.content.planets[v].top
            SMODS[top.object_type](top)
        end
    end
    SMODS.current_mod = c_mod
end

SpectrumAPI.spectrums = {
    ["bunc_Spectrum"] = "spa_Spectrum",
    ["bunc_Straight Spectrum"]="spa_Straight_Spectrum",
    ["bunc_Spectrum House"] = "spa_Spectrum_House",
    ["bunc_Spectrum Five"] = "spa_Spectrum_Five",

    ["six_Spectrum"] = "spa_Spectrum",
    ["six_Straight Spectrum"]="spa_Straight_Spectrum",
    ["six_Spectrum House"] = "spa_Spectrum_House",
    ["six_Spectrum Five"] = "spa_Spectrum_Five",

    ["paperback_Spectrum"] = "spa_Spectrum",
    ["paperback_Straight Spectrum"]="spa_Straight_Spectrum",
    ["paperback_Spectrum House"] = "spa_Spectrum_House",
    ["paperback_Spectrum Five"] = "spa_Spectrum_Five",
}

function SpectrumAPI.post_load()
    local c_mod = SMODS.current_mod
    SMODS.current_mod = SpectrumAPI
    for i, v in pairs(SpectrumAPI.spectrums) do
        SMODS.PokerHand:take_ownership(i, {
            key = "not_a_poker_hand",
            visible = false,
            l_mult = SpectrumAPI.configuration.hand_values[v].l_m,
            l_chips = SpectrumAPI.configuration.hand_values[v].l_c,
            mult = SpectrumAPI.configuration.hand_values[v].m,
            chips = SpectrumAPI.configuration.hand_values[v].c,
            evaluate = function()
                return
            end
        })
    end
    SMODS.current_mod = c_mod
    local tbl = {}
    for i, v in pairs(G.handlist) do
        if not SpectrumAPI.spectrums[v] then
            tbl[#tbl+1]=v
        end
    end
    for i, v in pairs(G.handlist) do
        if SpectrumAPI.spectrums[v] then
            tbl[#tbl+1]=v
        end
    end
    G.handlist = tbl

    local level_handref = level_up_hand
    function level_up_hand(card, hand, ...)
        if SpectrumAPI.spectrums[hand] then
            print(SpectrumAPI.spectrums[hand])
            hand = SpectrumAPI.spectrums[hand]
        end
        return level_handref(card, hand, ...)
    end

    local evaluate_poker_hand_ref = evaluate_poker_hand
    function evaluate_poker_hand(...)
        local results = evaluate_poker_hand_ref(...)
        for i, v in pairs(SpectrumAPI.spectrums) do
            if results[v] then results[i] = results[v] end
        end
        return results
    end
end

function SpectrumAPI.get_mult_joker()
    local tbl = SpectrumAPI.content.mult_handtype_jokers.top
    return tbl
end

function SpectrumAPI.get_chips_joker()
    local tbl = SpectrumAPI.content.chips_handtype_jokers.top
    return tbl
end

function SpectrumAPI.get_xmult_joker()
    local tbl = SpectrumAPI.content.xmult_handtype_jokers.top
    return tbl
end

function SpectrumAPI.get_planet()
    local tbl = SpectrumAPI.content.planets.top
    return tbl
end

function SpectrumAPI.get_other(key)
    local tbl = (SpectrumAPI.content.other[key] or {}).top
    return tbl
end

local function get_coordinates(position, width)
    if width == nil then width = 10 end -- 10 is default for Jokers
    return {x = (position) % width, y = math.floor((position) / width)}
end

if (SMODS.Mods["Bunco"] or {}).can_load then
    function SpectrumAPI.create_joker(joker)
        if joker.name == "Dynasty" or joker.name == "Lurid" or joker.name == "Zealous" then
            joker.priority = 0
            local jtype = ({
                Dynasty = "xmult_handtype_jokers",
                Lurid = "chips_handtype_jokers",
                Zealous = "mult_handtype_jokers"
            })[joker.name]
            local atlas

            if joker.type == nil then
                atlas = 'bunco_jokers'
            elseif joker.type == 'Exotic' then
                atlas = 'bunco_jokers_exotic'
            end

            if joker.rarity == 'Legendary' then
                atlas = 'bunco_jokers_legendary'
            end
            local key = string.gsub(string.lower(joker.name), '%s', '_') -- Removes spaces and uppercase letters

            -- Rarity conversion

            if joker.rarity == 'Common' then
                joker.rarity = 1
            elseif joker.rarity == 'Uncommon' then
                joker.rarity = 2
            elseif joker.rarity == 'Rare' then
                joker.rarity = 3
            elseif joker.rarity == 'Legendary' then
                joker.rarity = 4
            end

            if joker.rarity == 'Legendary' then
                joker.soul = get_coordinates(joker.position) -- Calculates coordinates based on the position variable
            end
    
            joker.position = get_coordinates(joker.position - 1)
    

            -- Config values

            if joker.vars == nil then joker.vars = {} end

            joker.config = {extra = {}}

            for _, kv_pair in ipairs(joker.vars) do
                -- kv_pair is {a = 1}
                local k, v = next(kv_pair)
                joker.config.extra[k] = v
            end

            -- Exotic Joker pool isolation

            local pool

            if joker.type == 'Exotic' then
                pool = BUNCOMOD.funcs.exotic_in_pool
            end
            joker.key = key
            joker.atlas = joker.custom_atlas or atlas
            joker.pos = joker.position
            joker.soul_pos = joker.soul
            joker.blueprint_compat = joker.blueprint
            joker.eternal_compat = joker.eternal
            joker.perishable_compat = joker.perishable
            joker.remove_from_deck = joker.remove
            joker.add_to_deck = joker.add
            joker.in_pool = joker.custom_in_pool or pool
            joker.loc_vars = joker.custom_vars or function(self, info_queue, card)

                -- Localization values
    
                local vars = {}
    
                for _, kv_pair in ipairs(joker.vars) do
                    -- kv_pair is {a = 1}
                    local k, v = next(kv_pair)
                    -- k is `a`, v is `1`
                    table.insert(vars, card.ability.extra[k])
                end
    
                return {vars = vars}
            end
            joker.config = joker.custom_config
            SpectrumAPI.add_content(joker, jtype)
            return true
        end
    end
end