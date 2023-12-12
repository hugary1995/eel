ma = 1; // matrix side length
fa = 0.5; // fiber length
e = 0.2; // element size

// matrix
Point(1) = {0, 0, 0, e};
Point(2) = {ma, 0, 0, e};
Point(3) = {ma, ma, 0, e};
Point(4) = {0, ma, 0, e};
Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};
Line Loop(1) = {1, 2, 3, 4};
Plane Surface(1) = {1};

// fiber
Point(5) = {ma/2, ma/2-fa/2, 0, e};
Point(6) = {ma/2, ma/2+fa/2, 0, e};
Line(5) = {5, 6};
Line {5} In Surface {1};

Physical Surface('matrix') = {1};
Physical Line('fiber') = {5};
Physical Line('top') = {3};
Physical Line('bottom') = {1};
Physical Line('left') = {4};
Physical Line('right') = {2};
