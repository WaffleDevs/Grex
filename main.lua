SMODS.optional_features.retrigger_joker = true

G.FUNCS.can_merge_joker = function(args)
    local card = args.config.ref_table
    local right_joker = nil
    for i = 1, #G.jokers.cards do
        if G.jokers.cards[i] == card and G.jokers.cards[i+1] and card.config.center_key == G.jokers.cards[i+1].config.center_key then
            right_joker = G.jokers.cards[i + 1]
        end
    end
    if right_joker then 
        args.config.colour = G.C.GREEN
        args.config.button = 'merge_joker'
    else
        args.config.colour = G.C.UI.BACKGROUND_INACTIVE
        args.config.button = nil
    end
end

G.FUNCS.merge_joker = function(args)
    local card = args.config.ref_table
    local right_joker = nil
    for i = 1, #G.jokers.cards do
        if G.jokers.cards[i] == card then
            right_joker = G.jokers.cards[i + 1]
        end
    end
    G.jokers:remove_card(right_joker)
    right_joker:remove()
    card.ability.grex_repeats = (card.ability.grex_repeats or 0) + 1
end

SMODS.Joker {
    key = "test",
    loc_txt = {
        name = "Test",
        text = {"Test"}
    },
    pos = {x=1,y=1},
    calculate = function (self, card, context)
        if context.retrigger_joker_check and not context.retrigger_joker then
            return {
                message = localize("k_again_ex"),
                repetitions = 2,
                card = card,
            }
        end
    end
}


-- watch lua Mods/Grex/main.lua