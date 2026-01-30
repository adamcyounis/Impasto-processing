
PVector mouseDownWorldPos;
PVector prevMousePos;

void HandleInputs() {

  boolean inputtingModifier = false;
  // Placeholder for processing tablet or other inputs
  if (keyPressed) {
    if (key == '=') {
      radius += 1;
      brushShader.set("brushRadius", radius);
      inputtingModifier = true;
    } else if (key == '-') {
      radius = max(1, radius - 1);
      brushShader.set("brushRadius", radius);
      inputtingModifier = true;
    }

    if (key == 'z' && mousePressed) {
      float zoomAmount = ( pmouseY - mouseY ) * 0.2f;
      AdjustZoomAtPosition(WorldToScreen(mouseDownWorldPos), zoomAmount);
      inputtingModifier = true;
    }
  }

  //pan view with middle mouse button or space + left mouse button
  if (mousePressed && (mouseButton == CENTER || (key == ' ' && keyPressed))) {
    view.x += (mouseX - pmouseX) / zoom;
    view.y += (mouseY - pmouseY) / zoom;
    inputtingModifier = true;
  }

  //adjust brush size with d + left mouse button
  if (mousePressed && keyPressed && key == 'd') {
    radius += (mouseX - pmouseX) * 0.5;
    radius = max(1, radius);
    inputtingModifier = true;
  }

  if (inputtingModifier) {
    mode = DrawMode.Modify;
  } else {
    mode = DrawMode.Default;
  }
}

void mousePressed() {
  mouseDownWorldPos = ScreenToWorld(new PVector(mouseX, mouseY));
}

void mouseWheel(MouseEvent event) {
  //zoom and pan towards mouse position
  float e = event.getCount();
  AdjustZoomAtPosition(new PVector(mouseX, mouseY), -e);
}

void AdjustZoomAtPosition(PVector screenPos, float amount) {
  //zoom and pan towards screenPos position
  float zoomFactor = 1.1;

  // Screen position in world space before zoom
  float mouseWorldX = screenPos.x / zoom - view.x;
  float mouseWorldY = screenPos.y / zoom - view.y;

  if (amount > 0) {
    zoom *= pow(zoomFactor, amount);
  } else if (amount < 0) {
    zoom /= pow(zoomFactor, -amount);
  }

  // Keep the same world point under the screenPos after zoom
  view.x = screenPos.x / zoom - mouseWorldX;
  view.y = screenPos.y / zoom - mouseWorldY;
}
