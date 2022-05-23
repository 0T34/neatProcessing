import java.util.Map;

Population pop;

void setup(){
  pop = new Population(100, 3, 1);
}

void draw(){
  Genome winnergenome = new Genome();
  for(Genome g : pop.gens){
    if(g.fitness > winnergenome.fitness){
      winnergenome = g;
    }
  }

  float sum = 0.0f;
  for(ConnectionGene con : winnergenome.connections){
    sum += abs(con.weight);
  }

  println("Generation: " + pop.generation +
          " | Species: " + pop.species.size() +
          " | Fitness: " + winnergenome.fitness +
          " | Sum: " + sum);

  if (winnergenome.fitness >= 4000) {
    int expressedconnections = 0;
    for (int i = 0; i < winnergenome.connections.size(); i++) {
      if (winnergenome.connections.get(i).expressed == true) {
        expressedconnections++;
      }
    }
    
    println("Done." + 
            "\n+ Total generations: " + pop.generation +
            "\n+ Total connections: " + winnergenome.connections.size() +
            "\n+ Total EXPRESSED conenctions: " + expressedconnections +
            "\n+ Total nodes: " + winnergenome.nodes.size() + 
            "\n+ Fitness: " + winnergenome.fitness);

    exit();
  }

  pop.naturalSelection();
}
