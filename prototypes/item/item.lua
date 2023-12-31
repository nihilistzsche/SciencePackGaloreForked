for i=1, total_packs do
    data:extend({
        {
            type = "tool",
            name = SciencePackGalore.prefix("science-pack-" .. i),
            localised_description = {"item-description.science-pack"},
            icon = "__SciencePackGaloreForked__/graphics/icons/science-pack-" .. i .. ".png",
            icon_size = 64,
            subgroup = "science-pack",
            stack_size = 200,
            order = "z[science-pack-" .. SciencePackGalore.toFixedString(i) .. "]",
            durability = 1,
            durability_description_key = "description.science-pack-remaining-amount-key",
            durability_description_value = "description.science-pack-remaining-amount-value"
        }
    })

    -- log("Added an item: " .. SciencePackGalore.prefix("science-pack-".. i) .. ".")
end