//take a 1-bit texture
//find the edges of the texture where the false and true data meet
//with the resulting edge data, simplify into a polygonal Path
Path BitMapTrace(boolean[][] bitmap) {
  Path tracedPath = new Path();
  int rows = bitmap.length;
  int cols = bitmap[0].length;

  // Simple edge detection: look for transitions from false to true
  for (int y = 0; y < rows - 1; y++) {
    for (int x = 0; x < cols - 1; x++) {
      if (bitmap[y][x] != bitmap[y][x + 1]) {
        tracedPath.AddPoint(x + 0.5, y);
      }
      if (bitmap[y][x] != bitmap[y + 1][x]) {
        tracedPath.AddPoint(x, y + 0.5);
      }
    }
  }

  return tracedPath;
}