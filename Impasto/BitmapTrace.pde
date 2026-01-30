ArrayList<Shape> BitMapTrace(PGraphics bitmap) {
  bitmap.loadPixels();
  ArrayList<Shape> shapes = new ArrayList<Shape>();
  boolean[] visited = new boolean[bitmap.width * bitmap.height];

  // Find all shapes by scanning for unvisited edges
  while (true) {
    // Find next unvisited edge pixel
    int startX = -1, startY = -1;
    for (int y = 0; y < bitmap.height - 1 && startX == -1; y++) {
      for (int x = 0; x < bitmap.width - 1; x++) {
        if (isEdge(bitmap, x, y, visited)) {
          startX = x;
          startY = y;
          break;
        }
      }
    }

    if (startX == -1) break; // No more edges found

    // Walk the boundary
    Shape tracedPath = new Shape();
    int x = startX, y = startY;
    int dir = 0; // Direction we're facing
    tracedPath.AddPoint(x, y);
    visited[y * bitmap.width + x] = true;

    // Moore-neighbor directions: N, NE, E, SE, S, SW, W, NW
    int[] dx = {0, 1, 1, 1, 0, -1, -1, -1};
    int[] dy = {-1, -1, 0, 1, 1, 1, 0, -1};

    do {
      boolean found = false;
      // Check neighbors clockwise
      for (int i = 0; i < 8; i++) {
        int checkDir = (dir + i) % 8;
        int nx = x + dx[checkDir];
        int ny = y + dy[checkDir];

        if (isEdge(bitmap, nx, ny, visited)) {
          x = nx;
          y = ny;
          tracedPath.AddPoint(x, y);
          visited[y * bitmap.width + x] = true;
          dir = (checkDir + 6) % 8; // Turn left for next search
          found = true;
          break;
        }
      }
      if (!found) break;
    } while (x != startX || y != startY);

    if (tracedPath.points.size() > 3) {
      shapes.add(tracedPath);
    }
  }

  return shapes;
}

boolean isEdge(PGraphics bitmap, int x, int y, boolean[] visited) {
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
