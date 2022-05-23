import java.util.Map;

class Population{
  ArrayList<Genome> gens;
  ArrayList<Genome> newGens = new ArrayList();
  ArrayList<Specie> species = new ArrayList();
  Map<Genome, Specie> speciesMap = new HashMap();
  int size;
  int inputcount;
  int generation = 0;
  
  Population(int size, int inputs, int outputs){
    gens = new ArrayList();
    this.size = size;
    
    this.inputcount = inputs;
    Genome firstOne = new Genome(inputs, outputs);
    createFirstPopulation(firstOne);
  }

  void sortSpecies(){
    speciesMap = new HashMap();
    for(Specie s : species){
      s.reset();
    }
    
    float c1 = 1;
    float c2 = 1;
    float c3 = 0.5;
    float dt = 3;
    
    for(Genome g : gens){
      boolean found = false;
      float n = 1;
      for(Specie s : species){
        if(s.mascot.nodes.size() >= 20 || g.nodes.size() >= 20){
          if(s.mascot.nodes.size() > g.nodes.size())
            n = s.mascot.nodes.size();
          else
            n = g.nodes.size();
        }
        float excessCount = g.calculateExcess(s.mascot);
        float disjointCount = g.calculateDisjoints(s.mascot);
        float weightDifference = g.calculateWeightDifference(s.mascot);
        float value = (c1*excessCount)/n + (c2*disjointCount)/n + c3*weightDifference;
        if(value <= dt){
          found = true;
          s.members.add(g);
          speciesMap.put(g, s);
          break;
        }
      }
      if(!found){
        Specie newSpecie = new Specie(g);
        species.add(newSpecie);
        speciesMap.put(g, newSpecie);
      }
    }
    
    ArrayList<Specie> removedSpecies = new ArrayList();
    for(Specie s : species){
      if(s.members.size() == 0){
        removedSpecies.add(s);
      }
    }
    if(removedSpecies.size() > 0)
      species.removeAll(removedSpecies);
  }
  
  void naturalSelection(){
    //create first population on pop constructor
    //sort species after create the population, reset species everytime you will create a population, when creating new species set the genome as mascot
    //reset and sort species after the mutation in this method
    
    for(Genome gen : gens){
      gen.fitness = Fitness.calculate(gen) / (float)((Specie)speciesMap.get(gen)).members.size();
      speciesMap.get(gen).addFitness(gen.fitness);
    }
    
    newGens = new ArrayList();
    
    //highest fitness only on the next gen
    Genome best = new Genome();
    for(Genome gen : gens){
      if(gen.fitness > best.fitness){
        best = gen.cpy();
      }
    }
    newGens.add(best);
    
    while(newGens.size() < size){
      //select specie
      Genome child;
      Specie s = selectSpecie();
      
      //select parents
      Genome parent1 = selectParent(s);
      Genome parent2 = selectParent(s);
      
      //create new
      child = crossover(parent1, parent2);
    
      //mutate ps: on mutation check if innovation number has to be incremented
      mutate(child);
      
      //add to next gen
      newGens.add(child);
    }
    
    gens = newGens;
    newGens = new ArrayList();
    
    //sort new generation species
    sortSpecies();
    generation++;
  }
  
  Specie selectSpecie(){
    float fitnessSum = 0f;
    for(Specie s : species){
      fitnessSum += s.totalFitness;
    }
    
    if(fitnessSum > 0){
      float select = random(0, fitnessSum);
      float sum = 0;
      for(Specie s : species){
        sum += s.totalFitness;
        if(select <= sum){
          return s;
        }
      }
    }
    
    throw new Error("Nenhuma espécie encontrada");
  }
  
  Genome selectParent(Specie s){
    float fitnessSum = 0f;
    for(Genome gen : s.members){
      fitnessSum += gen.fitness;
    }
    
    if(fitnessSum > 0){
      float select = random(0, fitnessSum);
      float sum = 0;
      for(Genome gen : s.members){
        sum += gen.fitness;
        if(select <= sum){
          return gen;
        }
      }
    }
    
    throw new Error("Nenhum indivíduo encontrado na espécie");
  }
  
  Genome crossover(Genome p1, Genome p2){
    ArrayList<ConnectionGene> newConnections = new ArrayList();
    ArrayList<NodeGene> newNodes = new ArrayList();
    
    //passar matching genes
    for(ConnectionGene con1 : p1.connections){
      for(ConnectionGene con2 : p2.connections){
        if(con1.innovation == con2.innovation){
          if(random(0, 1) <= 0.5){
            newConnections.add(con1.cpy());
          } else {
            newConnections.add(con2.cpy());
          }
        }
      }
    }
    
    //passar excesso, disjoint e nodes do maior fitness
    if(p1.fitness > p2.fitness){
      for(ConnectionGene con1 : p1.connections){
        boolean found = false;
        for(ConnectionGene con2 : newConnections){
          if(con1.innovation == con2.innovation){
            found = true;
          }
        }
        if(!found){
          newConnections.add(con1.cpy());
        }
      }
      
      for(NodeGene ng : p1.nodes){
        newNodes.add(ng.cpy());
      }
      
      return new Genome(newConnections, newNodes);
    } else if(p2.fitness > p1.fitness){
      for(ConnectionGene con1 : p2.connections){
        boolean found = false;
        for(ConnectionGene con2 : newConnections){
          if(con1.innovation == con2.innovation){
            found = true;
          }
        }
        if(!found){
          newConnections.add(con1.cpy());
        }
      }
      
      for(NodeGene ng : p2.nodes){
        newNodes.add(ng.cpy());
      }
      
      return new Genome(newConnections, newNodes);
    } else {
      //caso igual passar excesso, disjoint dos dois e node do maior
      for(ConnectionGene con1 : p1.connections){
        boolean found = false;
        for(ConnectionGene con2 : newConnections){
          if(con1.innovation == con2.innovation){
            found = true;
          }
        }
        if(!found){
          newConnections.add(con1.cpy());
        }
      }
      
      for(ConnectionGene con1 : p2.connections){
        boolean found = false;
        for(ConnectionGene con2 : newConnections){
          if(con1.innovation == con2.innovation){
            found = true;
          }
        }
        if(!found){
          newConnections.add(con1.cpy());
        }
      }
      
      if(p1.nodes.size() > p2.nodes.size()){
        for(NodeGene ng : p1.nodes){
          newNodes.add(ng.cpy());
        }
      } else {
        for(NodeGene ng : p2.nodes){
          newNodes.add(ng.cpy());
        }
      }    
    }
    
    return new Genome(newConnections, newNodes);
  }
  
  void mutate(Genome child){
    //println("mutate call");
    int maxMutationAttempts = 5;
    float mutateWeightRate = 0.5;
    float addConnectionRate = 0.1;
    float addNodeRate = 0.1;
  
    child.addConnectionMutation(this.inputcount, addConnectionRate, maxMutationAttempts);
    child.weightMutation(mutateWeightRate);
    child.addNodeMutation(addNodeRate);
  }
  
  void createFirstPopulation(Genome gen){
    gens.add(gen);
    
    while(gens.size() < size){
      Genome child = gen.cpy();
      
      mutate(child);
      
      gens.add(child);
    }
    
    sortSpecies();
    generation++;
  }
}
