void Smoothen(Chain c) {

  for (int i = 0; i < c.points.size(); i++) {
    Point p = c.points.get(i);
    Point prev = c.points.get((i - 1 + c.points.size()) % c.points.size());
    Point next = c.points.get((i + 1) % c.points.size());

    PVector dir = PVector.sub(next.pos, prev.pos);
    dir.normalize();
    dir.mult(PVector.dist(p.pos, prev.pos) / 3.0);
    p.leftCP = PVector.sub(p.pos, dir);
    dir.normalize();

    dir.mult(PVector.dist(p.pos, next.pos) /3.0);
    p.rightCP = PVector.add(p.pos, dir);
  }
}
