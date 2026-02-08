//a point is the base of a spline.
//it contains the position, the left and right control points.
class Point {
  PVector pos;      //position of the point
  PVector lc;   //left control point
  PVector rc;  //right control point

  Point(float x, float y) {
    pos = new PVector(x, y);
    lc = new PVector(x, y);
    rc = new PVector(x, y);
  }

  Point(PVector p, PVector lCP, PVector rCP) {
    pos = p.copy();
    lc = lCP.copy();
    rc = rCP.copy();
  }

  void Draw(boolean showControlPoints) {
    //draw the point and its control points
    strokeWeight(1/zoom);
    point(pos.x, pos.y);

    if (!showControlPoints) {
      return;
    }

    stroke(255, 0, 0);
    line(pos.x, pos.y, lc.x, lc.y);
    line(pos.x, pos.y, rc.x, rc.y);

    point(lc.x, lc.y);
    point(rc.x, rc.y);
    //ellipses for control points
    ellipse (lc.x, lc.y, 5/zoom, 5/zoom);
    ellipse (rc.x, rc.y, 5/zoom, 5/zoom);
  }

  void RescaleToView(PVector view, float zoom) {
    pos.div(zoom);
    pos.sub(view);

    lc.div(zoom);
    lc.sub(view);

    rc.div(zoom);
    rc.sub(view);
  }
}
