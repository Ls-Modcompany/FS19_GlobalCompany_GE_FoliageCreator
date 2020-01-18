-- Author:kevink98 / LS-Modcompany
-- Name:DeleteFoliages
-- Description: Full documentation on github
-- Icon:
-- Hide: no

local bitsFruitDensityGdm = 5

-------------------
--NO CHANGES HERE--
-------------------

--Terrain
local terrain = getChild(getChildAt(getRootNode(), 0), "terrain")
local terrainSize = getTerrainSize(terrain)

--Load GRLE
local id = getTerrainDetailByName(terrain, "grass")

local modifier = DensityMapModifier:new(id, 0, bitsFruitDensityGdm)

local sx = terrainSize / -2
local sz = terrainSize / -2
local wx = terrainSize / -2
local wz = terrainSize / 2
local hx = terrainSize / 2
local hz = terrainSize / -2

modifier:setParallelogramUVCoords(sx / terrainSize + 0.5, sz / terrainSize + 0.5, wx / terrainSize + 0.5, wz / terrainSize + 0.5, hx / terrainSize + 0.5, hz / terrainSize + 0.5, "ppp")
modifier:executeSet(0)