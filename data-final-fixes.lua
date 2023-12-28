require("functions")
require("constants")

-- An attempt at total rewrite
require("parsing.mod-tweaks-preliminary")
require("parsing.full-tree")
require("parsing.mod-tweaks")
require("parsing.tree-ordering")
require("parsing.node-status")
require("parsing.spaced-recipes")
require("parsing.preprocess-replacement")

require("prototypes.technology.preprocess")
require("prototypes.technology.recipe-preprocess")
require("prototypes.technology.crafting-hierarchy")
require("prototypes.technology.item-preprocess")
require("prototypes.technology.science-pack-prereqs")
require("prototypes.technology.technology-deepcopy")
require("prototypes.technology.technology-modified")
require("prototypes.technology.lab-fixes")