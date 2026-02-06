class BitMapTrace {
  PGraphics bitmap;
  Shape shape;
  IntVector startPos;
  boolean[][] visited;
  IntVector searchPos;

  BitMapTrace(PGraphics bitmap_) {
    bitmap = bitmap_;
    visited = new boolean[bitmap.height][bitmap.width];
    searchPos = new IntVector(0, 0); // Initialize search position once
    shape = Trace();
  }

  Shape Trace() {
    bitmap.loadPixels();
    shape = new Shape();

    // Scan through bitmap once, continuing from last position
    boolean hasMoreEdges = true;

    while (hasMoreEdges) {
      // Find next unvisited edge pixel, continuing from last position
      startPos = new IntVector(-1, -1);
      // Don't reset searchPos here - it should persist across iterations!

      boolean edgeFound = false;

      for (int y = searchPos.y; y < bitmap.height - 1 && !edgeFound; y++) {
        // Start from searchX only on the first row, otherwise start from 0
        int startX = (y == searchPos.y) ? searchPos.x : 0;

        for (int x = startX; x < bitmap.width - 1; x++) {
          if (isEdge(x, y)) {

            //print the colour of the pixel
            startPos.x = x;
            startPos.y = y;
            edgeFound = true;
            IncrementSearch();
            break;
          }
        }
      }

      // Check if we found an edge
      if (edgeFound) {
        Chain tracedPath = TraceChain(startPos);

        if (tracedPath.NumPoints() > 10) {
          shape.chains.add(tracedPath);
        }
      } else {
        hasMoreEdges = false;
      }
    }

    return shape;
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

    // Current position
    IntVector current = new IntVector(start.x, start.y);
    int dir = 0; // Direction we're facing

    Chain tracedPath = new Chain();
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
    IntVector[] directions = new IntVector[8];
    directions[0] = new IntVector(0, -1);   // N
    directions[1] = new IntVector(1, -1);   // NE
    directions[2] = new IntVector(1, 0);    // E
    directions[3] = new IntVector(1, 1);    // SE
    directions[4] = new IntVector(0, 1);    // S
    directions[5] = new IntVector(-1, 1);   // SW
    directions[6] = new IntVector(-1, 0);   // W
    directions[7] = new IntVector(-1, -1);  // NW

    // Check neighbors clockwise
    for (int i = 0; i < 8; i++) {
      int checkDir = (dir + i) % 8;
      int nx = pos.x + directions[checkDir].x;
      int ny = pos.y + directions[checkDir].y;

      if (isEdge(nx, ny)) {
        int newDir = (checkDir + 6) % 8; // Turn left for next search

        // If moving diagonally (odd direction), also mark the clockwise-adjacent cardinal neighbor as visited
        if (checkDir % 2 == 1) {
          int cardinalDir = (checkDir + 1) % 8; // Next clockwise direction
          int adjX = pos.x + directions[cardinalDir].x;
          int adjY = pos.y + directions[cardinalDir].y;

          if (adjX >= 0 && adjX < bitmap.width && adjY >= 0 && adjY < bitmap.height) {
            visited[adjY][adjX] = true;
          }
        }

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

    boolean rightEdge = (bitmap.pixels[index] != bitmap.pixels[index + 1]);
    boolean downEdge = (bitmap.pixels[index] != bitmap.pixels[index + bitmap.width]);
    //return true if any neighbor pixel is different
    return rightEdge || downEdge;
  }
}
