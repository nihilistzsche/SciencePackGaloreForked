-- For each recipe, get the first tech it unlocks

unlocking_tech = {}

for key, val in pairs(data.raw.technology) do
    if SciencePackGalore.techIsValid(val) then
        if val.effects then
            for _, effect in pairs(val.effects) do
                if effect.type == "unlock-recipe" then
                    log("Technology " .. key .. " unlocks recipe " .. effect.recipe .. ".")
                    if unlocking_tech[effect.recipe] then
                        if tech_order_reverse[unlocking_tech[effect.recipe]] > tech_order_reverse[key] then
                            unlocking_tech[effect.recipe] = key
                        end
                    else
                        unlocking_tech[effect.recipe] = key
                    end
                end
            end
        end
    end
end