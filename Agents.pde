class Agent {
  // Instance variables for the class
  PVector loc, vel, acc;
  float mass, max_vel, bounce, radius, topspeed, yoff, x2, recovery_rate, offset;
  int lifespan, x1, time_infected, duration, age, state, tod, time_recovered;
  boolean infected, immune, alive;

  // default constructor
  Agent() {
    age = 0;
    loc = new PVector(random(width),random(height));
    vel = new PVector(int(random(10))*2-10, int(random(10)*2-10));
    acc = new PVector(0,0);
    topspeed = 3;
    yoff = random(1000);
    x1 = int(random(10000000));
    x2 = random(1);
    mass = 1;
    bounce = 1.0;
    radius = 3;
    duration = 5;
    alive = true;
    infected = false;
    immune = false;
    time_infected = 0;
    time_recovered = 0;
    recovery_rate = .95;
    offset = random(.001, .05);
    state = 1; // 1 = S, 2 = I, 3 = R   0=Dead
  }


  int recovery() {
      this.recover();
      return 3;
  }
  
  boolean re_sus() {
    if ((time - this.time_recovered) > 50) {
      this.sus(); 
      return true;
    }
    else {
      return false;
    }
  }
  
  void infect() {
    this.alive=true;
    this.infected=true;
    this.immune = false;
    this.state = 2;
  }

  void recover() {
    this.alive=true;
    this.infected=false;
    this.immune = true;
    this.state = 3;
    this.time_recovered = time;
  }
  
  void sus() {
    this.alive=true;
    this.infected=false;
    this.immune = false;
    this.state = 1;
    this.time_recovered = 0;
  }

  void kill() {
    this.infected=false;
    this.alive=false;
    this.immune = false;
    this.state = 0;
    this.tod = time;
  }

  void rabid() {
    loc.add(PVector.mult(vel, random(1,2)));
  }

  void slowdown() {
    //loc.add(PVector.mult(vel, -.75));
  }


  void update() {
    this.age += 1;
    if (this.alive) { // don't waste time moving if i'm dead
      // grab a value from the perlin space
      float theta = map(noise(this.yoff, this.loc.x/300, this.loc.y/300), 0, 1, 0, TWO_PI); //mapped onto [0,2pi]
      // convert this theta into the x and y for the acc vector
      this.acc.x += cos(theta)*.1;
      this.acc.y += sin(theta);
      
      acc.normalize();
      acc.mult(.2);
      acc.mult(random(1,1.5));
      if (random(1) < .5) {
        acc.mult(-1);
      } 
      
      if (barrier_state == 1.0) {
        // force barrier down the middle
        if (this.loc.x > ((width/2)-35) && this.loc.x < (width/2)) { this.acc.x += -0.12; }
        if (this.loc.x < ((width/2)+35) && this.loc.x > (width/2)) { this.acc.x += 0.12; }
        
        if (this.loc.y > ((height/2)-40) && this.loc.y < (height/2)) { this.acc.y += -0.2; }
        if (this.loc.y < ((height/2)+40) && this.loc.y > (height/2)) { this.acc.y += 0.2; }
      }
      
      // Velocity change by acceleration and is limited by topspeed.

      this.checkEdges();
      vel.add(acc);
      vel.limit(topspeed);
      loc.add(vel);
      acc.mult(0);
    }
  }

  void applyForce(PVector force) {
    force.div(mass);   // Newton's second law
    acc.add(force);    // Accumulate acceleration
  }

  boolean checkCollision(Agent a2) {

    // get distances between the balls components
    PVector aVect = PVector.sub(this.loc, a2.loc);
    // calculate magnitude of the vector separating the balls
    if (aVect.mag() < (this.radius + a2.radius)) {
      return true;
    } 
    else {
      return false;
    }
  }

  boolean checkForInfection(Agent other) {
    if (!this.immune) {
      if ((other.infected) && random(1) < infection_rate ) {
        this.infect();
      }
    }

    return this.infected;
  }


  PVector calcGravForce(PVector t) {
    PVector dir = PVector.sub(loc,t);        // Calculate direction of force
    float d = dir.mag();                              // Distance between objects
    d = constrain(d,35.0,5000.0);                        // Limiting the distance to eliminate "extreme" results for very close or very far objects
    dir.normalize();                                  // Normalize vector (distance doesn't matter here, we just want this vector for direction)
    float force = (G * mass * 200) / (d * d); // Calculate gravitional force magnitude
    dir.mult(-force);                                  // Get force vector --> magnitude * direction
    return dir;
  }


  PVector calcGravForce(Agent t) {
    PVector dir = PVector.sub(loc,t.loc);        // Calculate direction of force
    float d = dir.mag();                              // Distance between objects
    d = constrain(d,20.0,5000.0);                        // Limiting the distance to eliminate "extreme" results for very close or very far objects
    dir.normalize();                                  // Normalize vector (distance doesn't matter here, we just want this vector for direction)
    float force = (G * mass * t.mass) / (d * d); // Calculate gravitional force magnitude
    dir.mult(-force);                                  // Get force vector --> magnitude * direction
    return dir;
  }


  void checkEdges() {

    if (loc.x > width) {
      acc.x += -1;
    } 
    else if (loc.x < 0) {
      acc.x += 1;
    }

    if (loc.y > height) {
      acc.y += -1;
    } 
    else if (loc.y < 0) {
      acc.y += 1;
    }

  }
}

