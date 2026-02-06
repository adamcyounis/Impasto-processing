void Simplify(Chain input, float tolerance) {


  if (input.points.size() <= 2) {
    return; // Nothing to simplify
  }

  // Track which indices to keep
  boolean[] keepIndex = new boolean[input.points.size()];
  keepIndex[0] = true;
  keepIndex[input.points.size() - 1] = true;

  FindExtremities(0, input.points.size() - 1, input.points, keepIndex, tolerance);

  // Build output list from kept indices
  ArrayList<Point> oPoints = new ArrayList<Point>();
  for (int i = 0; i < input.points.size(); i++) {
    if (keepIndex[i]) {
      oPoints.add(input.points.get(i));
    }
  }
  input.points = oPoints;
}

void FindExtremities(int startIndex, int endIndex, ArrayList<Point> iPoints, boolean[] keepIndex, float tolerance) {

  float maxDist = 0;
  int furthestIndex = -1;

  // Find the point furthest from the line segment
  for (int i = startIndex + 1; i < endIndex; i++) {
    Point p = iPoints.get(i);
    float dist = DistToSegment(iPoints.get(startIndex).pos, iPoints.get(endIndex).pos, p.pos);
    if (dist > maxDist) {
      maxDist = dist;
      furthestIndex = i;
    }
  }

  // If furthest point is beyond tolerance, keep it and recurse on both segments
  if (maxDist >= tolerance && furthestIndex != -1) {
    keepIndex[furthestIndex] = true;

    // Recurse on the two segments created by this point
    FindExtremities(startIndex, furthestIndex, iPoints, keepIndex, tolerance);
    FindExtremities(furthestIndex, endIndex, iPoints, keepIndex, tolerance);
  }
  // Otherwise, all points between start and end are within tolerance - discard them
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
