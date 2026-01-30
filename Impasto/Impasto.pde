/*
import jwinpointer.JWinPointerReader;
 import jwinpointer.JWinPointerReader.PointerEventListener;
 */

PVector view;
float zoom = 1.0;

PGraphics bufferTexture;
PShader brushShader;
PGraphics temp ;
ArrayList<Shape> shapes;
boolean drawing = false;
float radius = 20;
PVector prevMousePos;

void setup() {

  frameRate(120);
  size(700, 700, P2D);
  //pixelDensity(2);
  //turn anti aliasing off for crisp lines
  noSmooth();

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
}

void draw() {
  background(255);

  HandleInputs();
  HandleStroke();


  pushMatrix();
  scale(zoom);
  translate(view.x, view.y);
  DrawDebug();
  DrawShapes();
  popMatrix();


  prevMousePos = new PVector(mouseX, mouseY);


  DrawUI();
}

void DrawShapes() {
  for (Shape s : shapes) {
    s.Draw();
  }
}

void HandleStroke() {
  if (!drawing) {
    if (mousePressed && (mouseButton == LEFT)) {
      BeginStroke();
    }
  } else {
    if (!mousePressed || (mouseButton != LEFT)) {
      EndStroke();
    } else {
      UpdateStroke();
    }
  }
  if (drawing) {
    // Display the buffer
    image(bufferTexture, 0, 0);
  }
}

void BeginStroke() {
  drawing = true;
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
  drawing = false;
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

void HandleInputs() {
  // Placeholder for processing tablet or other inputs
  if (keyPressed) {
    if (key == '=') {
      radius += 1;
      brushShader.set("brushRadius", radius);
    } else if (key == '-') {
      radius = max(1, radius - 1);
      brushShader.set("brushRadius", radius);
    }
  }

  if (mousePressed && (mouseButton == CENTER)) {
    view.x += (mouseX - pmouseX) / zoom;
    view.y += (mouseY - pmouseY) / zoom;
  }
}

void mouseWheel(MouseEvent event) {
  //zoom and pan towards mouse position
  float e = event.getCount();
  float zoomFactor = 1.05;

  // Mouse position in world space before zoom
  float mouseWorldX = mouseX / zoom - view.x;
  float mouseWorldY = mouseY / zoom - view.y;

  if (e > 0) {
    zoom /= pow(zoomFactor, e);
  } else if (e < 0) {
    zoom *= pow(zoomFactor, -e);
  }

  // Keep the same world point under the mouse after zoom
  view.x = mouseX / zoom - mouseWorldX;
  view.y = mouseY / zoom - mouseWorldY;
}

void DrawUI() {
  fill(0);
  textSize(16);
  text("Brush Radius: " + nf(radius, 1, 2) + " (Use + / - to adjust)", 10, height - 10);
  //display zoom level
  text("Zoom: " + nf(zoom, 1, 2) + "(Use mouse wheel to zoom)", 10, height - 30);
  //display view
  text("View: (" + nf(view.x, 1, 2) + ", " + nf(view.y, 1, 2) + ") (Use middle mouse button to pan)", 10, height - 50);
}


void DrawDebug() {

  //draw crosshair at origin
  stroke(0, 255, 0);
  line(-10, 0, 10, 0);
  line(0, -10, 0, 10);
}
