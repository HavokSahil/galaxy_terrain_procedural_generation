// 0 - Undefined
// 1 - Space
// 2 - Galaxy Edge
// 3 - Galaxy Mid
// 4 - Galaxy Core

int win_dim = 720;
int cell_size = 5;
int world_height, world_width;
int map[][];
int types = 8;
int range_neib = 1;

// Expanded shades (8 total)
// Use different shades to reflect depth, light, or structure
int shades1[] = {
  #ff0000, // [0] - Undefined (Red - error/default marker)
  #000000, // [1] - Deep Space
  #1a1a2e, // [2] - Dark Space tint
  #3d194e, // [3] - Galaxy Edge (purple/dark violet)
  #5d3f6a, // [4] - Mid Edge
  #916ab0, // [5] - Mid Galaxy (lavender)
  #bcb6ec, // [6] - Inner Core
  #f5e6ff  // [7] - Bright Core Glow (whitish purple)
};

int shade2[] = {
  #8b0000, // [0] - Undefined (Dark Blood Red - error/default marker)
  #000000, // [1] - Deep Space (Void Black)
  #1a1a1a, // [2] - Dull Black (subtle void depth)
  #301934, // [3] - Outer Mist (Deep Purple Smoke)
  #4b2840, // [4] - Ethereal Edge (Twilight Mauve)
  #5f0f40, // [5] - Haunted Core (Dark Crimson Magenta)
  #9a1750, // [6] - Whispering Core (Blood Orchid)
  #d8b4f8  // [7] - Eldritch Glow (Pale Lilac Light)
};

int shades[] = {
  #b0c4de, // [0] - Undefined (Light Steel Blue - non-intrusive default marker)
  #0b0c10, // [1] - Deep Space (Very Dark Navy)
  #1f2a44, // [2] - Outer Space (Deep Midnight Blue)
  #3c4f76, // [3] - Galaxy Edge (Dusty Blue)
  #6d8fad, // [4] - Transition Mid (Sky Mist Blue)
  #9ebacb, // [5] - Mid Galaxy (Soft Ocean Blue)
  #d6eaf8, // [6] - Inner Core (Pale Ice Blue)
  #f4f9fd  // [7] - Core Glow (White Mist / Cloudy Glow)
};



float alpha = 0.2;
float beta = 1000;
float A = 0.3;
float lambda = 4.4;
float normalization_factor;

int notAllowed[][] = {
  //  0  1  2  3  4  5  6  7
  { 0, 0, 0, 0, 0, 0, 0, 0 },  // 0 - Undefined
  { 0, 0, 0, 1, 1, 1, 1, 1 },  // 1 - Deep Space
  { 0, 0, 0, 0, 1, 1, 1, 1 },  // 2 - Outer Space
  { 0, 1, 0, 0, 0, 1, 1, 1 },  // 3 - Galaxy Edge
  { 0, 1, 1, 0, 0, 0, 1, 1 },  // 4 - Transition Mid
  { 0, 1, 1, 1, 0, 0, 0, 1 },  // 5 - Galaxy Mid
  { 0, 1, 1, 1, 1, 0, 0, 0 },  // 6 - Inner Core
  { 0, 1, 1, 1, 1, 1, 0, 0 }   // 7 - Core Glow
};


int thresCore = -50;
int thresMid = 50;
int thresEdge = 100;
int thresSpace = 200;

void setup() {
  size(720, 720);
  world_height = win_dim / cell_size;
  world_width  = win_dim  / cell_size;
  normalization_factor = 100 / (sqrt(alpha*alpha + beta*beta) * world_height * sqrt(2));
  map = new int [world_width][world_height];
  for (int y = 0; y < world_height; y++) {
    for (int x = 0; x < world_width; x++) {
      int y_cen = world_height/2 - y;
      int x_cen = x - world_width / 2;
      if (abs(x_cen - y_cen) < 4) {
        map[x][y] = 7;
      } else map[x][y] = thresholdScore(x, y)? 1: 0;
    }
  }
  noStroke();
}

void draw() {
  for (int y = 0; y < world_height; y++) {
    for (int x = 0; x < world_width; x++) {
      fill(shades[map[x][y]]);
      rect(x*cell_size, y*cell_size, cell_size, cell_size);
    }
  }
  leastConflicts();
}

boolean thresholdScore(int x, int y) {
  int x_cen = -x + (world_width / 2);
  int y_cen = -y + (world_height / 2);
  int norm = int(dist(0, 0, x_cen, y_cen));
  float angle = atan2(y_cen, x_cen) - PI/4;
  
  float hor_sep = abs(norm * sin(angle))/(world_width / sqrt(2));
  float ver_sep = abs(norm * cos(angle))/(world_height/sqrt(2));
  float boundary = A * exp( - lambda * hor_sep * hor_sep);

  float seperation;
  if (ver_sep > 0) {
    seperation = ver_sep - boundary;
  } else {
    seperation = -ver_sep - boundary;
  }
  
  int score = int(alpha * norm + beta * seperation);
  return score > thresEdge;
}

int computeScoreViolation(int x, int y) {
  int t_x, t_y;
  int count = 0;
  for (int dx = -range_neib; dx < range_neib+1; dx++) {
    for (int dy = -range_neib; dy < range_neib+1; dy++) {
      t_x = (x + dx);
      t_y = (y + dy);
      if ((0 <= t_x) && (t_x < world_width) && (0 <= t_y) && (t_y < world_height))
        count += notAllowed[map[x][y]][map[t_x][t_y]];
    }
  }
  return count;
}

boolean leastConflicts() {
  int conflicts, x, y;
  int tries = 20;
  for (int i = 0; i < world_width * world_height; i++) {
    x = int(random(world_width));
    y = int(random(world_height));
    conflicts = computeScoreViolation(x, y);
    if (conflicts > 0 || map[x][y] == 0) {
      int bestType = 0;
      int leastConflicts = 100;
      int tempT, tempC;
      for (int j = 0; j < tries; j++) {
        tempT = 1 + int(random(types - 1));
        map[x][y] = tempT;
        tempC = computeScoreViolation(x, y);
        if (tempC < leastConflicts) {
          bestType = tempT;
          leastConflicts = tempC;
        }
      }
      map[x][y] = bestType;
    }
  }
  return true;
}
