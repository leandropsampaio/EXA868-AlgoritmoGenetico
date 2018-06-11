local OrganismController = {}
local Json = require "util.Json"

function OrganismController:new(organismConstructor, initialPosition)

  local self = {
    organisms;
    numberOfGenomes;
    genomeSize;

    constructor = function (this, initialPosition)
      this.numberOfGenomes = 50
      this.organisms = {}
      this.genomeSize = 16

      for index = 1, this.numberOfGenomes, 1 do
        local organism = organismConstructor:new(this.genomeSize)
        organism.setPosition({x = initialPosition.x, y = initialPosition.y})
        table.insert(this.organisms, organism)
      end
    end
  }

  self.constructor(self, initialPosition)

  local crossover = function (MomOrganism, DadOrganism, mutationProbability)
    if(not (MomOrganism and DadOrganism and mutationProbability)) then
      return false
    end

    local firstRandom, secondRandom
    local children = {}
    for indexOfChildren = 1, self.genomeSize, 1 do
      local newChildren = organismConstructor:new(self.genomeSize)
      for index = 1, self.genomeSize, 1 do --parents code
        firstRandom = math.random()
        local selectedOrganism = nil
        if (firstRandom <= 0.5) then
          selectedOrganism = MomOrganism
        else
          selectedOrganism = DadOrganism
        end
        newChildren.setGenomeInIndex(index, selectedOrganism.getGenomeInIndex(index) + 0)
        secondRandom = math.random()
        if (secondRandom <= mutationProbability) then --mutations (mutationProbability)
          newChildren.setGenomeInIndex(index, math.random(0, 3))
        end

      end --for end
      newChildren.setGeneration(MomOrganism.getGeneration() + 1)
      table.insert(children, newChildren)
    end --end of children for
    MomOrganism.setGeneration(MomOrganism.getGeneration() + 1)
    table.insert(children, MomOrganism)
    DadOrganism.setGeneration(DadOrganism.getGeneration() + 1)
    table.insert(children, DadOrganism)

    MomOrganism.reset(); DadOrganism.reset()
    self.organisms = children
    return children
  end

  local selectBestOnes = function ()
    local maxScores = {[0] = 0, [1] = 0}
    local bestOrganisms = {[0] = self.organisms[1], [1] = self.organisms[2]}

    for index, value in ipairs(self.organisms) do
      if(value.getFitness() > maxScores[0]) then
        bestOrganisms[1] = bestOrganisms[0]
        maxScores[1] = maxScores[0]
        bestOrganisms[0] = value
        maxScores[0] = value.getFitness()
      elseif(value.getFitness() > maxScores[1]) then
        bestOrganisms[1] = value
        maxScores[1] = value.getFitness()
      end
    end

    return bestOrganisms[0], bestOrganisms[1]
  end

  local saveGenomes = function (filePath)
    local outFile = assert(io.open(filePath, "w"))
    outFile:write("{ \"Organisms\":[")
    for index, value in ipairs(self.organisms) do
      outFile:write("{\"Generation", "\": [", value.getGeneration(), "],")
      outFile:write("\"Genome", "\": [")

      genomeSize = #value.getGenome()
      for genomeIndex, genomeValue in ipairs(value.getGenome()) do
        if(genomeIndex < genomeSize) then
          outFile:write(genomeValue, ",")
        else
          outFile:write(genomeValue, "]")
        end
      end
      if(index < #self.organisms) then
        outFile:write("},")
      else
        outFile:write("}")
      end
    end
    outFile:write("]}")
    assert(outFile:close())
  end

  local loadGenomes = function (filePath)
    local file = io.open(filePath,'r')
    local organisms = Json.decode(file:read("*all"))
  end

  local getOrganisms = function()
    return self.organisms
  end

  return {
    crossover = crossover;
    selectBestOnes = selectBestOnes;
    saveGenomes = saveGenomes;
    loadGenomes = loadGenomes;
    getOrganisms = getOrganisms;
  }
end

return OrganismController
