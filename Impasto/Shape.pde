// a closed loop of points
class Shape {
  float strokeRadius = 10.0; // Inflation radius for stroke
  color colour;
  ArrayList<Chain> chains;
  Shape() {
    colour = color(0, 128);//new PVector(random(255), random(255), random(255));
    chains = new ArrayList<Chain>();
  }

  void Draw() {
    fill(colour);  // Semi-transparent fill
    for (Chain c : chains) {
      c.Draw();
    }
  }

  Shape Clone() {
    Shape newShape = new Shape();
    newShape.colour = colour;
    newShape.strokeRadius = strokeRadius;
    newShape.chains = new ArrayList<Chain>();

    for (Chain c : chains) {
      newShape.chains.add(c.Clone());
    }
    return newShape;
  }

  void RescaleToView() {
    for (Chain c : chains) {
      c.RescaleToView();
    }
  }
}
