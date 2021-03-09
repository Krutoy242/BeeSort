--[[

Bee sorting program

Breeds best Princesses and Drones together

]]

local sides = require("sides")
local component = require'component'

local proxies = {
  component.proxy('e32f247b-1a3d-46cd-b9c4-6704c6429949'),
  component.proxy('f24961ff-833a-4a07-badc-37e02b6ed64a'),
}

-- Temperature, Humidity
local beeHabitats = {
  Agrarian    = { 0, 0},
  Austere     = { 1, 1},
  Avenging    = { 0, 0},
  Boggy       = { 0,-1},
  Common      = { 0, 0},
  Cultivated  = { 0, 0},
  Demonic     = { 3, 1},
  Diligent    = { 0, 0},
  Edenic      = { 1,-1},
  Ender       = {-1, 0},
  Exotic      = { 1,-1},
  Farmerly    = { 0, 0},
  Fiendish    = { 3, 1},
  Forest      = { 0, 0},
  Frugal      = { 1, 1},
  Glacial     = {-3, 0},
  Hermitic    = { 0, 0},
  Heroic      = { 0, 0},
  Icy         = {-3, 0},
  Imperial    = { 0, 0},
  Industrious = { 0, 0},
  Leporine    = { 0, 0},
  Majestic    = { 0, 0},
  Marshy      = { 0,-1},
  Meadows     = { 0, 0},
  Merry       = {-3, 0},
  Miry        = { 0,-1},
  Modest      = { 1, 1},
  Monastic    = { 0, 0},
  Noble       = { 0, 0},
  Phantasmal  = {-1, 0},
  Rural       = { 0, 0},
  Secluded    = { 0, 0},
  Sinister    = { 3, 1},
  Spectral    = {-1, 0},
  Steadfast   = { 0, 0},
  Tipsy       = {-3, 0},
  Tricky      = { 0, 0},
  Tropical    = { 1,-1},
  Unweary     = { 0, 0},
  Valiant     = { 0, 0},
  Vengeful    = { 0, 0},
  Vindictive  = { 0, 0},
  Wintry      = {-3, 0},
  Derpious    = { 0, 0},

  ["gendustry.bees.species.artisan"]     = { 0,-1},
  ["gendustry.bees.species.chilled"]     = {-1, 0},
  ["gendustry.bees.species.scrappy"]     = { 1,-1},
  ["gendustry.bees.species.dull"]        = {-3,-1},
  ["gendustry.bees.species.egoistic"]    = { 3, 1},
  ["gendustry.bees.species.elysian"]     = { 3, 0},
  ["gendustry.bees.species.gallant"]     = {-1,-1},
  ["gendustry.bees.species.narcissistic"]= { 1,-1},
  ["gendustry.bees.species.oozy"]        = { 1,-1},
  ["gendustry.bees.species.paughty"]     = { 3, 0},
  ["gendustry.bees.species.potter"]      = {-1, 0},
  ["gendustry.bees.species.selfish"]     = { 1, 1},
  ["gendustry.bees.species.tinker"]      = {-3, 1},
  ["gendustry.bees.species.tinsmith"]    = { 3, 1},
  ["gendustry.bees.species.vain"]        = { 3,-1},
  ["gendustry.bees.species.wacky"]       = {-1, 0},
}

local function isDrone   (stack) return stack.name == 'forestry:bee_drone_ge' end
local function isPrincess(stack) return stack.name == 'forestry:bee_princess_ge' end
local function moveCallback(transferFnc, sideFrom, sideTo)
  return function (slotFrom, count)
    if slotFrom==-1 then return false end
    local status, result = pcall(transferFnc, sideFrom, sideTo, count or 1, slotFrom)
    return status and result ~= 0.0
  end
end

local function getTolerance(v)
  local word = v:match("^(%S+)")
  local num = tonumber(v:match("(%d+)$")) or 0
  return ({
      Both={-num,num},
      Up=  {0,num},
      Down={-num,0},
      None={0,0},
    })[word]
end

local function getCallbacks(data)
  return {
    name = data.name,
    comp = function (stack)
      if data.comp and not data.comp(stack) then return false end

      local active = stack.individual.active
      local h1 = beeHabitats[active.species]
      local h2 = data.habitat
      if h1[1] == h2[1] and h1[2] == h2[2] then return true end

      local ht = {
        getTolerance(active.temperatureTolerance),
        getTolerance(active.humidityTolerance),
      }
      for i = 1, 2 do
        if not (h1[i] >= h2[i]+ht[i][1] and h1[i] <= h2[i]+ht[i][2]) then
          return false
        end
      end
      return true
    end,
    getPrincessStack = function ()
      return data.tr.getStackInSlot(data.out, 1)
    end,
    isNeedDrone = function (notCheckPrincess, princessStack)
      if notCheckPrincess or (princessStack and isPrincess(princessStack)) then
        return not data.tr.getStackInSlot(data.out, 2)
      end
    end,
    move = moveCallback(data.tr.transferItem, data.source, data.out)
  }
end

local biomes = {
  getCallbacks{
    name   = 'Hellish',
    habitat= { 3, 1},
    comp   = function (stack)
      return stack.individual.active.caveDwelling and stack.individual.active.neverSleeps
    end,
    tr     = proxies[2],
    source = sides.down,
    out    = sides.north,
  },
  getCallbacks{
    name   = 'Icy',
    habitat= {-3, 0},
    tr     = proxies[2],
    source = sides.down,
    out    = sides.south,
  },
  getCallbacks{
    name   = 'Swamp',
    habitat= { 0,-1},
    tr     = proxies[2],
    source = sides.down,
    out    = sides.up,
  },
  getCallbacks{
    name   = 'Desert',
    habitat= { 1, 1},
    tr     = proxies[1],
    source = sides.up,
    out    = sides.south,
  },
  getCallbacks{
    name   = 'Tropic',
    habitat= { 1,-1},
    tr     = proxies[1],
    source = sides.up,
    out    = sides.north,
  },

  -- Default should go last
  getCallbacks{
    name   = 'Normal',
    habitat= { 0, 0},
    tr     = proxies[1],
    source = sides.top,
    out    = sides.east,
  },
}

local trashFnc = moveCallback(proxies[1].transferItem, sides.top, sides.bottom)

---------------------------------------------
-- Calculating score
---------------------------------------------

local function tolerance(v)
  local word = v:match("^(%S+)")
  local num = tonumber(v:match("(%d+)$"))
  return (({
    Both=2.0,
    Up=0.25,
    Down=0.25
  })[word] or 1.0)
  * (num or 1.0)
end

local function territoryScore(v)
  local x,y,z = v:match("^Vec3i{x=(%d+), y=(%d+), z=(%d+)}")
  return (tonumber(x) + tonumber(y) + tonumber(z)) / 40
end

local speciesPool = {
  _total = 1
}
local function addSpecieToPool(stack)
  local specieName = stack.individual and stack.individual.active and stack.individual.active.species
  if not specieName then return end
  speciesPool[specieName] = (speciesPool[specieName] or 0) + 1
  speciesPool._total = speciesPool._total + 1
end
local function getDiversity(specieName)
  return math.log(speciesPool._total / (speciesPool[specieName] or 1)) * 2
end


local scores = {
  flowerProvider       = function(v) return ({Flowers=1, End=-5})[v] or 0.0 end,
  fertility            = function(v) return v/2.0 end,
  flowering            = function(v) return v / 30 end,
  speed                = function(v) return v end,
  lifespan             = function(v) return 80.0 / v end,
  species              = function(v) return (({Cultivated=0, Avenging=-5})[v] or 1.0) + getDiversity(v) end,
  neverSleeps          = function(v) return v and 2.0 or 0.0 end,
  humidityTolerance    = function(v) return tolerance(v) end,
  temperatureTolerance = function(v) return tolerance(v) end,
  effect               = function(v) return ({None=0, Explorer=2})[v] or 1.0 end,
  territory            = function(v) return territoryScore(v) end,
  caveDwelling         = function(v) return v and 2.0 or 0.0 end,
  toleratesRain        = function(v) return v and 1.0 or 0.0 end,
}

local function getStackScore(stack)
  if(stack.individual == nil or stack.individual.active == nil) then return nil end
  local score = 0.0
  for gene, mult in pairs({active=1.0, inactive=0.75}) do
    for name, v in pairs(stack.individual[gene]) do
      score = score + scores[name](v) * mult
    end
  end
  return score
end

local function getSortedList()
  local t = {}
  local slot = 0
  for stack in proxies[1].getAllStacks(sides.top) do
    slot = slot + 1
    local v = getStackScore(stack)
    if v ~= nil then
      t[slot] = {slot, v, stack, isDrone(stack)}
    end
  end
  table.sort(t, function(a,b)return ((b or {})[2] or 0)-((a or {})[2] or 0) < 0 end)
  return t, slot
end

---------------------------------------------
-- Moving
---------------------------------------------


local cachedTable = {}
local cachedTableLength = 0
local cycleNumber = 999

local function moveSingleBee(biome, forDrone)
  for i=1,cachedTableLength do
    local t = cachedTable[i]
    if t then
      local slot, v, stack, ifDrone = table.unpack(t)
      if (ifDrone and forDrone) or (not ifDrone and not forDrone) then
        if forDrone or biome.comp(stack) then
          if biome.move(slot) then
            cachedTable[i] = nil
            addSpecieToPool(stack)
            print('<- moved', stack.label ,'to', biome.name, 'score:', v)
            return true
          end
        end
      end
    end
  end
end

local function moveToBiome(biome)
  local princessStack = biome.getPrincessStack()
  local princessMoved = (not princessStack and moveSingleBee(biome, false))

  local needDrone  = biome.isNeedDrone(princessMoved, princessStack)
  local droneMoved = (needDrone and moveSingleBee(biome, true ))
  return princessMoved or droneMoved
end

local function purgeDrones()
  local droneCount = 0
  for i=1,cachedTableLength do
    local t = cachedTable[i]
    if t then
      local slot, v, stack, ifDrone = table.unpack(t)
      if ifDrone then
          droneCount = droneCount + 1
        if droneCount > 20 and trashFnc(slot, 64) then
          cachedTable[i] = nil
          print(' X trashed', stack.label, 'score:', v)
        end
      end
    end
  end
end

local function cycle()
  -- Check where we need something
  for i, biome in pairs(biomes)do
    moveToBiome(biome)
  end

  -- Update cashed table
  cycleNumber = cycleNumber+1
  if cycleNumber > 5 then
    cachedTable, cachedTableLength = getSortedList()
    cycleNumber = 0
    purgeDrones()
  end
end

while true do
  cycle()
  io.write('.')
  os.sleep(0.1)
end