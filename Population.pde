class Population {
  int size, sus, inf, rec, dead;
  Agent[] members;
  ArrayList[][] buckets;
  ArrayList thegraph;

  Population(int size_) {
    thegraph = new ArrayList();
    size = size_;
    sus = size;
    inf = 0;
    rec = 0;
    prev = new int[] {sus, inf, rec};
    now = prev;
    dead = 0;
    buckets = new ArrayList[10][10];
    members = new Agent[size];
    for (int i=0; i<size; i++) {
      members[i] = new Agent();
    }
  }  

  void infect(int num) {
    for (int i=0; i<num; i++) {
      members[int(random(size))].infect();
      inf++;
      sus--;
    }
  }
  
  void toggle_state(float x, float y) {
    PVector mouseLoc;
    mouseLoc = new PVector(x, y);
    for (int i=0; i< members.length; i++) {
      // get distances between the components
      PVector aVect = PVector.sub(members[i].loc, mouseLoc);
      // calculate magnitude of the vector separating the balls
      if (aVect.mag() < (members[i].radius)) {
        
        // change to next sate
        switch(members[i].state) {
          case 1: // S
            members[i].infect();
            inf++;
            sus--;
            break;
          case 2: // I
            members[i].recover(); 
            rec++;
            inf--;
            break;
          case 3: // R
            members[i].sus();
            sus++;
            rec--; 
            break;
        }
      } 
    }
  }

  int size() {
    return size;
  }
  
  void display() {
    if (time > 0) {draw_line_graph();}
    
    // Itterate over all members
    for (int i=0; i< members.length; i++) {
      
      // Color based on state
      switch(members[i].state) {
        case 1: // S
          fill(204,204,204,opacity); // white
          break;
        case 2: // I
          fill(255,0,0,opacity); // red
          break;
        case 3: // R
          fill(204,0,204,opacity); // purple
          break;
        case 0: // Dead
          noStroke();
          fill(0,0,0, 255-((time-members[i].tod))*4);  // black
          break;
      }
      
      // draw if alive
      if (members[i].alive) {
        ellipse(members[i].loc.x, members[i].loc.y, radius*2, radius*2);
      }
      else {
        ellipse(members[i].loc.x, members[i].loc.y, radius*2, radius*2);
      }
      stroke(0);
    }
    
    // draw Graph
    graph_type = int(r.value());
    switch(graph_type) {
      case 1: // Stacked
        draw_stacked_graph();
        break;
      case 2: // Meters
        draw_meter_graph();
        break;
      case 3:  // "Line"
        if (time > 0) {
          image(graph_overlay,0,0);
        }
        break;
    }
    
    // Print Day
    fill(8,162,207,220);
    textFont(font_big);
    day = (time/day_length)+1;
    text("Day: "+day, width-200, 40);
  }
  
  void update() {
    thecount = 0;
  
    for (int i=0; i< members.length; i++) {
      // update values from sliders
      members[i].radius = radius;
      members[i].duration = duration*day_length;
      
      members[i].update();  // age and update location
     
      if (members[i].infected) {
        members[i].time_infected++;
        if (members[i].time_infected > members[i].duration) {
            inf--;
          if (members[i].recovery() == 3) { // Recovered
            rec++;
          }
          else {   // Dead
            dead++;
          }
        } 
      } 
      
      // update graph numbers
      
      for (int j=0; j< members.length; j++) {
        if (i != j && members[i].alive && members[j].alive) {
          start_state = members[i].infected;
          if (members[i].checkCollision(members[j])) {
           members[i].checkForInfection(members[j]);
          }
          end_state = members[i].infected;
          if (start_state == false && end_state == true) {
            inf++;
            sus--;
          }
        }
      }

      if (members[i].alive) {
        members[i].checkEdges();
        if (members[i].immune) {
//          if (members[i].re_sus()) {
//            rec--;
//            sus++;
//          }
      }
      
     }
    }
    // add row to graph at time t
    now = new int[] {sus, inf, rec};
    thegraph.add(new int[] {sus, inf, rec, dead});
    //println(time+", "+sus+", "+inf+", "+rec+", "+dead); 
  }
  
  void print_graph() {
   println("Time, S, I, R");  
   for (int i = 0; i < thegraph.size(); i++) {
     int[] tmp = (int[]) thegraph.get(i);
     println(i+", "+tmp[0]+", "+tmp[1]+", "+tmp[2]);
   }
  }
  
  void export_graph() {
    String folder = selectFolder("Where do you want to save export?");
    String[] graph_data = new String[thegraph.size()+2];
    String barrier_string;
    if (barrier_state > 0) {
      barrier_string = "On";
    }
    else {
      barrier_string = "Off";
    }
    graph_data[0] = "Exported "+timestamp()+"\nInfectivity: "+infectionRate+"\nPopulation Density: "+radius+"\nInfectious Period: "+duration+"\nBarrier: "+barrier_string;
    graph_data[1] = "Time (in hours), Susceptible, Infected, Recovered";
    for (int i = 0; i < thegraph.size(); i++) {
     int[] tmp = (int[]) thegraph.get(i);
     graph_data[i+2] = (i+", "+tmp[0]+", "+tmp[1]+", "+tmp[2]);
    }
    String filename = "/epi_graph_"+timestamp()+".csv";
    String fullpath = folder+filename;
    saveStrings(fullpath, graph_data); 
  }
  
  
  void draw_meter_graph() {
    float m_rec = map(rec, 0, size, 0, height-150)+20;
    float m_inf = map(inf, 0, size, 0, height-150)+20;
    float m_sus = map(sus, 0, size, 0, height-150)+20;
    
    
    textFont(font_small);
    fill(204,0,204,opacity); 
    text("R", 45, height-(m_rec)-5);
    rect(40, height-(m_rec), 20, m_rec);
    fill(255,0,0,opacity);
    text("I", 25, height-(m_inf)-5);
    rect(20, height-(m_inf), 20, m_inf);
    fill(204,204,204,opacity);
    text("S", 5, height-(m_sus)-5);
    rect(0, height-(m_sus), 20, m_sus);
    
    fill(0); 
    textFont(font_tiny);
    
    text(rec, 42, height-(m_rec)+15);
    text(inf, 22, height-(m_inf)+15);
    text(sus, 2, height-(m_sus)+15);
  }
  
  void draw_line_graph() {
    graph_overlay.beginDraw();
    graph_overlay.strokeWeight(3);
    graph_overlay.smooth();
    
    int[] a = prev;
    int[] b = now; 
    
    float a_rec = map(a[2], 0, size, 0, height-150);
    float a_inf = map(a[1], 0, size, 0, height-150);
    float a_sus = map(a[0], 0, size, 0, height-150);
    
    float b_rec = map(b[2], 0, size, 0, height-150);
    float b_inf = map(b[1], 0, size, 0, height-150);
    float b_sus = map(b[0], 0, size, 0, height-150);
    
    float t1 = (time-1)*.4;
    float t2 = (time)*.4;
    
    graph_overlay.stroke(204,204,204,opacity);
    graph_overlay.line(t1, height-a_sus, t2, height-b_sus);
    graph_overlay.stroke(255,0,0,opacity);
    graph_overlay.line(t1, height-a_inf, t2, height-b_inf);
    graph_overlay.stroke(204,0,204,opacity);
    graph_overlay.line(t1, height-a_rec, t2, height-b_rec);
    graph_overlay.endDraw();
    prev = now;
  }

  void draw_stacked_graph() {
    float m_rec = map(rec, 0, size, 0, height-150);
    float m_inf = map(inf, 0, size, 0, height-150);
    float m_sus = map(sus, 0, size, 0, height-150);
    
    fill(204,0,204,opacity);
    rect(0, height-(m_rec), 20, (m_rec));
    fill(255,0,0,opacity);
    rect(0, height-((m_inf)+(m_rec)), 20, m_inf);
    fill(204,204,204,opacity);
    rect(0, height-((m_inf)+(m_rec)+(m_sus)), 20, m_sus);
  }
  
}
