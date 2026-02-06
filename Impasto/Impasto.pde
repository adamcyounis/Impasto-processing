import codeanticode.tablet.*;

Tablet tablet;
PVector view;
float zoom = 1.0;

PGraphics bufferTexture;
PShader brushShader;
PGraphics temp ;
float pressure = 0;
float radius = 20;
float activeRadius = 20;
static History history;
KeyboardInput keys;
boolean debugging;
enum DrawMode {
  Default, Drawing, Modify
}

DrawMode mode;
void setup() {

  frameRate(120);
  size(1280, 720, P2D);
  //pixelDensity(2);
  //turn anti aliasing off for crisp lines
  noSmooth();
  tablet = new Tablet(this);

  keys = new KeyboardInput();
  view = new PVector(0, 0);
  history = new History();
  history.AddState(new Canvas());

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
  for (Shape s : history.GetCurrent().shapes) {
    s.Draw();
  }

  if (debugging) {
    for (Chain c : history.GetCurrent().chains) {
      c.DrawDebug();
    }
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
  Shape newShape = new BitMapTrace(bufferTexture).shape.Clone();

  for (int i = 0; i < newShape.chains.size(); i++) {
    Chain c = newShape.chains.get(i);
    Simplify(c, 2f);
    if (c.points.size() < 4) {
      newShape.chains.remove(i);
      i--;
      continue;
    }

    c.RescaleToView();
    GetCanvas().chains.add(c);
  }
  Canvas canvas = GetCanvas().Clone();
  canvas.shapes.add(newShape);

  //clear the buffer texture
  bufferTexture.beginDraw();
  bufferTexture.background(255);
  bufferTexture.endDraw();
  history.AddState(canvas);
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

  ArrayList<String> logs = new ArrayList<String>();

  fill(0);
  textSize(16);
  logs.add("Brush Radius: " + nf(radius, 1, 2) + " (Use + / - to adjust)");
  //display zoom level
  logs.add("Zoom: " + nf(zoom, 1, 2) + "(Use mouse wheel to zoom)");
  //display view
  logs.add("View: (" + nf(view.x, 1, 2) + ", " + nf(view.y, 1, 2) + ") (Use middle mouse button to pan)");

  //log pen pressure
  if (tablet != null) {
    logs.add("Pen Pressure: " + nf(tablet.getPressure(), 1, 2));
  }

  logs.add("Canvas Chains: " + GetCanvas().chains.size());
  logs.add("Canvas Shapes: " + GetCanvas().shapes.size());
  logs.add("Debug Mode: " + (debugging ? "ON" : "OFF") + " (Press ` to toggle)");

  //draw a stroke preview circle at mouse position of radius size in screen space
  noFill();
  stroke(0);
  ellipse(mouseX, mouseY, radius*2, radius*2);

  for (int i = 0; i < logs.size(); i++) {
    text(logs.get(i), 10, height - 10 - i * 20);
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

static Canvas GetCanvas() {
  return history.GetCurrent();
}
