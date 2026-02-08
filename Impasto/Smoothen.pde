void Smoothen(Chain c) {

  for (int i = 0; i < c.points.size(); i++) {
    Point p = c.points.get(i);
    Point prev = c.points.get((i - 1 + c.points.size()) % c.points.size());
    Point next = c.points.get((i + 1) % c.points.size());

    PVector dir = PVector.sub(next.pos, prev.pos);
    dir.normalize();

    //concave or convex check
    PVector toNext = PVector.sub(next.pos, p.pos);
    PVector toPrev = PVector.sub(prev.pos, p.pos);
    float cross = toNext.x * toPrev.y - toNext.y * toPrev.x;

    boolean isConvex = cross > 0;
    float angle = PVector.angleBetween(toNext, toPrev);


    if ( angle > PI/2 *0.9f) {
      dir.mult(PVector.dist(p.pos, prev.pos) / 3.0);
      p.lc = PVector.sub(p.pos, dir);
      dir.normalize();

      dir.mult(PVector.dist(p.pos, next.pos) /3.0);
      p.rc = PVector.add(p.pos, dir);
    }
  }
}
