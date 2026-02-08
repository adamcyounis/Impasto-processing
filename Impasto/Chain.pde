class Chain {
  ArrayList<Point> points;  //list of points in the shape
  color debugColour = color(random(255), random(255), random(255));
  Chain() {
    points = new ArrayList<Point>();
  }

  void AddPoint(Point p) {
    points.add(p);
  }

  void AddPoint(float x, float y) {
    points.add(new Point(x, y));
  }

  int NumPoints() {
    return points.size();
  }

  Point GetPoint(int index) {
    return points.get(index);
  }

  void Draw() {
    if (points.size() > 2) {
      // Draw filled shape
      noStroke();

      beginShape();

      // First vertex
      Point firstPoint = points.get(0);
      vertex(firstPoint.pos.x, firstPoint.pos.y);

      for (int i = 0; i < points.size(); i++) {
        Point p0 = points.get(i);
        Point p1 = points.get((i + 1) % points.size());
        // Add bezier vertex from p0 to p1
        bezierVertex(p0.rc.x, p0.rc.y,
          p1.lc.x, p1.lc.y,
          p1.pos.x, p1.pos.y);
      }

      endShape(CLOSE);
    }
  }
  void DrawDebug() {
    //for every point in shape
    for (int i = 0; i < points.size(); i++) {
      Point p = points.get(i);
      //draw a red circle at point
      if (i == 0) {
        fill(255);
      } else {
        fill(debugColour);
      }
      noStroke();
      p.Draw(true);
    }
  }

  void RelaxControlPoints() {
    //relax the control points of all points in the shape
    for (int i = 0; i < points.size(); i++) {
      Point p0 = points.get((i - 1 + points.size()) % points.size());
      Point p1 = points.get(i);
      Point p2 = points.get((i + 1) % points.size());

      //vector from p0 to p2
      PVector dir = PVector.sub(p2.pos, p0.pos);
      dir.normalize();
      dir.mult(PVector.dist(p1.pos, p0.pos) / 3.0);

      //set left and right control points
      p1.lc = PVector.sub(p1.pos, dir);
      p1.rc = PVector.add(p1.pos, dir);
    }
  }

  Chain Clone() {
    Chain newChain = new Chain();
    for (Point p : points) {
      Point newPoint = new Point(p.pos.x, p.pos.y);
      newPoint.lc = p.lc.copy();
      newPoint.rc = p.rc.copy();
      newChain.AddPoint(newPoint);
    }
    return newChain;
  }

  void RescaleToView() {
    for (Point p : points) {
      p.RescaleToView(view, zoom);
    }
  }
}
