class Canvas {
  ArrayList<Shape> shapes;
  ArrayList<Chain> chains;
  Canvas() {
    shapes = new ArrayList<Shape>();
    chains = new ArrayList<Chain>();
  }

  Canvas Clone() {
    Canvas newCanvas = new Canvas();
    for (Shape s : shapes) {
      newCanvas.shapes.add(s.Clone());
    }
    return newCanvas;
  }
}
