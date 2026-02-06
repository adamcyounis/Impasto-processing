class BitMapTrace {
  PGraphics bitmap;
  Shape shape;
  IntVector startPos;
  BitMapTrace(PGraphics bitmap_) {
    bitmap = bitmap_;
    shape = Trace();
  }

  Shape Trace() {
    bitmap.loadPixels();
    Shape s = new Shape();
    boolean[] visited = new boolean[bitmap.width * bitmap.height];

    // Find all shapes by scanning for unvisited edges
    boolean hasMoreEdges = true;
    while (hasMoreEdges) {
      // Find next unvisited edge pixel
      startPos = new IntVector(-1, -1);
      for (int y = 0; y < bitmap.height - 1 && startPos.x == -1; y++) {
        for (int x = 0; x < bitmap.width - 1; x++) {
          if (isEdge(x, y, visited)) {
            startPos.x = x;
            startPos.y = y;
            break;
          }
        }
      }

      // Check if we found an edge
      if (startPos.x == -1) {
        hasMoreEdges = false;
      } else {
        Chain tracedPath = TraceChain(startPos, visited);

        if (tracedPath.NumPoints() > 3) {
          GetCanvas().chains.add(tracedPath);
          s.chains.add(tracedPath);
        }
      }
    }

    return s;
  }


  Chain TraceChain(IntVector start, boolean[] visited) {
    // Walk the boundary
    Chain tracedPath = new Chain();

    // Store original starting position
    int startX = start.x;
    int startY = start.y;

    // Current position
    IntVector current = new IntVector(start.x, start.y);
    int dir = 0; // Direction we're facing

    tracedPath.AddPoint(current.x, current.y);
    visited[current.y * bitmap.width + current.x] = true;

    int maxIterations = bitmap.width * bitmap.height; // Safety limit
    int iterations = 0;
    boolean continueTracing = true;
    boolean hasReturnedToStart = false;

    while (continueTracing && !hasReturnedToStart && iterations < maxIterations) {
      iterations++;
      int[] result = FindNextNeighbour(current, visited, dir);

      if (result == null) {
        continueTracing = false;
      } else {
        current.x = result[0];
        current.y = result[1];
        dir = result[2];
        tracedPath.AddPoint(current.x, current.y);
        visited[current.y * bitmap.width + current.x] = true;

        // Check if we've returned to the starting position
        hasReturnedToStart = (current.x == startX && current.y == startY);
      }
    }

    return tracedPath;
  }

  int[] FindNextNeighbour(IntVector pos, boolean[] visited, int dir) {
    // Moore-neighbor directions: N, NE, E, SE, S, SW, W, NW
    int[] dx = {0, 1, 1, 1, 0, -1, -1, -1};
    int[] dy = {-1, -1, 0, 1, 1, 1, 0, -1};

    // Check neighbors clockwise
    for (int i = 0; i < 8; i++) {
      int checkDir = (dir + i) % 8;
      int nx = pos.x + dx[checkDir];
      int ny = pos.y + dy[checkDir];

      if (isEdge(nx, ny, visited)) {
        int newDir = (checkDir + 6) % 8; // Turn left for next search
        return new int[]{nx, ny, newDir}; // Return new position and direction
      }
    }
    return null; // No neighbor found
  }

  boolean isEdge(int x, int y, boolean[] visited) {
    //out of bounds check
    if (x < 0 || x >= bitmap.width-1 || y < 0 || y >= bitmap.height-1) return false;
    //get current position
    int index = y * bitmap.width + x;
    //check if already visited
    if (visited[index]) return false;
    //return true if any neighbor pixel is different
    return bitmap.pixels[index] != bitmap.pixels[index + 1] ||
      bitmap.pixels[index] != bitmap.pixels[index + bitmap.width];
  }
}
