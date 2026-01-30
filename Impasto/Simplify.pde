Shape Simplify(Shape input, float tolerance) {
  Shape output = input.Clone();

  //take a Shape.
  //start at the first and last points, and recursively find the point furthest from the line segment between them.
  ArrayList<Point> iPoints = input.points;

  ArrayList<Point> oPoints = new ArrayList<Point>();
  oPoints.add(iPoints.get(0));
  //oPoints.add(iPoints.get(iPoints.size()-1));
  FindExtremities(0, iPoints.size()-1, iPoints, oPoints, tolerance);

  //if that point is further than the tolerance, keep it, and recurse on the two segments
  //if a point is within the tolerance, remove it
  // when all points have been processed, return the simplified Path
  output.points = oPoints;
  println("Simplified from " + iPoints.size() + " to " + output.points.size());

  return output;
}

ArrayList<Point> FindExtremities(int startIndex, int endIndex, ArrayList<Point> iPoints, ArrayList<Point> oPoints, float tolerance) {

  float maxDist = 0;
  int furthestIndex = -1;

  for (int i = startIndex + 1; i < endIndex; i++) {
    Point p = iPoints.get(i);
    float dist = DistToSegment(iPoints.get(startIndex).pos, iPoints.get(endIndex).pos, p.pos);
    if (dist > maxDist) {
      maxDist = dist;
      furthestIndex = i;
    }
  }

  //early return if we didn't find anything far enough.
  if (maxDist < tolerance || furthestIndex == -1) {
    return oPoints;
  }

  //add the furthest that we found, which necessarily was further than the tolerance
  //insertion sort to keep order
  boolean added = false;

  if (!added) {
    for (int i = 0; i < oPoints.size(); i++) {
      if (furthestIndex < iPoints.indexOf(oPoints.get(i))) {
        oPoints.add(i, iPoints.get(furthestIndex));
        added = true;
        break;
      }
    }
  }

  if (!added) {
    oPoints.add(iPoints.get(furthestIndex));
    added = true;
  }

  //split the two lists either side of the furthest point, and recurse
  FindExtremities(startIndex, furthestIndex, iPoints, oPoints, tolerance);
  FindExtremities(furthestIndex, endIndex, iPoints, oPoints, tolerance);
  return oPoints;
}

public float DistToSegment(PVector a, PVector b, PVector x) {

  PVector ab = PVector.sub(b, a);
  PVector ax = PVector.sub(x, a);
  float ab2 = ab.magSq();
  float ap_ab = ax.dot(ab);
  float t = ap_ab / ab2;

  if (t < 0.0) t = 0.0;
  else if (t > 1.0) t = 1.0;

  PVector projection = PVector.add(a, PVector.mult(ab, t));
  return PVector.dist(x, projection);
}
