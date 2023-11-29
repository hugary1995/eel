ma = 1; // matrix side length
mt = 0.05; // matrix thickness
fa = 0.5; // fiber length
fr = 0.02; // fiber radius
e = 0.02; // element size

SetFactory('OpenCASCADE');

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
Point(5) = {ma/2, ma/2-fa/2, mt/2, e};
Point(6) = {ma/2+fr, ma/2-fa/2, mt/2, e};
Point(7) = {ma/2, ma/2-fa/2, mt/2+fr, e};
Point(8) = {ma/2-fr, ma/2-fa/2, mt/2, e};
Point(9) = {ma/2, ma/2-fa/2, mt/2-fr, e};
Circle(5) = {6, 5, 7};
Circle(6) = {7, 5, 8};
Circle(7) = {8, 5, 9};
Circle(8) = {9, 5, 6};
Line Loop(2) = {5, 6, 7, 8};
Plane Surface(2) = {2};

Extrude {0, 0, mt} {Surface{1};}
Extrude {0, fa, 0} {Surface{2};}

BooleanFragments{Volume{1,2}; Delete;}{}

Physical Volume("fiber") = {2};
Physical Volume("matrix") = {3};
Physical Surface("top") = {18};
Physical Surface("bottom") = {13};
Physical Surface("left") = {14};
Physical Surface("right") = {15};
