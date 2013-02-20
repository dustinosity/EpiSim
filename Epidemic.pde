import controlP5.*;

int population_size = 500;

int init_infected = 1;
int infectionRate = 25;
float infection_rate = map(infectionRate, 0, 100, 0.004, 0.13);
int mass = 10;
int duration = 5;
int opacity = 125;
int totalcount = init_infected;
int thecount;
int radius = 7;
int day = 1;
int time = 0;
int day_length = 24;
boolean start_state, end_state;
int graph_type = 0 ; // 1 = stacked, 2 = meters, 3 = line
PFont font_big, font_small, font_tiny;
RadioButton r;
RadioButton checkbox;
Button reset;
Slider d, rad;
int[] prev;
int[] now;
boolean playPause = false; // true = play, false = pause
void play() { playPause = !playPause; } // toggle
float barrier_state = 0.0;
PGraphics graph_overlay;

Population population;
ControlP5 controlP5;

void setup() {
  frameRate(15);
  size(800, 600);
  smooth();
  controlP5 = new ControlP5(this);
  reset = controlP5.addButton("reset",0,50,10, 40 ,15);
  reset.setLabel("restart");
  controlP5.addButton("play", 0,10,10,30,15);
  controlP5.addButton("save", 0,100,10,30,15);
  // add horizontal sliders
  controlP5.addSlider("infectionRate", 0,  100,   25,    10,  55,   100,  10);
  controlP5.controller("infectionRate").setLabel("Infectivity (chance per day of contatct)");
  //controlP5.addSlider("populationSize",0,  1000,  500,   10,  55,   100,  10);
  rad = controlP5.addSlider("radius",        3,  10,    7,     10,  70,   100,  10);
  rad.setNumberOfTickMarks(8);
  rad.showTickMarks(false);
  controlP5.controller("radius").setLabel("Population Denisty");
  d = controlP5.addSlider("duration",      1,  10,   5,   10,  85,   100,  10);
  d.setNumberOfTickMarks(10);
  d.showTickMarks(false);
  controlP5.controller("duration").setLabel("Infectious Period (in days)");
  r = controlP5.addRadioButton("Graph Mode",10,100);
  r.setItemsPerRow(5);
  r.setSpacingColumn(50);
  addToRadioButton(r,"line",3);
  addToRadioButton(r,"bar",2);
  addToRadioButton(r,"stacked",1);
  checkbox = controlP5.addRadioButton("homogeneous",10,40);
  checkbox.addItem("barrier", 1.0);
  font_big = loadFont("HelveticaNeue-48.vlw"); 
  font_small = loadFont("inconsolata-24.vlw"); 
  font_tiny = loadFont("inconsolata-12.vlw"); 
  fill(204, 204, 204, opacity);
  reset();
}

void addToRadioButton(RadioButton theRadioButton, String theName, int theValue ) {
  Toggle t = theRadioButton.addItem(theName,theValue);
  t.captionLabel().setColorBackground(color(80));
  t.captionLabel().style().movePadding(2,0,-1,2);
  t.captionLabel().style().moveMargin(-2,0,0,-3);
  t.captionLabel().style().backgroundWidth = 46;
}

void reset() {
  time=0;
  stroke(0);
  noiseSeed(int(random(100)));
  frameCount = 0;
  totalcount = 0;
  population = new Population(population_size);
  population.infect(init_infected);
  graph_overlay = createGraphics(800, 600, JAVA2D);
  graph_overlay.beginDraw();
}

void draw() {
  
  barrier_state=checkbox.value();
  background(51);
  stroke(0);
  
  if (playPause) { 
    controlP5.controller("play").setLabel("Pause");
    time += 1; 
    population.update();
  }
  else { controlP5.controller("play").setLabel("Play"); }
  population.display();  

}

void infectionRate(int value) {
 infection_rate = map(value, 0, 100, 0.004, 0.13);
 println("Infection Rate: "+infection_rate);
}

void populationSize(int value) {
 population_size = value;
 println("Population Size: "+value);
}

void keyPressed() {
  controlP5.controller("infectionRate").setValue(50);
}

void mousePressed() {
  population.toggle_state(mouseX, mouseY);
}

void save() { 
  population.export_graph();
} 

String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$tY-%1$tm-%1$td_%1$tH%1$tM%1$tS", now);
}






