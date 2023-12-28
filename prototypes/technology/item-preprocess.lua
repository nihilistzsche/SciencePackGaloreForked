-- For each item, get the first tech that unlocks a recipe which it is an output of, and not an input of

item_techs = {}
base_items = {}

for key, val in pairs(data.raw.recipe) do
    if SciencePackGalore.isRecipeEnabledFromStart(val) and not unlocking_tech[key] then
        log("Recipe " .. key .. " is available from the start.")
        local result_lnk = val
        if val.normal then
            result_lnk = val.normal
        end
        local banned_items = {}
        if result_lnk.ingredients then
            for _, ingredient in pairs(result_lnk.ingredients) do
                local ingredient_name = SciencePackGalore.getItemName(ingredient)
                if ingredient_name then
                    banned_items[ingredient_name] = true
                end
            end
        end
        if result_lnk.result and not banned_items[result_lnk.result] then
            base_items[result_lnk.result] = true
        end
        if result_lnk.results then
            for _, result in pairs(result_lnk.results) do
                local item_name = SciencePackGalore.getItemName(result)
                if item_name and not banned_items[item_name] then
                    base_items[item_name] = true
                end
            end
        end
    else
        if unlocking_tech[key] then
            local recipe_unlock = unlocking_tech[key]
            log("Recipe " .. key .. " requires technology " .. recipe_unlock .. ".")
            local result_lnk = val
            if val.normal then
                result_lnk = val.normal
            end
            local banned_items = {}
            if result_lnk.ingredients then
                for _, ingredient in pairs(result_lnk.ingredients) do
                    local ingredient_name = SciencePackGalore.getItemName(ingredient)
                    if ingredient_name then
                        banned_items[ingredient_name] = true
                    end
                end
            end
            if result_lnk.result and not banned_items[result_lnk.result] then
                if item_techs[result_lnk.result] then
                    if tech_order_reverse[item_techs[result_lnk.result]] > tech_order_reverse[recipe_unlock] then
                        item_techs[result_lnk.result] = recipe_unlock
                    end
                else
                    item_techs[result_lnk.result] = recipe_unlock
                end
            end
            if result_lnk.results then
                for _, result in pairs(result_lnk.results) do
                    local item_name = SciencePackGalore.getItemName(result)
                    if item_name and not banned_items[item_name] then
                        if item_techs[item_name] then
                            if tech_order_reverse[item_techs[item_name]] > tech_order_reverse[recipe_unlock] then
                                item_techs[item_name] = recipe_unlock
                            end
                        else
                            item_techs[item_name] = recipe_unlock
                        end
                    end
                end
            end
        end
    end
end

for key, val in pairs(item_techs) do
    log("Item " .. key .. " requires technology " .. val .. ".")
end