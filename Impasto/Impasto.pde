Shape s;
ArrayList<PVector> stroke;  //list of points in the shape
boolean drawing = false;

void setup() {
  size(700, 700);
  pixelDensity(2);
  s = new Shape();
  //north
  s.AddPoint(width/2, height/4);
  //east
  s.AddPoint(width*3/4, height/2);
  //south
  s.AddPoint(width/2, height*3/4);
  //west
  s.AddPoint(width/4, height/2);
  s.RelaxControlPoints();
}

void draw() {
  background(255);
  s.Draw();

  if (drawing) {
    UpdateDrawing();
  } else {
    if (mousePressed) {
      StartDrawing();
    }
  }
}

void UpdateDrawing() {
  if (mousePressed) {
    for (PVector p : stroke) {
      strokeWeight(2);
      point(p.x, p.y);
    }
    stroke.add(new PVector(mouseX, mouseY));
  } else {
    drawing = false;
    //create shape
    s = new Shape();
    for (PVector p : stroke) {
      s.AddPoint(p.x, p.y);
    }
    s.RelaxControlPoints();
  }
}

void StartDrawing() {
  drawing = true;
  stroke = new ArrayList<PVector>();
  stroke.add(new PVector(mouseX, mouseY));
}
