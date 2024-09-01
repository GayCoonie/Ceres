--- STEAMODDED HEADER
--- MOD_NAME: Ceres
--- MOD_ID: ceres
--- MOD_PREFIX: cere
--- MOD_AUTHOR: [nekojoe]
--- MOD_DESCRIPTION: please read the read me
--- BADGE_COLOUR: 13afce
--- PRIORITY: 10
--- VERSION: 1.0.5b

----------------------------------------------
---------------- MOD CODE --------------------
local nativefs = require("nativefs")
local lovely = require("lovely")
local prefix = 'cere'

local mod_icon = SMODS.Atlas({
    key = "modicon",
    path = "cere_icon.png",
    px = 32,
    py = 32
})

Ceres = {}
Ceres.DEFAULT_CONFIG = {
    jokers = {
        rarities = {
            common = { enabled = true },
            uncommon = { enabled = true },
            rare = { enabled = true },
            legendary = { enabled = true },
            divine = { enabled = true },
        },
        enabled = true,
    },
    card_modifiers = {
        editions = { enabled = true },
        enhancements = { enabled = false },
        seals = { enabled = true },
        enabled = true
    },
    suits = { enabled = false },
    consumables = {
        reversed_tarots = { enabled = true },
        vouchers = { enabled = true },
        enabled = true,
    },
    perks = { enabled = true },
    run_modifiers = {
        blinds = { enabled = true },
        stakes = { enabled = true },
        decks = { enabled = true },
        enabled = true,
    },
    misc = {
        unlock_all = { enabled = true }, -- has to be until i get round to unlock checks
        discover_all = { enabled = false },
    }
}
Ceres.MOD_PATH = lovely.mod_dir .. '/Ceres/'
Ceres.DEV = false
Ceres.COMPAT = {
    talisman = (SMODS.Mods['Talisman'] or {}).can_load,
    cryptid = (SMODS.Mods['Cryptid'] or {}).can_load,
    cere = (SMODS.Mods['Ceres'] or {}).can_load,
}

function love.conf(t)
	t.console = true
end
if Ceres.DEV then
    _RELEASE_MODE = false
end

Ceres.FUNCS = {}

Ceres.FUNCS.load_config = function(mod)
    mod = mod or Ceres
    local folder = mod.MOD_PATH
    if nativefs.getInfo(folder .. 'config.lua') then
        local config = STR_UNPACK(nativefs.read(folder .. 'config.lua'))
        if not config then
            mod.CONFIG = Ceres.FUNCS.copy(mod.DEFAULT_CONFIG)
            Ceres.FUNCS.save_config(mod)
        else
            mod.CONFIG = Ceres.FUNCS.copy(config)
        end
    else
        mod.CONFIG = Ceres.FUNCS.copy(mod.DEFAULT_CONFIG)
        Ceres.FUNCS.save_config(mod)
    end
end

Ceres.FUNCS.save_config = function(mod)
    mod = mod or Ceres
    local folder = mod.MOD_PATH
    nativefs.write(folder .. 'config.lua', STR_PACK(mod.CONFIG))
end

Ceres.FUNCS.read_files = function(mod)
    mod = mod or Ceres
    for path_prefix, paths in pairs(mod.ITEMS) do
        if type(paths) == 'table' then
            for _, path in pairs(paths) do
                assert(load(nativefs.read(mod.MOD_PATH .. path_prefix .. '/' .. path .. '.lua')))()
            end
        else
            assert(load(nativefs.read(mod.MOD_PATH .. paths .. '.lua')))()
        end
    end
end

Ceres.FUNCS.copy = function(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[Ceres.FUNCS.copy(k, s)] = Ceres.FUNCS.copy(v, s) end
    return res
end

-- colours
Ceres.C = {
    devil = HEX('333333'),
    dark_red = HEX('B60000'),
    new_moon = HEX('2c485dcc'),
    divine = G.C.DARK_EDITION,
    eternal = G.C.ETERNAL,
    the_bill = HEX('EDCE7B'),
    the_fall = HEX('eb7a34'),
    the_french = HEX('E5E5E5'),
    cere_perk = G.C.GREEN,
    cere_defective = HEX('FF3D4D'),
    cere_temporary = HEX('47B2FF'),
}

-- files for loading
Ceres.FUNCS.load_config(Ceres)

Ceres.ITEMS = {
    card_modifiers = {
        'editions',
        'enhancements',
        'seals',
    },
    consumables = {
        'spectrals',
        'reversed_tarots',
        'vouchers',
    },
    jokers = {
        'common',
        'uncommon',
        'rare',
        'legendary',
        'divine',
    },
    perks = {
        'perk_boosters',
        'perks',
    },
    run_modifiers = {
        'blinds',
        'decks',
        'stakes',
    },
    suits = {
        'suits',
    },
    items = not Ceres.COMPAT.eris and {
        'card',
        'cardarea',
        'funcs',
        'perk',
        'sticker',
        'ui',
    },
    'ui',
}

Ceres.FUNCS.read_files(Ceres)

-- custom rarity based on Cryptid, which was based on Relic-Jokers

G.C.RARITY['cere_divine'] = Ceres.C['divine']

local insert_pool_ref = SMODS.insert_pool
function SMODS.insert_pool(pool, center, replace)
    if pool == nil then pool = {} end
    insert_pool_ref(pool, center, replace)
end

SMODS.current_mod.config_tab = function()
    local ref_table = Ceres.CONFIG
    local _buttons = {
        {label = 'Jokers', toggle_ref = ref_table.jokers, button_ref = 'cere_change_page', ref_page = 'jokers_rarities'},
        {label = 'Consumables', toggle_ref = ref_table.consumables, button_ref = 'cere_change_page', ref_page = 'consumables'},
        {label = 'Card Modifiers', toggle_ref = ref_table.card_modifiers, button_ref = 'cere_change_page', ref_page = 'card_modifiers'},
        {label = 'Run Modifiers', toggle_ref = ref_table.run_modifiers, button_ref = 'cere_change_page', ref_page = 'run_modifiers'},
		{label = 'Suits', toggle_ref = ref_table.suits, remove_enable = true,},
        {label = 'Miscellaneous', button_ref = 'cere_change_page', ref_page = 'misc', remove_enable = true,},
    }
    return {
        n = G.UIT.ROOT,
        config = {
            emboss = 0.05,
            r = 0.1,
            minh = 8,
            minw = 7.3,
            align = 'cm',
            padding = 0.2,
            colour = G.C.BLACK,
        },
        nodes = Ceres.FUNCS.create_buttons(_buttons, false, 'cere_save_config'),
    }
end

function SMODS.current_mod.reset_game_globals()
    G.GAME.cere_clock_card = pick_from_deck('clock')
    G.GAME.cere_yumeko_suit = pick_from_deck('yumeko').suit
    G.GAME.cere_insurance_card = pick_from_deck('fraud')
end

-- NEW FUNCS

function get_perk_pool(key)
    --create the pool
    G.ARGS.TEMP_POOL = EMPTY(G.ARGS.TEMP_POOL)
    local pool = G.ARGS.TEMP_POOL
    local starting_pool = G.P_CENTER_POOLS['Perk']

    -- add any non shredded perks to pool
    for k, v in pairs(starting_pool) do
        if G.GAME.cere_temp.shredded and not G.GAME.cere_temp.shredded[v.key] then
            pool[#pool+1] = v
        end
    end

    if #pool == 0 then
        pool[#pool+1] = G.P_CENTERS['perk_cere_example']
    end

    return pool, key .. G.GAME.round_resets.ante
end

function poll_perk()
    local pool, pool_key = get_perk_pool('perk')
    if #pool == 0 then return false end
    local perk = pseudorandom_element(pool, pseudoseed(pool_key))
    return perk
end

function pick_from_deck(seed)
    local valid_cards = {}
    for k, v in ipairs(G.playing_cards) do
        if v.ability.effect ~= 'Stone Card' then
            valid_cards[#valid_cards+1] = v
        end
    end
    if valid_cards[1] then 
        local random_card = pseudorandom_element(valid_cards, pseudoseed(seed..G.GAME.round_resets.ante))
        return {
            rank = random_card.base.value,
            suit = random_card.base.suit,
            id = random_card.base.id,
        }
    else
        return {
            rank = 'Ace',
            suit = 'Spades',
            id = 14,
        }
    end
end

----------------------------------------------
---------------- MOD CODE END ----------------