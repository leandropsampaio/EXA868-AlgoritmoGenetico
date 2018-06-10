local Finder = require "models.value.Finder"
local OrganismController = require "models.business.OrganismController"
local Labyrinth = require "models.value.Labyrinth"

local MainController = {}

function MainController:new()
  local self = {
    controllerOrganism;
    labyrinth;

    constructor = function (this)
      this.controllerOrganism = OrganismController:new(Finder)
      this.labyrinth = Labyrinth:new("config.json")
      this.labyrinth.loadLabyrinth("labyrinth.la")
    end
  }

  self.constructor(self)

  local calculateFitness = function (organism)
    local xDiference = organism.getX()
    xDiference = xDiference - self.objectiveCoordinates.x

    local yDiference = organism.getY()
    yDiference = yDiference - self.objectiveCoordinates.y

    return (math.sqrt(math.pow(xDiference, 2) + math.pow(yDiference, 2)))

  end

  local move = function(organisms)
    for index, organism in ipairs(organisms) do
      
    end
  end

  local execute = function ()
    local organisms = self.controllerOrganism.getOrganisms()
    if not organisms then
      return nil
    end

    move(organisms)

    local mom, dad = self.controllerOrganism.selectBestOnes()
    self.controllerOrganism.crossover(mom, dad, 0.02)
    
    for index, value in ipairs(self.controllerOrganism.getOrganisms()) do
      value.setPosition(self.labyrinth.getBeginPosition())
      print(value.getPosition().x, value.getPosition().y)
    end

    if(mom.getGeneration() % 11 == 0) then
      self.controllerOrganism.saveGenomes("LastsGenomes.json")
    end

  end

  return {
    execute = execute;
  }

end

return MainController
