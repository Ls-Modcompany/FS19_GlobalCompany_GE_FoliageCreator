-- Author:kevink98 / LS-Modcompany
-- Name:FoliageCreator
-- Description: Full documentation on github
-- Icon:
-- Hide: no

--VARIABLES--
--Path
local pathFruitDensityGrle = "C:/Users/xxx/Documents/My Games/FarmingSimulator2019/mods/xxx/maps/map/fruitDensity.grle"
local pathFieldDimensions = "C:/Users/xxx/Documents/My Games/FarmingSimulator2019/mods/xxx/maps/map/fieldDimensions.grle";

--Bits
local bitsFruitDensityGdm = 5
local bitsFruitDensityGrle = 8
local bitsFieldDimensionsGrle = 8


--CONSTANTS--
-- decoFoliage State 1: 1
-- decoFoliage State 2: 2
-- decoFoliage State 3: 3
-- decoFoliage State 4: 4
-- decoFoliage State 5: 5
-- decoFoliage State 6: 6
-- decoFoliage State 7: 7
-- decoFoliage State 8: 8
-- decoFoliage State 9: 9
-- decoFoliage State 10: 10
-- decoFoliage State 11: 11
-- bush01 State 1: 12
-- bush01 State 2: 13
-- bush01 State 3: 14
-- bush01 State 4: 15
-- grass State 1: 16
-- grass State 2: 17
-- grass State 3: 18
-- grass State 4: 19
-- grass State 5: 20

local bit_grass_state = 19 -- one value - will be set always!

local bit_grass_states = {13, 3}
local bit_grass_factor = 100000

local bit_wald_states = {13, 3, 14, 15, 10, 3, 10, 3, 10, 3, 10}
local bit_wald_factor = 1000000

local bit_grassDeco_states = {3, 5, 6, 8}
local bit_grassDeco_factor = 100000

local maxFactor = 1000000

-------------------
--NO CHANGES HERE--
-------------------

local bit_grass = 1
local bit_wald = 2
local bit_grassDeco = 3

--Terrain
local terrain = getChild(getChildAt(getRootNode(), 0), "terrain")
local terrainSize = getTerrainSize(terrain)

--Load GRLE
local grle = createBitVectorMap("FruitDensity")
if not loadBitVectorMapFromFile(grle, pathFruitDensityGrle, bitsFruitDensityGrle) then
    print("Can't load file!")
    return;
end;

--Load GDM
local id_grass = getTerrainDetailByName(terrain, "grass")
local id_decoFoliage = getTerrainDetailByName(terrain, "decoFoliage")
local id_bush = getTerrainDetailByName(terrain, "bush01")

local modifier_grass = DensityMapModifier:new(id_grass, 0, bitsFruitDensityGdm)
local modifier_decoFoliage = DensityMapModifier:new(id_decoFoliage, 0, bitsFruitDensityGdm)
local modifier_bush = DensityMapModifier:new(id_bush, 0, bitsFruitDensityGdm)

--Load fieldDimensions
local fieldDim = createBitVectorMap("FieldDefs");
local useFieldDim = loadBitVectorMapFromFile(fieldDim, pathFieldDimensions, bitsFieldDimensionsGrle);

--Function from Seasonsmod - Create a random parallelogram
function createRandomParallelogram(size, randomSize)
    local height = size
    local width = size
    if randomSize then
        height = math.abs(2 * math.random() - 1) * size
        size = math.abs(2 * math.random() - 1) * size
    end
    local startWorldX = (2 * math.random() - 1) * terrainSize / 2       
    local startWorldZ = (2 * math.random() - 1) * terrainSize / 2
    local widthWorldX = startWorldX + width +  (2 * math.random() - 1) * size
    local widthWorldZ = startWorldZ + (2 * math.random() - 1) * size
    local heightWorldX = startWorldX + (2 * math.random() - 1) * size
    local heightWorldZ = startWorldZ + height + (2 * math.random() - 1) * size
    return startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ
end

--Function from GlobalCompany - Get count of table
function getTableLength(t)
	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end

-- Set value on the correct layer
function setValue(value, sx, sz, wx, wz, hx, hz)
    if value <= 11 then   
        modifier_decoFoliage:setParallelogramUVCoords(sx / terrainSize + 0.5, sz / terrainSize + 0.5, wx / terrainSize + 0.5, wz / terrainSize + 0.5, hx / terrainSize + 0.5, hz / terrainSize + 0.5, "ppp")
        modifier_decoFoliage:executeSet(value)
    elseif value > 11 and value <= 15 then
        modifier_bush:setParallelogramUVCoords(sx / terrainSize + 0.5, sz / terrainSize + 0.5, wx / terrainSize + 0.5, wz / terrainSize + 0.5, hx / terrainSize + 0.5, hz / terrainSize + 0.5, "ppp")
        modifier_bush:executeSet(value - 11)  
    elseif value > 15 and value <= 20 then
        modifier_grass:setParallelogramUVCoords(sx / terrainSize + 0.5, sz / terrainSize + 0.5, wx / terrainSize + 0.5, wz / terrainSize + 0.5, hx / terrainSize + 0.5, hz / terrainSize + 0.5, "ppp")
        modifier_grass:executeSet(value - 15) 
    end
end

local localMapWidth = 0
if useFieldDim then
    localMapWidth, _ = getBitVectorMapSize(fieldDim)
end

--make grass
local edges = terrainSize / 2
for i=-edges, edges do
    for j=-edges, edges do
        local value = getBitVectorMapPoint(grle,i + terrainSize/2, j + terrainSize/2, 0, bitsFruitDensityGrle)       
        if value == bit_grass or value == bit_grassDeco then
            local canSet = true
            if useFieldDim then
                local f = localMapWidth / terrainSize
                local x = i * f
                local y = j * f
                canSet = getBitVectorMapPoint(fieldDim, x + terrainSize/2, y + terrainSize/2, 0, bitsFieldDimensionsGrle) == 0
            end
            if canSet then
                setValue(bit_grass_state, i, j, i+1, j, i, j+1)
            end
        end
    end
end

--Do random foliage
for i=1,maxFactor do
    local sx, sz, wx, wz, hx, hz = createRandomParallelogram(1, true)
    local value = getBitVectorMapPoint(grle, sx + terrainSize/2, sz + terrainSize/2, 0, bitsFruitDensityGrle)
    
    local canSet = true
    if useFieldDim then
        local f = localMapWidth / terrainSize
        local x = sx * f
        local y = sz * f
        canSet = getBitVectorMapPoint(fieldDim, x + terrainSize/2, y + terrainSize/2, 0, bitsFieldDimensionsGrle) == 0
    end

    if canSet then
        if value == bit_grass and i < bit_grass_factor then
            setValue(bit_grass_states[math.random(1,getTableLength(bit_grass_states))], sx, sz, wx, wz, hx, hz)
        elseif value == bit_wald and i < bit_wald_factor then
            setValue(bit_wald_states[math.random(1,getTableLength(bit_wald_states))], sx, sz, wx, wz, hx, hz)
        elseif value == bit_grassDeco and i < bit_grassDeco_factor then
            setValue(bit_grassDeco_states[math.random(1,getTableLength(bit_grassDeco_states))], sx, sz, wx, wz, hx, hz)
        end
    end
end
print("Foliage created!")