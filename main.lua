SMODS.optional_features.retrigger_joker = true
local config = SMODS.current_mod.config
SMODS.current_mod.config_tab = function()
    return {n = G.UIT.ROOT, config = {
        r = .2, colour = G.C.BLACK
    }, nodes = {
        {n = G.UIT.C, config = { padding = .5,}, nodes = {
            create_toggle({label = "Ignore Editions", ref_table = config, ref_value = 'ignore_editions', info = {"If ignored, any editions can be stacked into one.", "This would mean the main Joker would be the main edition.","Splitting while Ignoring Editions, will always yield an editionless joker."}, active_colour = G.C.RED}) or nil,
        }}
    }}
end


G.FUNCS.can_merge_joker = function(args)
    local card = args.config.ref_table
    local right_joker = nil
    for i = 1, #G.jokers.cards do
        if G.jokers.cards[i] == card and G.jokers.cards[i+1] and card.config.center_key == G.jokers.cards[i+1].config.center_key then
            right_joker = G.jokers.cards[i + 1]
        end
    end
    if right_joker and (config.ignore_editions or (card.edition and card.edition.key) == (right_joker.edition and right_joker.edition.key))then 
        args.config.colour = copy_table(G.C.FILTER)
        args.config.button = 'merge_joker'
    else
        args.config.colour = copy_table(G.C.UI.BACKGROUND_INACTIVE)
        args.config.button = nil
    end
    args.config.colour[4] = args.config.colour[4] * 0.6
end

G.FUNCS.can_split_joker = function(args)
    local card = args.config.ref_table
    local grex_amount = card.ability.grex_count or 0

    local split_type = args.config.split_type

    if grex_amount > 1 then 
        args.config.colour = copy_table(split_type == "half_split" and G.C.BLUE or G.C.GREEN)
        args.config.button = "split_joker"
    else
        args.config.colour = copy_table(G.C.UI.BACKGROUND_INACTIVE)
        args.config.button = nil
    end
    args.config.colour[4] = args.config.colour[4] * 0.6
end


G.FUNCS.merge_joker = function(args)
    local card = args.config.ref_table
    local right_joker = nil
    for i = 1, #G.jokers.cards do
        if G.jokers.cards[i] == card then
            right_joker = G.jokers.cards[i + 1]
        end
    end
    card.ability.grex_count = (card.ability.grex_count or 1) + (right_joker.ability.grex_count or 1)
    card.mass_sell_value = (card.cost or 1)/2 * (card.ability.grex_count)
    if type(card.sell_cost_label) == "number" then
        card.mass_sell_cost_label = card.sell_cost_label * card.ability.grex_count
    end
    G.jokers:remove_card(right_joker)
    play_sound('slice1', 0.96+math.random()*0.08)
    right_joker:remove(true)
end

G.FUNCS.split_joker = function(args)
    local card = args.config.ref_table
    local grex_amount = card.ability.grex_count or 1

    local split_type = args.config.split_type
    local split_amount = split_type == "half_split" and math.floor(grex_amount/2) or 1

    local new_joker = copy_card(card, nil, nil, nil, config.ignore_editions)
    G.jokers:emplace(new_joker)
    card.ability.grex_count = grex_amount - split_amount
    card.mass_sell_value = (card.cost or 1)/2 * (card.ability.grex_count)
    if type(card.sell_cost_label) == "number" then
        card.mass_sell_cost_label = card.sell_cost_label * card.ability.grex_count
    end
    new_joker.ability.grex_count = split_amount
    new_joker.mass_sell_value = (card.cost or 1)/2 * (card.ability.grex_count)
    if type(new_joker.sell_cost_label) == "number" then
        new_joker.mass_sell_cost_label = new_joker.sell_cost_label * new_joker.ability.grex_count
    end
end

G.UIDEF.merge_button = function (card)
    if card.area and card.area.config.type == 'joker' then
        return {n=G.UIT.ROOT, config = { colour = G.C.CLEAR}, nodes={
            {n=G.UIT.R, config={align = "cm"}, nodes={
                {n=G.UIT.R, config={ref_table = card, align = "cm",padding = 0.135, r=0.08, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, button = 'merge_joker', func = 'can_merge_joker'}, nodes={
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        {n=G.UIT.T, config={text = "Merge",colour = G.C.UI.TEXT_LIGHT, scale = 0.3, shadow = true}}
                    }},
                }},
                {n=G.UIT.R, config={}, nodes={
                    {n=G.UIT.B, config = {w=0.1,h=0.1}},
                }},
                {n=G.UIT.R, config={ref_table = card, align = "cm",padding = 0.135, r=0.08, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, button = 'split_joker', split_type="half_split", func = 'can_split_joker'}, nodes={
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        {n=G.UIT.T, config={text = "Split Half",colour = G.C.UI.TEXT_LIGHT, scale = 0.25, shadow = true}}
                    }},
                }},
                {n=G.UIT.R, config={}, nodes={
                    {n=G.UIT.B, config = {w=0.1,h=0.1}},
                }},
                {n=G.UIT.R, config={ref_table = card, align = "cm",padding = 0.135, r=0.08, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, button = 'split_joker', split_type="single_split", func = 'can_split_joker'}, nodes={
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        {n=G.UIT.T, config={text = "Split 1",colour = G.C.UI.TEXT_LIGHT, scale = 0.25, shadow = true}}
                    }},
                }},
            }}  
        }}
    end
    return {n=G.UIT.ROOT, config = { colour = G.C.CLEAR}, nodes={}}
end


G.FUNCS.mass_sell_card = function(args)
    local card = args.config.ref_table
    card.sell_cost = card.mass_sell_value
    
    card:sell_card(true)
    SMODS.calculate_context({selling_card = true, card = card})
end
G.FUNCS.can_mass_sell_card = function(args)
    local card = args.config.ref_table
    if card.ability.grex_count and card.ability.grex_count > 1 then
        G.FUNCS.can_sell_card(args)
        if args.config.button then args.config.button = "mass_sell_card" end
    end
end


SMODS.find_card = function (key, count_debuffed)
    local results = {}
    if not G.jokers or not G.jokers.cards then return {} end
    for _, area in ipairs(SMODS.get_card_areas('jokers')) do
        if area.cards then
            for _, v in pairs(area.cards) do
                if v and type(v) == 'table' and v.config.center.key == key and (count_debuffed or not v.debuff) then
                    for i = 1, (v.ability.grex_count or 1) do
                        table.insert(results, v)
                    end
                end
            end
        end
    end
    return results
end







-- watch lua Mods/Grex/main.lua