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
  if (furthestIndex != -1) {
    if (maxDist >= tolerance ) {
      keepIndex[furthestIndex] = true;

      // Recurse on the two segments created by this point
      FindExtremities(startIndex, furthestIndex, iPoints, keepIndex, tolerance);
      FindExtremities(furthestIndex, endIndex, iPoints, keepIndex, tolerance);
    }
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


void DrawSimplifyUnitTest() {
  //create a shape with 3 points
  Chain chain = new Chain();

  float margin = 100;
  float baseLine = height/2f;
  float penultimate = height/3;

  PVector ap = new PVector(margin, baseLine);
  PVector bp = new PVector(width*0.33f, penultimate);
  PVector cp = new PVector(width*0.66f, height/4);
  PVector dp = new PVector(width-margin, baseLine);

  Point a = new Point(ap.x, ap.y);
  Point b = new Point(bp.x, bp.y);
  Point c = new Point(cp.x, cp.y);
  Point d = new Point(dp.x, dp.y);

  chain.points.add(a);
  chain.points.add(b);
  chain.points.add(c);
  chain.points.add(d);

  Simplify(chain, baseLine - penultimate );
  Smoothen(chain);
  chain.Draw();

  stroke(255, 0, 0);
  for (Point p : chain.points) {
    p.Draw(true);
  }
}
