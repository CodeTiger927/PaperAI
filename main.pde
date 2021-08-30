int SIZE = 12;
int BS;

public double sigmoid(double x) {
  return 1.0 / (1.0 + Math.exp(-x));
}

public double relu(double x) {
  return Math.max(0,x);
}

public class Population {
  public int popSize = 2000;
  public float mutationRate = 0.05;
  public ArrayList<Double[]> pop = new ArrayList<Double[]>();
  public Double[] best = new Double[52 * 40 + 40 * 20 + 20 * 8];
  public double highestFitness = 0;
    void mutate(Double[] gene) {
    for(int i = 0;i < gene.length;++i) {
      if(random(1) < mutationRate) {
        gene[i] = Math.min(1,Math.max(-1,gene[i] + randomGaussian() / 5));
      }
    }
    return;
  }
  
  Double[] crossover(Double a[],Double b[]) {
    Double[] res = new Double[52 * 40 + 40 * 20 + 20 * 8];
    int l = (int)random(res.length);
    for(int i = 0;i < res.length;++i) {
      res[i] = i < l ? a[i] : b[i];
    }
    return res;
  }
  
  void randomize(Double[] gene) {
    for(int i = 0;i < gene.length;++i) {
      gene[i] = (double)random(1) * 2 - 1;
    }
  }
  
  void init() {
    for(int i = 0;i < popSize;++i) {
      pop.add(new Double[52 * 40 + 40 * 20 + 20 * 8]);
      randomize(pop.get(i));
    }
    best = pop.get(0).clone();
  }
  
  double match(int n,boolean tf) {
    Grid g = new Grid();
    Entity p1 = new Entity(g,tf ^ false,pop.get(n));
    Entity p2 = new Entity(g,tf ^ true,best);
    int maxTerms = 100;
    for(int i = 0;i < maxTerms;++i) {
      if(random(1) < 0.5) {
        p2.think();
        p1.think();
      }else{
        p1.think();
        p2.think();
      }
      
    }
    double res = 0;
    for(int i = 0;i < SIZE;++i) {
      for(int j = 0;j < SIZE;++j) {
        if(g.grid[i][j] == (tf ? 3 : 1)) {
          res += 0.1;
        }else if(g.grid[i][j] == (tf ? 4 : 2)) {
          res += 1;
        }
      }
    }
    return res + (g.lost[tf ? 0 : 1] ? 144 : 0);
  }
  
  // roulette selection
  int select(double sum,double threshold,ArrayList<Double> fitness) {
    for(int i = 0;i < popSize;++i) {
      double r = random((float)sum);
      double s = 0;
      for(int j = 0;j < popSize;++j) {
        if(fitness.get(j) < threshold) continue;
        s += fitness.get(j) - threshold + 0.1;
        if(s >= r) {
          return j;
        }
      }
    }
    return 0;  
  }
  void nextGen() {
    ArrayList<Double[]> newP = new ArrayList<Double[]>();
    ArrayList<Double> fitness = new ArrayList<Double>();
    float[] sorted = new float[popSize];
    double threshold = 0;
    double sum = 0;
    int rec = 0;
    double recV = -1;
    for(int i = 0;i < popSize;++i) {
      fitness.add(match(i,false) + match(i,true));
      sorted[i] = (float)(double)fitness.get(i);
      if(fitness.get(i) > recV) {
        rec = i;
        recV = fitness.get(i);
      }
    }
    sort(sorted);
    threshold = Math.max(0,sorted[(int)(popSize * 0.2)]);
    for(int i = 0;i < popSize;++i) sum += sorted[i] >= threshold ? sorted[i] - threshold + 0.1 : 0;
    best = pop.get(rec).clone();
    highestFitness = recV;
    for(int i = 0;i < popSize;++i) {
      newP.add(crossover(pop.get(select(sum,threshold,fitness)),pop.get(select(sum,threshold,fitness))));
      newP.add(pop.get((int)random(popSize)).clone());
      // println(sum);
      mutate(newP.get(i));
    }
    pop = newP;
  }
}

public class Entity {
  public Grid g;
  // tN = trail number
  // bN = body number
  // e.. = enemy ..
  public int x,y,tN,bN,etN,ebN;
  public boolean p;
  public int[] dx = new int[]{1,0,-1,0};
  public int[] dy = new int[]{0,-1,0,1};
  //8 directions
  //each direction has:
  //1. Distance to its own body
  //2. Distance to its own trail
  //3. Distance to enemy body
  //4. Distance to enemy head
  //5. Distance to enemy trail
  //6. Distance to wall
  //4 Memory nodes
  //52 -> 40 -> 20 -> 8
  public double[] input = new double[52];
  public double[] gene = new double[52 * 40 + 40 * 20 + 20 * 8];
  public double fitness = 0;
  
  public Entity() {}
  
  public Entity(Grid _g,boolean _p) {
    g = _g;
    p = _p;
    tN = (p ? 1 : 0) * 2 + 1;
    bN = (p ? 1 : 0) * 2 + 2;
    etN = (p ? 0 : 1) * 2 + 1;
    ebN = (p ? 0 : 1) * 2 + 2;
    g.x[p ? 1 : 0] = x = p ? SIZE - 1 : 0;
    g.y[p ? 1 : 0] = y = p ? SIZE - 1 : 0;
    g.grid[x][y] = bN;
    for(int i = 0;i < gene.length;++i) gene[i] = random(1) * 2 - 1;
  }
  
  public Entity(Grid _g,boolean _p,Double[] _gene) {
    g = _g;
    p = _p;
    tN = (p ? 1 : 0) * 2 + 1;
    bN = (p ? 1 : 0) * 2 + 2;
    etN = (p ? 0 : 1) * 2 + 1;
    ebN = (p ? 0 : 1) * 2 + 2;
    g.x[p ? 1 : 0] = x = p ? SIZE - 1 : 0;
    g.y[p ? 1 : 0] = y = p ? SIZE - 1 : 0;
    g.grid[x][y] = bN;
    for(int i = 0;i < gene.length;++i) gene[i] = _gene[i];
  }
  
  public void printGenes(int gen) {
    Table modelTable = new Table();
    modelTable.addColumn("weights");
    for(int i = 0;i < gene.length;++i) {
      TableRow newRow = modelTable.addRow();
      newRow.setDouble("weights",gene[i]);
    }
    saveTable(modelTable,"data/gen-" + gen + ".csv");
  }
  
  void think() {
    if(g.lost[p ? 1 : 0]) return;
    int t = 0;
    for(int i = -1;i <= 1;++i) {
      for(int j = -1;j <= 1;++j) {
        if(i == 0 && j == 0) continue;
        look(i,j,t);
        t += 6;
      }
    }
    double[] hidden1 = new double[40];
    t = 0;
    for(int i = 0;i < 40;++i) {
      for(int j = 0;j < 52;++j) {
        hidden1[i] += gene[t++] * input[j];
      }
      hidden1[i] = relu(hidden1[i]);
    }
    double[] hidden2 = new double[20];
    for(int i = 0;i < 20;++i) {
      for(int j = 0;j < 40;++j) {
        hidden2[i] += gene[t++] * hidden1[j];
      }
      hidden2[i] = relu(hidden2[i]);
    }
    double[] output = new double[8];
    for(int i = 0;i < 8;++i) {
      for(int j = 0;j < 20;++j) {
        output[i] += gene[t++] * hidden2[j];
      }
      output[i] = sigmoid(output[i]);
    }
    // Memory nodes
    input[48 + 0] = output[4];
    input[48 + 1] = output[5];
    input[48 + 2] = output[6];
    input[48 + 3] = output[7];
    int r = 0;
    for(int i = 0;i < 4;++i) {
      if(output[i] > output[r]) r = i;
    }
    move(r);
  }
  
  void win() {
    for(int i = 0;i < SIZE;++i) {
      for(int j = 0;j < SIZE;++j) {
        if(g.grid[i][j] == ebN || g.grid[i][j] == etN) {
          g.grid[i][j] = 0;
        }
      }
    }
    g.lost[p ? 0 : 1] = true;
  }
  
  void lose() {
    for(int i = 0;i < SIZE;++i) {
      for(int j = 0;j < SIZE;++j) {
        if(g.grid[i][j] == bN || g.grid[i][j] == tN) {
          g.grid[i][j] = 0;
        }
      }
    }
    g.lost[p ? 1 : 0] = true;
  }
  
  void look(int xd,int yd,int offset) {
    int nx = x + xd;
    int ny = y + yd;
    input[offset + 0] = 0;
    input[offset + 1] = 0;
    input[offset + 2] = 0;
    input[offset + 3] = 0;
    input[offset + 4] = 0;
    input[offset + 5] = 0;
    for(int t = 1;;++t,nx += xd,ny += yd) {
      if(nx < 0 || nx >= SIZE || ny < 0 || ny >= SIZE) {
        input[offset + 5] = 1.0 / t;
        break;
      }
      if(g.grid[nx][ny] == bN) {
        input[offset + 0] = 1.0 / t;
      }
      if(g.grid[nx][ny] == tN) {
        input[offset + 1] = 1.0 / t;
      }
      if(g.grid[nx][ny] == ebN) {
        input[offset + 2] = 1.0 / t;
      }
      if(g.grid[nx][ny] == etN) {
        input[offset + 3] = 1.0 / t;
      }
      if(nx == g.x[p ? 0 : 1] && ny == g.y[p ? 0 : 1]) {
        input[offset + 4] = 1.0 / t;
      }
    }
  }
  
  void fillUtility(int x,int y,boolean[][] b) {
    if(b[x][y]) return;
    ArrayList<PVector> pts = new ArrayList<PVector>();
    pts.add(new PVector(x,y));
    boolean valid = true;
    for(int i = 0;i < pts.size();++i) {
      for(int j = 0;j < 4;++j) {
        int nx = (int)pts.get(i).x + dx[j];
        int ny = (int)pts.get(i).y + dy[j];
        if(nx < 0 || nx >= SIZE || ny < 0 || ny >= SIZE) {
          valid = false;
          continue;
        }
        if(b[nx][ny] || g.grid[nx][ny] == tN || g.grid[nx][ny] == bN) continue;
        pts.add(new PVector(nx,ny));
        b[nx][ny] = true;
      }
    }
    for(int i = 0;i < pts.size();++i) {
      int cx = (int)pts.get(i).x;
      int cy = (int)pts.get(i).y;
      b[cx][cy] = true;
      if(valid) {
        g.grid[cx][cy] = bN;
      }
    }
  }
  
  void fill() {
    boolean[][] b = new boolean[SIZE][SIZE];
    for(int i = 0;i < SIZE;++i) {
      for(int j = 0;j < SIZE;++j) {
        if(g.grid[i][j] == 0) {
          fillUtility(i,j,b);
        }else if(g.grid[i][j] == tN) {
          g.grid[i][j] = bN;
        }
      }
    }
  }
  
  void move(int d) {
    if(g.lost[p ? 1 : 0]) return;
    int nx = x + dx[d];
    int ny = y + dy[d];
    if(nx < 0 || nx >= SIZE || ny < 0 || ny >= SIZE) return;
    if(g.grid[nx][ny] == tN) {
      //lose();
      return;
    }
    x = nx;
    y = ny;
    g.x[p ? 1 : 0] = x;
    g.y[p ? 1 : 0] = y;
    if(g.grid[nx][ny] == 0 || g.grid[nx][ny] == ebN) {
      g.grid[nx][ny] = tN;
    }else if(g.grid[nx][ny] == bN) {
      fill();
    }else if(g.grid[nx][ny] == etN) {
      g.grid[nx][ny] = tN;
      win();
    }
  }
}

public class Grid {
  public int[][] grid = new int[SIZE][SIZE];
  int[] x = new int[]{0,SIZE - 1};
  int[] y = new int[]{0,SIZE - 1};
  boolean[] lost = new boolean[]{false,false};
  void display() {
    for(int i = 0;i < SIZE;++i) {
      for(int j = 0;j < SIZE;++j) {
        noStroke();
        if(grid[i][j] == 0) {
          fill(135,206,235);
        }else if(grid[i][j] == 1) {
          // P1 Trail
          fill(144,238,144);
        }else if(grid[i][j] == 2) {
          // P1 Body
          fill(50,205,50);
        }else if(grid[i][j] == 3) {
          // P2 Trail
          fill(250,128,114);
        }else if(grid[i][j] == 4) {
          // P2 Body
          fill(220,20,60);
        }
        rect(i * BS,j * BS,BS,BS);
      }
    }
    strokeWeight(6);
    if(!lost[0]) {
      stroke(34,139,34);
      fill(50,205,50);
      rect(x[0] * BS,y[0] * BS,BS,BS);
    }
    if(!lost[1]) {
      stroke(139,0,0);
      fill(220,20,60);
      rect(x[1] * BS,y[1] * BS,BS,BS);
    }
  }
}

int mode = 1;
int t = 0;
int d = 2;
int generation = 0;
Entity p1,p2;
Grid g = new Grid();
Population p = new Population();

void loadData(String path) {
  Table table = loadTable(path,"header");
  int i = 0;
  Double[] data = new Double[52 * 40 + 40 * 20 + 20 * 8];
  for(TableRow row : table.rows()) {
    data[i++] = (double)row.getDouble("weights");
  }
  println(i + " " + data.length);
  p1 = new Entity(g,false);
  p2 = new Entity(g,true,data);
}

void setup() {
  size(1200,1200);
  BS = width / SIZE;
  p1 = new Entity(g,false);
  p2 = new Entity(g,true);
  p.init();
  frameRate(10);
  if(mode == 2) {
    // Player mode
    frameRate(2);
    loadData("./data/gen-1200.csv");
  }
}

void draw() {
  background(135,206,235);
  if(mode == 2) {
    if(keyPressed) {
      if(key == 'd') {
        d = 0;
      }else if(key == 'w') {
        d = 1;
      }else if(key == 'a') {
        d = 2;
      }else if(key == 's') {
        d = 3;
      }
    }
    g.display();
    if(random(1) < 0.5) {
      p1.move(d);
      p2.think();
    }else{
      p2.think();
      p1.move(d);
    }
  }else if(mode == 0 && generation % 50 == 0) {
    g.display();
    if(random(1) < 0.5) {
      p2.think();
      p1.think();
    }else{
      p1.think();
      p2.think();
    }
    if(t++ >= 100) {
      mode = 1;
      t = 0;
    }
  }else{
    p.nextGen();
    println("Generation " + (generation++) + ": " + p.highestFitness);
    mode = 0;
    g = new Grid();
    p1 = new Entity(g,false,p.best);
    p2 = new Entity(g,true,p.best);
    if(generation < 30 || generation % 10 == 0) p1.printGenes(generation);
  }
}

void keyPressed() {
  
}
