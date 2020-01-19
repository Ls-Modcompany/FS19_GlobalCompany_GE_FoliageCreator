-- Author:kevink98 / LS-Modcompany
-- Name:TreeCreator
-- Description: Full documentation on github
-- Icon:
-- Hide: no

--VARIABLES--
--Path
local pathFruitDensityGrle = "C:/Users/xxx/Documents/My Games/FarmingSimulator2019/mods/xxx/maps/map/fruitDensity.grle"
local pathFieldDimensions = "C:/Users/xxx/Documents/My Games/FarmingSimulator2019/mods/xxx/maps/map/fieldDimensions.grle";

--Bits
local bitsFruitDensityGrle = 8
local bitsFieldDimensionsGrle = 8

local useBit = 3
local factor = 100000
local treeRadius = 0.5

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

--Load fieldDimensions
local fieldDim = createBitVectorMap("FieldDefs");
local useFieldDim = loadBitVectorMapFromFile(fieldDim, pathFieldDimensions, bitsFieldDimensionsGrle);

--Function from Seasonsmod - Create a random parallelogram
function createRandomPosition()
    local h1 = math.random(-terrainSize/2, terrainSize/2)
    local l1 = math.random(1, 9)
    local h2 = math.random(-terrainSize/2, terrainSize/2)
    local l2 = math.random(1, 9)
        
    local x = h1 + l1 * 0.1
    local z = h2 + l2 * 0.1
    local y = getTerrainHeightAtWorldPos(terrain, x, 0, z)
    
    return  x,y,z
end

local localMapWidth = 0
if useFieldDim then
    localMapWidth, _ = getBitVectorMapSize(fieldDim)
end

local parentTg = getSelection(0)
local templateTg = getChildAt(parentTg, 0)
local numTemplates = getNumOfChildren(templateTg)

local allTrees = {}

function canPlaceTree(x,z)
    for _,tree in pairs(allTrees) do
        local dx = math.abs(x - tree.x)
        local dz = math.abs(z - tree.z)
        if math.sqrt(dx*dx - dz*dz) < treeRadius then
            return false
        end
    end
    return true
end

for i=1,factor do
    local x, y, z = createRandomPosition()
    local value = getBitVectorMapPoint(grle, x + terrainSize/2, z + terrainSize/2, 0, bitsFruitDensityGrle)
    
    local canSet = true
    if useFieldDim then
        local f = localMapWidth / terrainSize
        local xd = x * f
        local yd = z * f
        canSet = getBitVectorMapPoint(fieldDim, xd + terrainSize/2, yd + terrainSize/2, 0, bitsFieldDimensionsGrle) == 0
    end

    if canSet and value == useBit and canPlaceTree(x,z) then
        local templateNum = math.random(0, numTemplates-1)
        local newTree = clone(getChildAt(templateTg, templateNum), false, true)
        link(parentTg, newTree)

        local yRot = math.random( ) * 2 * math.pi

        setTranslation(newTree, x,y,z)
        setRotation(newTree, 0, yRot, 0)
        table.insert(allTrees, {x=x, z=z})
    end
end
print(#allTrees .. " Trees created!")