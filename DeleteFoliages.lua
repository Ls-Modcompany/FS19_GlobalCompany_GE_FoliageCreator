-- Author: FoliageCreate: kevink98 / LS-Modcompany (adapted by TopAce888 for FoliageDelete)
-- Name:FoliageDelete
-- Description: Full documentation on github
-- Icon:
-- Hide: no

--VARIABLES--
--Path
local pathFruitDensityGrle = "C:/Users/xxx/Documents/My Games/FarmingSimulator2019/mods/xxx/maps/map/fruitDensity.grle"
local pathFieldDimensions = "C:/Users/xxx/Documents/My Games/FarmingSimulator2019//mods/xxx/maps/map/fieldDimensions.grle"

--Bits
local bitsFruitDensityGdm = 5
local bitsFruitDensityGrle = 8
local bitsFieldDimensionsGrle = 8

local bit_delete = 1

-------------------
--NO CHANGES HERE--
-------------------


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
local id = getTerrainDetailByName(terrain, "grass")
local modifier = DensityMapModifier:new(id, 0, bitsFruitDensityGdm)

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
function setValue(sx, sz, wx, wz, hx, hz)
        modifier:setParallelogramUVCoords(sx / terrainSize + 0.5, sz / terrainSize + 0.5, wx / terrainSize + 0.5, wz / terrainSize + 0.5, hx / terrainSize + 0.5, hz / terrainSize + 0.5, "ppp")
        modifier:executeSet(0)
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
        if value == bit_delete then
            local canSet = true
            if useFieldDim then
                local f = localMapWidth / terrainSize
                local x = i * f
                local y = j * f
                canSet = getBitVectorMapPoint(fieldDim, x + terrainSize/2, y + terrainSize/2, 0, bitsFieldDimensionsGrle) == 0
            end
            if canSet then
                setValue(i, j, i+1, j, i, j+1)
            end
        end
    end
end

print("Foliage deleted!")