//a point is the base of a spline.
//it contains the position, the left and right control points.
class Point {
  PVector pos;      //position of the point
  PVector leftCP;   //left control point
  PVector rightCP;  //right control point

  Point(float x, float y) {
    pos = new PVector(x, y);
    leftCP = new PVector(x, y);
    rightCP = new PVector(x, y);
  }

  Point(PVector p, PVector lCP, PVector rCP) {
    pos = p.copy();
    leftCP = lCP.copy();
    rightCP = rCP.copy();
  }

  void Draw(boolean showControlPoints) {
    //draw the point and its control points
    stroke(0);
    strokeWeight(1);
    point(pos.x, pos.y);

    if (!showControlPoints) {
      return;
    }
    strokeWeight(1);
    line(pos.x, pos.y, leftCP.x, leftCP.y);
    line(pos.x, pos.y, rightCP.x, rightCP.y);

    strokeWeight(1);
    point(leftCP.x, leftCP.y);
    point(rightCP.x, rightCP.y);
  }
}
