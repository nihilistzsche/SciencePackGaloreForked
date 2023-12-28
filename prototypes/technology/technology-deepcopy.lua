-- Deepcopy all technology prerequisites and unit ingredients, so they do not try to do some funny stuff
for _, key in pairs(tech_order) do
    data.raw.technology[key].prerequisites = table.deepcopy(data.raw.technology[key].prerequisites)
    data.raw.technology[key].unit = table.deepcopy(data.raw.technology[key].unit)
    data.raw.technology[key].unit.ingredients = table.deepcopy(data.raw.technology[key].unit.ingredients)
end