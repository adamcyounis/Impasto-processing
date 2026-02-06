class BitMapTrace {
  PGraphics bitmap;
  Shape shape;
  IntVector startPos;
  boolean[][] visited;
  IntVector searchPos;
  BitMapTrace(PGraphics bitmap_) {
    bitmap = bitmap_;
    visited = new boolean[bitmap.height][bitmap.width];
    shape = Trace();
  }

  Shape Trace() {
    bitmap.loadPixels();
    Shape s = new Shape();

    // Scan through bitmap once, continuing from last position
    boolean hasMoreEdges = true;

    while (hasMoreEdges) {
      // Find next unvisited edge pixel, continuing from last position
      startPos = new IntVector(-1, -1);
      searchPos = new IntVector(0, 0);

      boolean edgeFound = false;

      for (int y = searchPos.y; y < bitmap.height - 1 && !edgeFound; y++) {
        // Start from searchX only on the first row, otherwise start from 0
        int startX = (y == searchPos.y) ? searchPos.x : 0;

        for (int x = startX; x < bitmap.width - 1; x++) {
          if (isEdge(x, y)) {
            startPos.x = x;
            startPos.y = y;
            edgeFound = true;
            IncrementSearch();
            break;
          }
        }
      }

      // Check if we found an edge
      if (!edgeFound) {
        hasMoreEdges = false;
      } else {
        Chain tracedPath = TraceChain(startPos);

        if (tracedPath.NumPoints() > 3) {
          GetCanvas().chains.add(tracedPath);
          s.chains.add(tracedPath);
        }
      }
    }

    return s;
  }

  void IncrementSearch() {
    // Update search position to continue from next pixel
    searchPos.x = startPos.x + 1;
    searchPos.y = startPos.y;
    // Handle wrapping to next row
    if (searchPos.x >= bitmap.width - 1) {
      searchPos.x = 0;
      searchPos.y = startPos.y + 1;
    }
  }

  Chain TraceChain(IntVector start) {
    // Walk the boundary
    Chain tracedPath = new Chain();

    // Store original starting position

    // Current position
    IntVector current = new IntVector(start.x, start.y);
    int dir = 0; // Direction we're facing

    tracedPath.AddPoint(current.x, current.y);
    visited[current.y][current.x] = true;

    int maxIterations = bitmap.width * bitmap.height; // Safety limit
    int iterations = 0;
    boolean continueTracing = true;
    boolean hasReturnedToStart = false;

    while (continueTracing && !hasReturnedToStart && iterations < maxIterations) {
      iterations++;
      int[] result = FindNextNeighbour(current, dir);

      if (result == null) {
        continueTracing = false;
      } else {
        current.x = result[0];
        current.y = result[1];
        dir = result[2];
        tracedPath.AddPoint(current.x, current.y);
        visited[current.y][current.x] = true;

        // Check if we've returned to the starting position
        hasReturnedToStart = (current.x == start.x && current.y == start.y);
      }
    }

    return tracedPath;
  }

  int[] FindNextNeighbour(IntVector pos, int dir) {
    // Moore-neighbor directions: N, NE, E, SE, S, SW, W, NW
    int[] dx = {0, 1, 1, 1, 0, -1, -1, -1};
    int[] dy = {-1, -1, 0, 1, 1, 1, 0, -1};

    // Check neighbors clockwise
    for (int i = 0; i < 8; i++) {
      int checkDir = (dir + i) % 8;
      int nx = pos.x + dx[checkDir];
      int ny = pos.y + dy[checkDir];

      if (isEdge(nx, ny)) {
        int newDir = (checkDir + 6) % 8; // Turn left for next search
        return new int[]{nx, ny, newDir}; // Return new position and direction
      }
    }
    return null; // No neighbor found
  }

  boolean isEdge(int x, int y) {
    //out of bounds check
    if (x < 0 || x >= bitmap.width-1 || y < 0 || y >= bitmap.height-1) return false;
    //get current position
    int index = y * bitmap.width + x;
    //check if already visited
    if (visited[y][x]) return false;
    //return true if any neighbor pixel is different
    return bitmap.pixels[index] != bitmap.pixels[index + 1] ||
      bitmap.pixels[index] != bitmap.pixels[index + bitmap.width];
  }
}
