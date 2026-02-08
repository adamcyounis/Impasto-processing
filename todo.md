## To Do

- [x] Add offsets for control points when simplifying shapes to preserve bends
- [ ] Unify shapes of the same colour drawn on top of each other

-------------------------

- [ ] Detect holes in shapes rather than just resolving outlines

- [ ] add colour selectors
- [ ] add palette
- [ ] add fill / ink drop
- [ ] add marquee selection and cutting/ slicing
- [ ] add selection and dragging
- [ ] add control point modification
- [ ] primitive shapes
- [ ] image import? 
- [ ] text support?

## contour data structure rationalisation
- Shapes contain a bounding edge chain that forms the perimeter
- A contour is an edge chain that falls within a parent shape.
- Shapes can have a list of contours, but never need to nest within each other. Simply a flat data structure.
- Contours are always considered "negative space" within the shape they belong to
- Edge chains are stored "by reference" in the application, such that modifying an edge will cause any shapes that use it to have their appearance affected.

Look up Avalonia 
Ramer–Douglas–Peucker



## concave control point solution pseudocode
- 

Flash has two kinds of logic depending on whether the angle is concave or convex. Convex angles always have the control points be a straight line, while concave angles have handles that behave independently


## shape unify pseudocode
- if any area on the new shape intersects with any area on any other chain
- (later, we'll compare brush colours, but not necessary now)
- then 