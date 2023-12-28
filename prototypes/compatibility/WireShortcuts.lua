-- Wire Shortcuts removes both red and green wires. An alternate recipe simply requires their components.

if mods["WireShortcuts"] then
    -- Red wire into copper cables, green wire into electronic circuits
    SciencePackGalore.recursiveReplaceName(science_pack_ingredients, "red-wire", "copper-cable")
    SciencePackGalore.recursiveReplaceName(science_pack_ingredients, "green-wire", "electronic-circuit")
end