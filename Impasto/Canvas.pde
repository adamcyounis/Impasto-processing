class Canvas {
  ArrayList<Shape> shapes;
  Canvas() {
    shapes = new ArrayList<Shape>();
  }

  Canvas Clone() {
    Canvas newCanvas = new Canvas();
    for (Shape s : shapes) {
      newCanvas.shapes.add(s.Clone());
    }
    return newCanvas;
  }
}
