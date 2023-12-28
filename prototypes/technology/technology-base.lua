for i=1, total_packs do
    data:extend({
        {
            type = "technology",
            name = SciencePackGalore.prefix("science-pack-" .. i .. "-tech"),
            localised_name = {"item-name." .. SciencePackGalore.prefix("science-pack-" .. i)},
            icon = "__SciencePackGaloreForked__/graphics/technologies/science-pack-" .. i .. ".png",
            icon_size = 256,
            effects =
            {
                {
                    type = "unlock-recipe",
                    recipe = SciencePackGalore.prefix("science-pack-" .. i)
                }
            },
            unit =
            {
                count = 10,
                ingredients = {{"automation-science-pack", 1}},
                time = 10
            },
            order = "z[science-pack-" .. SciencePackGalore.toFixedString(i) .. "]"
        }
    })

    -- log("Added a technology: " .. SciencePackGalore.prefix("science-pack-".. i .. "-tech") .. ".")
end
