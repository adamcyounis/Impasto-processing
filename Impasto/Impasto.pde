import codeanticode.tablet.*;

Tablet tablet;
PVector view;
float zoom = 1.0;

PGraphics bufferTexture;
PShader brushShader;
PGraphics temp ;
ArrayList<Shape> shapes;
float pressure = 0;
float radius = 20;
float activeRadius = 20;
enum DrawMode {
  Default, Drawing, Modify
}

DrawMode mode;
void setup() {

  frameRate(120);
  size(700, 700, P2D);
  //pixelDensity(2);
  //turn anti aliasing off for crisp lines
  noSmooth();
  tablet = new Tablet(this);

  view = new PVector(0, 0);
  shapes = new ArrayList<Shape>();

  // Create offscreen buffer
  temp = createGraphics(width, height, P2D);
  bufferTexture = createGraphics(width, height, P2D);
  bufferTexture.beginDraw();
  bufferTexture.background(255); // Start with white
  bufferTexture.endDraw();

  // Load shader
  brushShader = loadShader("data/brush.frag");

  // Set uniforms that NEVER change
  brushShader.set("resolution", float(width), float(height));
  brushShader.set("brushRadius", radius);
  mode = DrawMode.Default;
}

void draw() {
  background(255);

  if (mode != DrawMode.Drawing) {
    HandleInputs();
  }

  if (mode != DrawMode.Modify) {
    HandlePressure();
    HandleStroke();
  }

  pushMatrix();
  scale(zoom);
  translate(view.x, view.y);
  DrawShapes();
  popMatrix();

  DrawUI();
  DrawDebug();
  prevMousePos = new PVector(mouseX, mouseY);
}

void DrawShapes() {
  for (Shape s : shapes) {
    s.Draw();
  }
}

void HandlePressure() {
  if (tablet != null && tablet.getPressure() > 0) {
    activeRadius = map(tablet.getPressure(), 0, 1, 1, radius);
    brushShader.set("brushRadius", activeRadius);
  }
}

void HandleStroke() {
  boolean inputtingMouseDraw = mousePressed && (mouseButton == LEFT);
  if (mode != DrawMode.Drawing) {
    if (inputtingMouseDraw) {
      BeginStroke();
    }
  } else {
    if (!inputtingMouseDraw) {
      EndStroke();
      mode = DrawMode.Default;
    } else {
      UpdateStroke();
    }
  }

  if (mode == DrawMode.Drawing) {
    // Display the buffer
    image(bufferTexture, 0, 0);
  }
}

void BeginStroke() {
  mode = DrawMode.Drawing;
}

void UpdateStroke() {
  PVector mousePos = new PVector(mouseX, mouseY);
  int dist = int(PVector.dist(prevMousePos, mousePos));
  for (int i = 0; i < dist; i++) {
    PVector pos = PVector.lerp(prevMousePos, mousePos, i/(float)dist);
    Stamp(pos);
    // Copy result back to buffer
    bufferTexture.beginDraw();
    bufferTexture.image(temp, 0, 0);
    bufferTexture.endDraw();
  }
}

void EndStroke() {
  mode = DrawMode.Default;
  ArrayList<Shape> newShapes = BitMapTrace(bufferTexture);

  for (int i = 0; i < newShapes.size(); i++) {
    Shape s = newShapes.get(i);
    newShapes.set(i, Simplify(s, 1) );
    newShapes.get(i).RescaleToView();
  }

  shapes.addAll(newShapes);

  //clear the buffer texture
  bufferTexture.beginDraw();
  bufferTexture.background(255);
  bufferTexture.endDraw();
  //convert the bitmap into a vector shape;
}

void Stamp(PVector mousePos) {
  float x = mousePos.x;
  float y = height -mousePos.y;
  brushShader.set("mousePos", x, y);
  brushShader.set("bufferTexture", bufferTexture);
  temp.beginDraw();
  temp.shader(brushShader);
  temp.rect(0, 0, width, height);
  temp.endDraw();
}


void DrawUI() {
  fill(0);
  textSize(16);
  text("Brush Radius: " + nf(radius, 1, 2) + " (Use + / - to adjust)", 10, height - 10);
  //display zoom level
  text("Zoom: " + nf(zoom, 1, 2) + "(Use mouse wheel to zoom)", 10, height - 30);
  //display view
  text("View: (" + nf(view.x, 1, 2) + ", " + nf(view.y, 1, 2) + ") (Use middle mouse button to pan)", 10, height - 50);

  //log pen pressure
  if (tablet != null) {
    text("Pen Pressure: " + nf(tablet.getPressure(), 1, 2), 10, height - 70);
  }
}


void DrawDebug() {

  //draw crosshair at origin
  stroke(0, 255, 0);
  line(-10, 0, 10, 0);
  line(0, -10, 0, 10);

  //draw tablet pressure as a circle at mouse position
}

PVector ScreenToWorld(PVector screenPos) {
  return new PVector(screenPos.x / zoom - view.x, screenPos.y / zoom - view.y);
}

PVector WorldToScreen(PVector worldPos) {
  return new PVector((worldPos.x + view.x) * zoom, (worldPos.y + view.y) * zoom);
}
