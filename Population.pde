import java.util.Map;

class Population{
  ArrayList<Genome> gens;
  ArrayList<Genome> newGens = new ArrayList();
  ArrayList<Specie> species;
  Map<Genome, Specie> speciesMap = new HashMap();
  int size;
  int generation = 0;
  int lastInput;
  int lastOutput;
  
  Population(int size, Genome firstOne, int lastInput, int lastOutput){
    gens = new ArrayList();
    this.size = size;
    this.lastInput = lastInput;
    this.lastOutput = lastOutput;
    
    createFirstPopulation(firstOne);
  }
  
  Population(ArrayList<Genome> gens, int size, int lastInput, int lastOutput){
    this.gens = gens;
    this.size = size;
    this.lastInput = lastInput;
    this.lastOutput = lastOutput;
  }
  
  void sortSpecies(){
    
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
    
    //best on new gen
    for(Specie s : species){
      Genome best = new Genome();
      for(Genome gen : s.members){
        if(gen.fitness > best.fitness){
          best = gen.cpy();
        }
      }
      newGens.add(best);
    }
    
    while(newGens.size() < size){
      //select specie
      Specie s = selectSpecie();
      
      //select parents
      Genome parent1 = selectParent(s);
      Genome parent2 = selectParent(s);
      
      //create new
      Genome child = crossover(parent1, parent2);
      
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
    
  }
  
  Genome selectParent(Specie s){
  
  }
  
  Genome crossover(Genome p1, Genome p2){
    int maxInnP1 = 0;
    int maxInnP2 = 0;
    Genome child = new Genome();
    for(ConnectionGene con : p1.connections){
      if(con.innovation > maxInnP1)
        maxInnP1 = con.innovation;
    }
    for(ConnectionGene con : p2.connections){
      if(con.innovation > maxInnP2)
        maxInnP2 = con.innovation;
    }
    if(maxInnP1 >= maxInnP2){
      for(ConnectionGene con1 : p1.connections){
        boolean found = false;
        for(ConnectionGene con2 : p2.connections){
          if(con1.innovation == con2.innovation){
            found = true;
            if(random(1)<=0.5){
              child.connections.add(con1.cpy());
            } else {
              child.connections.add(con2.cpy());
            }
          }
        }
        if(!found){
          if(p1.fitness >= p2.fitness){
            child.connections.add(con1.cpy());
          }
        }
      }
    } else {
      for(ConnectionGene con2 : p2.connections){
        boolean found = false;
        for(ConnectionGene con1 : p1.connections){
          if(con1.innovation == con2.innovation){
            found = true;
            if(random(1)<=0.5){
              child.connections.add(con1.cpy());
            } else {
              child.connections.add(con2.cpy());
            }
          }
        }
        if(!found){
          if(p2.fitness >= p1.fitness){
            child.connections.add(con2.cpy());
          }
        }
      }
    }
    ArrayList<NodeGene> newNodes = new ArrayList();
    if(p1.fitness >= p2.fitness){
      for(NodeGene ng : p1.nodes){
        newNodes.add(ng.cpy());
      }
    } else {
      for(NodeGene ng : p2.nodes){
        newNodes.add(ng.cpy());
      }
    }
    child.nodes = newNodes;
    
    return child;
  }
  
  void mutate(Genome child){
    float mutateWeightRate = 0.5;
    float addConnectionRate = 0.1;
    float addNodeRate = 0.1;
    float r = random(0, 1);
    float r2 = random(0, 1);
    if(generation==0){
      mutateWeightRate = 0;
      addConnectionRate = 0.5;
      addNodeRate = 0.25;
    }
    
    if(r<=mutateWeightRate){
      ConnectionGene connection = child.connections.get(int(random((float)child.connections.size()-1)));
      
      float r3 = random(0, 1);
      if(r3 <= 0.8){
        connection.weight = connection.weight*random(-2, 2);
      } else {
        connection.weight = random(-2, 2);
      }
    }
    
    if(r<=addConnectionRate){
      boolean mutated = false;
      int maximumTries = 10;
      do{
        maximumTries--;
        int node = ceil(random((float)child.nodes.size()));
        if(node <= lastInput || node > lastOutput){
          int node2 = ceil(random(lastInput, (float)child.nodes.size()));
          boolean alreadyExists = false;
          boolean possible = true;
          for(ConnectionGene con : child.connections){
            if(con.inNode == node && con.outNode == node2){
              alreadyExists = true;
            }
            if(con.outNode == node && con.inNode == node2){
              possible = false;
            }
          }
          
          if(!alreadyExists && possible){
            //create new connection
            int inNum = 0;
            boolean found = false;
            for(ConnectionGene con : Mutations.getInnovations()){
              if(con.inNode == node && con.outNode == node2){
                inNum = con.innovation;
                found = true;
                break;
              }
            }
            if(!found){
              ConnectionGene innCon = new ConnectionGene(node, node2, InnovationGenerator.getInnovation());
              Mutations.addInnovations(innCon);
              inNum = innCon.innovation;
            }
            
            child.connections.add(new ConnectionGene(node, node2, random(-2, 2), true, inNum));
            mutated = true;
          }
        }
      } while(!mutated && maximumTries > 0);
    }
    
    if(r2<=addNodeRate){
      ConnectionGene connection = child.connections.get(floor(random(0, child.connections.size()-0.1)));
      println(connection.innovation);
      
      NodeGene newNode = new NodeGene(2, child.nodes.size()+1);
      child.nodes.add(newNode);
      
      int in1 = 0;
      int in2 = 0;
      boolean found1 = false;
      boolean found2 = false;
      for(ConnectionGene con : Mutations.getInnovations()){
        if(con.inNode == connection.inNode && con.outNode == newNode.id){
          in1 = con.innovation;
          found1 = true;
        }
        if(con.inNode == newNode.id && con.outNode == connection.outNode){
          in2 = con.innovation;
          found2 = true;
        }
      }
      if(!found1){
        ConnectionGene innCon = new ConnectionGene(connection.inNode, newNode.id, InnovationGenerator.getInnovation());
        Mutations.addInnovations(innCon);
        in1 = innCon.innovation;
      }
      if(!found2){
        ConnectionGene innCon = new ConnectionGene(newNode.id, connection.outNode, InnovationGenerator.getInnovation());
        Mutations.addInnovations(innCon);
        in2 = innCon.innovation;
      }      
      
      ConnectionGene newCon1 = new ConnectionGene(connection.inNode, newNode.id, 1f, true, in1);
      ConnectionGene newCon2 = new ConnectionGene(newNode.id, connection.outNode, connection.weight, true, in2);
      
      child.connections.add(newCon1);
      child.connections.add(newCon2);
      connection.expressed = false;
    }
    
  }
  
  void createFirstPopulation(Genome gen){
    while(gens.size() < size){
      Genome child = gen.cpy();
      
      mutate(child);
      
      gens.add(child);
    }
    
    //sortSpecies();
    generation++;
  }
}

class Specie{
  Genome mascot;
  ArrayList<Genome> members;
  float totalFitness = 0;
  
  Specie(Genome mascot, ArrayList<Genome> members){
    this.mascot = mascot;
    this.members = members;
  }
  
  void addFitness(float fitness){
    totalFitness += fitness;
  }
  
  void reset(){
    mascot = members.get(floor(random(members.size())));
    members = new ArrayList();
    totalFitness = 0;
  }
}

static class Fitness{
  
  static float calculate(Genome gen){
    float weightSum=0;

    for(ConnectionGene con : gen.connections){
      weightSum += abs(con.weight);
    }
      
    float difference = abs(weightSum - 100);
    
    return 1000f/difference;
  }
  
}

static class Mutations{
  static ArrayList<ConnectionGene> innovations = new ArrayList();
  
  static ArrayList<ConnectionGene> getInnovations(){
    return innovations;
  }
  
  static void addInnovations(ConnectionGene newInnovation){
    innovations.add(newInnovation);
  } 
}