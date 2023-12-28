if SciencePackGalore.enable_random_pack_recipes then

    -- Generate a new recipe for each science pack.
    -- First, order all items based on their technology level unlocks.
    -- Then, pick some ingredients among the prefix to be used in a science pack, generate some random numbers, get the cost and balance it.

    -- Ignored items: 
    -- - any non-infinite stuff 
    -- - science packs themselves (of all types)
    -- - anything that is a fixed recipe in rocket silo
    -- - burnt results
    -- - anything with the cost above 100k

    local item_blacklist = {}
    for key, val in pairs(data.raw['rocket-silo']) do
        if val.fixed_recipe then
            item_blacklist[val.fixed_recipe] = true
        end
    end

    for key, val in pairs(data.raw['tool']) do
        item_blacklist[key] = true
    end

    for _, category in pairs(item_prototype_classes) do
        for key, val in pairs(data.raw[category]) do
            if val.burnt_result then
                item_blacklist[val.burnt_result] = true
            end
        end
    end

    for key, val in pairs(SciencePackGalore.prototype_internal_id["item"]) do
        if SciencePackGalore.entity_full_cost[val] == nil or SciencePackGalore.entity_full_cost[val] > 100000 then
            item_blacklist[key] = true
        end
    end

    local proper_item_order = {}

    for ind, val in pairs(SciencePackGalore.reverse_prototype_internal_id) do
        if val.type == 'item' and not item_blacklist[val.name] and SciencePackGalore.min_level_to_produce_infinitely[ind] then
            table.insert(proper_item_order, ind)
        end
    end

    table.sort(proper_item_order, SciencePackGalore.orderTwoItems)

    local items_total = SciencePackGalore.tableSize(proper_item_order)

    if items_total < total_packs + 1 then
        log("The mod encountered too few valid items. Random recipes disabled.")
    else
        for i=1, total_packs do
            local target_pack_cost = SciencePackGalore.first_pack_cost * (SciencePackGalore.last_pack_cost / SciencePackGalore.first_pack_cost) ^ ((i - 1) / (total_packs - 1))

            local main_ingredient_start = math.ceil(items_total * (i - 1) / total_packs) + 1
            local main_ingredient_end = math.ceil(items_total * i / total_packs)

            local running_cost = 0
            local ingredient_list = {}

            local iterations = 0
            local main_ingredient = math.random(main_ingredient_start, main_ingredient_end)
            while SciencePackGalore.entity_full_cost[proper_item_order[main_ingredient]] > math.pow(2, iterations) * target_pack_cost and iterations < max_random_selection_iterations do
                main_ingredient = math.random(main_ingredient_start, main_ingredient_end)
                iterations = iterations + 1
            end

            local main_ingredient_amt = SciencePackGalore.roundToFirstDigit(math.ceil(target_pack_cost / SciencePackGalore.entity_full_cost[proper_item_order[main_ingredient]] * (math.random() + 2)))
            table.insert(ingredient_list, {type = "item", name = SciencePackGalore.reverse_prototype_internal_id[proper_item_order[main_ingredient]].name, amount = main_ingredient_amt})
            running_cost = running_cost + main_ingredient_amt * SciencePackGalore.entity_full_cost[proper_item_order[main_ingredient]]

            local ingredient_total = 1
            local selected_ingredients = {[main_ingredient] = true}

            while ingredient_total < 2 + i / 9 and ingredient_total <= main_ingredient_end - main_ingredient_start and (ingredient_total < 2 or running_cost * math.random() < 3 * target_pack_cost) do
                local iterations = 0
                local new_ingredient = math.random(main_ingredient_start, main_ingredient_end)
                while selected_ingredients[new_ingredient] and iterations < max_random_selection_iterations do
                    new_ingredient = math.random(main_ingredient_start, main_ingredient_end)
                    iterations = iterations + 1
                end
                if iterations < max_random_selection_iterations then
                    selected_ingredients[new_ingredient] = true
                    local ingredient_amt = SciencePackGalore.roundToFirstDigit(math.ceil(target_pack_cost / SciencePackGalore.entity_full_cost[proper_item_order[new_ingredient]] * (math.random() + 1 / ingredient_total)))
                    table.insert(ingredient_list, {type = "item", name = SciencePackGalore.reverse_prototype_internal_id[proper_item_order[new_ingredient]].name, amount = ingredient_amt})
                    running_cost = running_cost + ingredient_amt * SciencePackGalore.entity_full_cost[proper_item_order[new_ingredient]]
                end
                ingredient_total = ingredient_total + 1
            end

            data.raw.recipe[SciencePackGalore.prefix("science-pack-" .. i)].ingredients = ingredient_list
            local new_result_count = math.min(65535, math.max(1, SciencePackGalore.roundToFirstDigit(running_cost / target_pack_cost)))
            data.raw.recipe[SciencePackGalore.prefix("science-pack-" .. i)].energy_required =  data.raw.recipe[SciencePackGalore.prefix("science-pack-" .. i)].energy_required * new_result_count / data.raw.recipe[SciencePackGalore.prefix("science-pack-" .. i)].result_count
            data.raw.recipe[SciencePackGalore.prefix("science-pack-" .. i)].result_count = new_result_count

            data.raw.tool[SciencePackGalore.prefix("science-pack-" .. i)].stack_size = math.max(data.raw.tool[SciencePackGalore.prefix("science-pack-" .. i)].stack_size, new_result_count)
            data.raw.tool[SciencePackGalore.prefix("science-pack-" .. i)].localised_name = {"item-name." .. SciencePackGalore.prefix("science-pack-generic"), i}
            data.raw.technology[SciencePackGalore.prefix("science-pack-" .. i .. "-tech")].localised_name = {"item-name." .. SciencePackGalore.prefix("science-pack-generic"), i}
        end
    end

end