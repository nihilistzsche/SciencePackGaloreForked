for i=1, total_packs do
    data.raw.recipe[SciencePackGalore.prefix("science-pack-" .. i)].ingredients = table.deepcopy(science_pack_ingredients[i])
end