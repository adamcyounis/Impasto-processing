


Path2D.Float ChainToPath2D(Chain c) {
  Path2D.Float path = new Path2D.Float();
  if (c.points.size() == 0) return path;
  
  path.moveTo(c.points.get(0).pos.x, c.points.get(0).pos.y);
  for (int i = 1; i < c.points.size(); i++) {
    path.lineTo(c.points.get(i).pos.x, c.points.get(i).pos.y);
  }

  path.closePath();
  return path;
}

Chain Path2DToChain(Path2D path) {
  Chain c = new Chain();
  PathIterator it = path.getPathIterator(null);
  float[] coords = new float[6];
  
  while (!it.isDone()) {
    int type = it.currentSegment(coords);
    if (type == PathIterator.SEG_MOVETO || type == PathIterator.SEG_LINETO) {
      c.AddPoint(coords[0], coords[1]);
    }
    it.next();
  }
  return c;
}

Shape UnionShapes(Shape a, Shape b) {
  Area areaA = new Area();
  for (Chain c : a.chains) {
    areaA.add(new Area(ChainToPath2D(c)));
  }
  
  Area areaB = new Area();
  for (Chain c : b.chains) {
    areaB.add(new Area(ChainToPath2D(c)));
  }
  
  areaA.add(areaB); // Union
  
  Shape result = new Shape();
  
  // Extract all contours from the union
  PathIterator it = areaA.getPathIterator(null);
  float[] coords = new float[6];
  Chain currentChain = null;
  
  while (!it.isDone()) {
    int type = it.currentSegment(coords);
    
    if (type == PathIterator.SEG_MOVETO) {
      if (currentChain != null && currentChain.points.size() > 0) {
        result.chains.add(currentChain);
      }
      currentChain = new Chain();
      currentChain.AddPoint(coords[0], coords[1]);
    } else if (type == PathIterator.SEG_LINETO) {
      currentChain.AddPoint(coords[0], coords[1]);
    } else if (type == PathIterator.SEG_CLOSE) {
      if (currentChain != null && currentChain.points.size() > 0) {
        result.chains.add(currentChain);
      }
      currentChain = null;
    }
    
    it.next();
  }
  
  // Add final chain if exists
  if (currentChain != null && currentChain.points.size() > 0) {
    result.chains.add(currentChain);
  }
  
  return result;
}