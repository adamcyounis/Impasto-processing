// a closed loop of points
class Shape {
  ArrayList<Point> points;  //list of points in the shape
  float strokeRadius = 10.0; // Inflation radius for stroke
  boolean isClosed = true; // Whether the shape is closed
  Shape() {
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
      fill(200, 100, 100, 150);  // Semi-transparent fill
      noStroke();

      beginShape();

      // First vertex
      Point firstPoint = points.get(0);
      vertex(firstPoint.pos.x, firstPoint.pos.y);

      for (int i = 0; i < points.size(); i++) {
        Point p0 = points.get(i);
        Point p1 = points.get((i + 1) % points.size());

        // Add bezier vertex from p0 to p1
        bezierVertex(p0.rightCP.x, p0.rightCP.y,
          p1.leftCP.x, p1.leftCP.y,
          p1.pos.x, p1.pos.y);
      }

      endShape(CLOSE);

      // Optionally draw control points for editing
      for (Point p : points) {
        p.Draw(false);
      }
    } else {
      // Fallback for shapes with fewer points
      for (int i = 0; i < points.size(); i++) {
        Point p0 = points.get(i);
        Point p1 = points.get((i + 1) % points.size());

        //draw bezier curve from p0 to p1
        noFill();
        stroke(0);
        strokeWeight(2);
        p0.Draw(false);
        p1.Draw(false);
      }
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
      p1.leftCP = PVector.sub(p1.pos, dir);
      p1.rightCP = PVector.add(p1.pos, dir);
    }
  }
}
