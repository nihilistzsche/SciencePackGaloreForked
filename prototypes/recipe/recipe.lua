for i=1, total_packs do
    local pack_time = base_pack_time + (i - 1) * pack_time_increase
    if SciencePackGalore.enable_random_craft_time then
        pack_time = math.ceil(pack_time * math.pow(10, math.random() - 0.5) / 100) * 100
    end

    data:extend({
        {
            type = "recipe",
            name = SciencePackGalore.prefix("science-pack-" .. i),
			enabled = false,
            ingredients = table.deepcopy(science_pack_ingredients[i]),
            energy_required = science_pack_yields[i] * pack_time / 1000,
            result = SciencePackGalore.prefix("science-pack-" .. i),
            result_count = science_pack_yields[i]
        }
    })
    
    -- log("Added a recipe: " .. SciencePackGalore.prefix("science-pack-".. i) .. ".")
    --[[ 
    for key, module in pairs(data.raw.module) do
        if module.limitation and module.effect.productivity then
            table.insert(module.limitation, SciencePackGalore.prefix("science-pack-".. i))
            log("Allowed the use of " .. key .. " for recipe " .. SciencePackGalore.prefix("science-pack-".. i) .. ".")
        end
    end
    ]]--
end