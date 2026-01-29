Shape s;
ArrayList<PVector> stroke;  //list of points in the shape
boolean drawing = false;
boolean strokeMode = true;
float radius = 10;
void setup() {
  size(700, 700);
  pixelDensity(2);
  s = new Shape();
}

void draw() {
  background(255);
  s.Draw();

  if (drawing) {
    UpdateDrawing();
  } else {
    if (mousePressed) {
      StartDrawing();
    }
  }
}

void UpdateDrawing() {
  if (mousePressed) {
    for (PVector p : stroke) {
      strokeWeight(2);
      point(p.x, p.y);
    }
    stroke.add(new PVector(mouseX, mouseY));
  } else {
    FinishDrawing();
  }
}

void StartDrawing() {
  drawing = true;
  stroke = new ArrayList<PVector>();
  stroke.add(new PVector(mouseX, mouseY));
}


void FinishDrawing() {
  drawing = false;
  //create shape
  // s = new Shape();

  if (strokeMode) {
    FinishStroke();
  } else {
    FinishPolygon();
  }
}

void FinishStroke() {
  // Stroke mode: create envelope around the stroke points
  s.isClosed = false;  // Strokes are typically open
  s.strokeRadius = radius;

  // Add stroke points to shape (with some filtering for smoothness)
  ArrayList<PVector> filteredStroke = FilterStrokePoints(stroke);
  for (PVector p : filteredStroke) {
    s.AddPoint(p.x, p.y);
  }
  s.RelaxControlPoints();

  // Convert to inflated envelope
  s = createBrushStroke(filteredStroke, radius);
}

void FinishPolygon() {
  // Normal mode: create regular bezier shape
  for (PVector p : stroke) {
    s.AddPoint(p.x, p.y);
  }
  s.RelaxControlPoints();
}

// Create a brush stroke as an envelope around the stroke path
Shape createBrushStroke(ArrayList<PVector> strokePath, float brushRadius) {
  if (strokePath.size() < 2) {
    Shape emptyShape = new Shape();
    return emptyShape;
  }

  Shape brushShape = new Shape();
  brushShape.isClosed = true; // The envelope will be closed

  // Calculate normals and create offset paths
  ArrayList<PVector> leftSide = new ArrayList<PVector>();
  ArrayList<PVector> rightSide = new ArrayList<PVector>();

  for (int i = 0; i < strokePath.size(); i++) {
    PVector current = strokePath.get(i);
    PVector tangent;

    if (i == 0) {
      // First point: use direction to next point
      tangent = PVector.sub(strokePath.get(i + 1), current);
    } else if (i == strokePath.size() - 1) {
      // Last point: use direction from previous point
      tangent = PVector.sub(current, strokePath.get(i - 1));
    } else {
      // Middle points: average direction
      PVector prev = strokePath.get(i - 1);
      PVector next = strokePath.get(i + 1);
      tangent = PVector.sub(next, prev);
    }

    tangent.normalize();
    PVector normal = new PVector(-tangent.y, tangent.x); // Perpendicular
    normal.mult(brushRadius);

    leftSide.add(PVector.add(current, normal));
    rightSide.add(PVector.sub(current, normal));
  }

  // Add left side points
  for (PVector p : leftSide) {
    brushShape.AddPoint(p.x, p.y);
  }

  // Add right side points in reverse order
  for (int i = rightSide.size() - 1; i >= 0; i--) {
    PVector p = rightSide.get(i);
    brushShape.AddPoint(p.x, p.y);
  }

  brushShape.RelaxControlPoints();
  return brushShape;
}


// Improved stroke point filtering with overlap elimination
ArrayList<PVector> FilterStrokePoints(ArrayList<PVector> rawStroke) {
  if (rawStroke.size() < 3) return rawStroke;

  // First pass: Remove points too close together
  ArrayList<PVector> distanceFiltered = new ArrayList<PVector>();
  distanceFiltered.add(rawStroke.get(0));

  float minDistance = radius * 0.3; // Adaptive to brush radius

  for (int i = 1; i < rawStroke.size(); i++) {
    PVector current = rawStroke.get(i);
    PVector last = distanceFiltered.get(distanceFiltered.size() - 1);

    if (PVector.dist(current, last) > minDistance) {
      distanceFiltered.add(current);
    }
  }

  // Second pass: Douglas-Peucker simplification
  ArrayList<PVector> simplified = douglasPeucker(distanceFiltered, radius * 0.2);

  // Third pass: Remove points that would create internal overlaps
  return RemoveOverlapPoints(simplified, radius);
}

// Douglas-Peucker line simplification algorithm
ArrayList<PVector> douglasPeucker(ArrayList<PVector> points, float epsilon) {
  if (points.size() < 3) return points;

  // Find the point with maximum distance from line between first and last
  float maxDist = 0;
  int maxIndex = 0;

  PVector start = points.get(0);
  PVector end = points.get(points.size() - 1);

  for (int i = 1; i < points.size() - 1; i++) {
    float dist = PointToLineDistance(points.get(i), start, end);
    if (dist > maxDist) {
      maxDist = dist;
      maxIndex = i;
    }
  }

  ArrayList<PVector> result = new ArrayList<PVector>();

  if (maxDist > epsilon) {
    // Recursively simplify both sides
    ArrayList<PVector> leftSide = new ArrayList<PVector>(points.subList(0, maxIndex + 1));
    ArrayList<PVector> rightSide = new ArrayList<PVector>(points.subList(maxIndex, points.size()));

    ArrayList<PVector> leftResult = douglasPeucker(leftSide, epsilon);
    ArrayList<PVector> rightResult = douglasPeucker(rightSide, epsilon);

    // Combine results (remove duplicate point at junction)
    result.addAll(leftResult);
    rightResult.remove(0);
    result.addAll(rightResult);
  } else {
    // Keep only endpoints
    result.add(start);
    result.add(end);
  }

  return result;
}

// Calculate perpendicular distance from point to line
float PointToLineDistance(PVector point, PVector lineStart, PVector lineEnd) {
  float A = point.x - lineStart.x;
  float B = point.y - lineStart.y;
  float C = lineEnd.x - lineStart.x;
  float D = lineEnd.y - lineStart.y;

  float dot = A * C + B * D;
  float lenSq = C * C + D * D;

  if (lenSq == 0) return PVector.dist(point, lineStart);

  float param = dot / lenSq;

  PVector closest;
  if (param < 0) {
    closest = lineStart.copy();
  } else if (param > 1) {
    closest = lineEnd.copy();
  } else {
    closest = new PVector(lineStart.x + param * C, lineStart.y + param * D);
  }

  return PVector.dist(point, closest);
}

// Remove points that would create overlapping brush strokes
ArrayList<PVector> RemoveOverlapPoints(ArrayList<PVector> points, float brushRadius) {
  if (points.size() < 4) return points;

  ArrayList<PVector> filtered = new ArrayList<PVector>();
  filtered.add(points.get(0));

  float overlapThreshold = brushRadius * 1.8; // Points closer than this may cause overlaps

  for (int i = 1; i < points.size(); i++) {
    PVector current = points.get(i);
    boolean shouldAdd = true;

    // Check against recent points (not just the immediate previous)
    int checkBack = Math.min(filtered.size(), 3);
    for (int j = filtered.size() - checkBack; j < filtered.size(); j++) {
      if (PVector.dist(current, filtered.get(j)) < overlapThreshold) {
        // Check if this point would create a "fold back" in the stroke
        if (j < filtered.size() - 1 && WouldCreateFoldback(filtered.get(j), current, filtered.get(filtered.size() - 1))) {
          shouldAdd = false;
          break;
        }
      }
    }

    if (shouldAdd) {
      filtered.add(current);
    }
  }

  return filtered;
}

// Check if adding a point would create a fold-back that causes overlaps
boolean WouldCreateFoldback(PVector prevPoint, PVector newPoint, PVector lastPoint) {
  PVector v1 = PVector.sub(lastPoint, prevPoint);
  PVector v2 = PVector.sub(newPoint, prevPoint);

  // If the dot product is negative, we're folding back
  return PVector.dot(v1, v2) < 0;
}
