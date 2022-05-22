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

  pop.naturalSelection();
}
