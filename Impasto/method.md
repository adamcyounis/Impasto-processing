Method
- drop all points into quadtrees with a cel size as large as the brush radius
- run a delaunay triangulation over everything within 2 cells of eachother
- go clockwise over all of the triangulated points to find the outline
- turn the outline into control points, make them relaxed

- when the next stroke gets made, do the same thing and overlap 
- importantly, don't relax points between strokes