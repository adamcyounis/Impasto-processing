

//take a Path.
//start at the first and last points, and recursively find the point furthest from the line segment between them.
//if that point is further than the tolerance, keep it, and recurse on the two segments
//if a point is within the tolerance, remove it
// when all points have been processed, return the simplified Path


Path Simplify(Path input, float tolerance) {

  Path output = input.Clone();

  return output;
}
