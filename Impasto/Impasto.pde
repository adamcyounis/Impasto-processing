/*
import jwinpointer.JWinPointerReader;
 import jwinpointer.JWinPointerReader.PointerEventListener;
 */


PGraphics bufferTexture;
PShader brushShader;
PGraphics temp ;
Path s;
boolean drawing = false;
float radius = 5;
PVector prevMousePos;

void setup() {
  frameRate(120);
  size(700, 700, P2D);
  //pixelDensity(2);

  s = new Path();

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
  s.Draw();

  if (!drawing) {
    if (mousePressed) {
      BeginStroke();
    }
  } else {
    if (!mousePressed) {
      EndStroke();
    } else {
      UpdateStroke();
    }
  }

  // Display the buffer
  image(bufferTexture, 0, 0);
  prevMousePos = new PVector(mouseX, mouseY);
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