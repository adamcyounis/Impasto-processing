## To Do
- [ ] Add offsets for control points when simplifying shapes to preserve bends
- [ ] Unify shapes of the same colour drawn on top of each other
- [ ] Detect holes in shapes rather than just resolving outlines


## contour data structure rationalisation
- Shapes contain a bounding edge chain that forms the perimeter
- A contour is an edge chain that falls within a parent shape.
- Shapes can have a list of contours, but never need to nest within each other. Simply a flat data structure.
- Contours are always considered "negative space" within the shape they belong to
- Edge chains are stored "by reference" in the application, such that modifying an edge will cause any shapes that use it to have their appearance affected.

Look up Avalonia 