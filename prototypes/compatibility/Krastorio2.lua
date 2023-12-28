-- Krastorio 2 removes uranium rounds magazines.

if mods["Krastorio2"] then
    -- Uranium rifle magazine instead of uranium rounds magazine
    SciencePackGalore.recursiveReplaceName(science_pack_ingredients, "uranium-rounds-magazine", "uranium-rifle-magazine")
end