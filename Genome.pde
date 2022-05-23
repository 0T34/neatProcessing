import java.util.ArrayList;
import java.util.Map;

class Genome{
  ArrayList<ConnectionGene> connections = new ArrayList();
  ArrayList<NodeGene> nodes = new ArrayList();
  float fitness = 0;
  
  Genome(){}

  Genome(int inputs, int outputs){
    for (int i = 1; i < inputs + 1; i++) {
      this.nodes.add(new NodeGene(1, i));
    }

    for (int i = inputs + 1; i < inputs + outputs + 1; i++) {
      this.nodes.add(new NodeGene(3, i));
    }
  }
  
  Genome(ArrayList<ConnectionGene> connections, ArrayList<NodeGene> nodes){
    this.connections = connections;
    this.nodes = nodes;
  }
  
  Genome cpy(){
    ArrayList<ConnectionGene> connectionsClone = new ArrayList();
    for(ConnectionGene con : connections){
      connectionsClone.add(con.cpy());
    }
    ArrayList<NodeGene> nodesClone = new ArrayList();
    for(NodeGene node : nodes){
      nodesClone.add(node.cpy());
    }
    Genome newGen = new Genome(connectionsClone, nodesClone);
    //Genome newGen = new Genome(connections, nodes); //testar multiplas mutações no mesmo genoma
    newGen.fitness = fitness;
    return newGen;
  }
  
  void weightMutation(float mutateWeightRate){
    if (this.connections.size() == 0) {
      return;
    }

    if(random(0, 1) <= mutateWeightRate){
      for (ConnectionGene connection : this.connections) {
        if(random(0, 1) <= 0.9){
          connection.weight += randomGaussian() / 5;
          if (connection.weight > 2){
            connection.weight = 2;
          }else if (connection.weight < -2){
            connection.weight = -2;
          }
        } else {
          connection.weight = random(-2, 2);
        }
      }
    }
  }

  void addConnectionMutation(int inputcount, float addConnectionRate, int maxmutationattempts){
    if(random(0,1) <= addConnectionRate || this.connections.size() == 0) {
      boolean mutated = false;
      do{
        maxmutationattempts--;
        NodeGene node_in = this.nodes.get(int(random(0, this.nodes.size())));
        NodeGene node_out = this.nodes.get(int(random(inputcount, this.nodes.size())));      
        if(node_in.id != node_out.id && node_in.type != 3 && node_out.type != 1){
          boolean alreadyExists = false;
          boolean possible = true;
          if(node_in.type == 2 && node_out.type == 2){
            if(node_in.layer >= node_out.layer){
              possible = false;
            }
          }

          if(possible){
            for(ConnectionGene con : this.connections){
              if(con.inNode == node_in.id && con.outNode == node_out.id){
                alreadyExists = true;
              }
            }

            if(!alreadyExists){
              //create new connection
              int inNum = 0;
              boolean found = false;
              for(ConnectionGene con : Mutations.getInnovations()){
                if(con.inNode == node_in.id && con.outNode == node_out.id){
                  inNum = con.innovation;
                  found = true;
                  break;
                }
              }
              if(!found){
                ConnectionGene innCon = new ConnectionGene(node_in.id, node_out.id, InnovationGenerator.getInnovation());
                Mutations.addInnovations(innCon);
                inNum = innCon.innovation;
              }
                  
              this.connections.add(new ConnectionGene(node_in.id, node_out.id, random(-2, 2), true, inNum));
              mutated = true;
            }
          }
        }
      } while(!mutated && maxmutationattempts > 0);
    }
  }

  void addNodeMutation(float addNodeRate){
    if (this.connections.size() == 0) {
      return;
    }

    if(random(0, 1) <= addNodeRate){
      ConnectionGene connection = this.connections.get(int(random(0, this.connections.size()-1)));

      NodeGene newNode = new NodeGene(2, this.nodes.size()+1);
      this.nodes.add(newNode);
        
      NodeGene originalIn = new NodeGene();
      NodeGene originalOut = new NodeGene();
        
      for(NodeGene ng : this.nodes){
        if(ng.id == connection.inNode){
          originalIn = ng;
        }
        if(ng.id == connection.outNode){
          originalOut = ng;
        }
      }
        
      if(originalIn.type == 1 && originalOut.type == 3){
        newNode.layer = 1;
      } else if(originalIn.type == 2 && originalOut.type == 3){
        newNode.layer = originalIn.layer+1;
      } else if(originalIn.type == 1 && originalOut.type == 2){
        //caso originalOut for layer 1
        if(originalOut.layer == 1){
          //aumentar 1 numero em todas as hidden layers
          for(NodeGene ng : this.nodes){
            if(ng.layer > 0){
              ng.layer += 1;
            }
          }
        }
          
        //setar novo nodo como layer 1
        newNode.layer = 1;
      } else if(originalIn.type == 2 && originalOut.type == 2){
        //caso a layer do originalOut for layer do originalIn + 1
        if(originalOut.layer == originalIn.layer+1){
          //aumentar 1 numero na layer do originalOut e de todos os nodos da mesma layer
          for(NodeGene ng : this.nodes){
            if(ng.layer >= originalOut.layer){
              ng.layer += 1;
            }
          }
        }
        
        //setar novo nodo como layer originalIn + 1
        newNode.layer = originalIn.layer+1;
      }
        
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
        
      this.connections.add(newCon1);
      this.connections.add(newCon2);
      connection.expressed = false;
    }
  }

  float calculateExcess(Genome gen){
    int max1 = 0;
    int max2 = 0;
    
    for(ConnectionGene cg : connections){
      if(cg.innovation > max1){
        max1 = cg.innovation;
      }
    }
    for(ConnectionGene cg : gen.connections){
      if(cg.innovation > max2){
        max2 = cg.innovation;
      }
    }
    
    if(max1 > max2){
      return max1 - max2;
    } else {
      return max2 - max1;
    }
  }
  
  float calculateDisjoints(Genome gen){
    int max1 = 0;
    int max2 = 0;
    
    for(ConnectionGene cg : connections){
      if(cg.innovation > max1){
        max1 = cg.innovation;
      }
    }
    for(ConnectionGene cg : gen.connections){
      if(cg.innovation > max2){
        max2 = cg.innovation;
      }
    }
    
    Map<Integer, ConnectionGene> map1 = new HashMap();
    Map<Integer, ConnectionGene> map2 = new HashMap();
    
    for(ConnectionGene cg : connections){
      map1.put(cg.innovation, cg);
    }
    for(ConnectionGene cg : gen.connections){
      map2.put(cg.innovation, cg);
    }
    
    float disjoints = 0;    
    float max=0;
    if(max1 > max2){
      max = max1;
    } else {
      max = max2;
    }
    for(int i=1; i<max; i++){
      if(map1.get(i) != null && map2.get(i) == null && max2 > i){
        disjoints++;
      } else if(map1.get(i) == null && map2.get(i) != null && max1 > i){
        disjoints++;
      }
    }
    
    return disjoints;
  }
  
  float calculateWeightDifference(Genome gen){
    float weightSum = 0;
    float weightCount = 0;
    for(ConnectionGene cg1 : connections){
      for(ConnectionGene cg2 : gen.connections){
        if(cg1.innovation == cg2.innovation){
          weightSum += abs(cg1.weight - cg2.weight);
          weightCount++;
          break;
        }
      }
    }
    
    return weightSum / weightCount;
  }
}
