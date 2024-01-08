fa = 0.5; // fiber length
fr = 0.02; // fiber radius

s = 0.25; // padding between matrix boundaries and fiber
mx = fa+2*s;
my = 2*s;
mz = 2*s;

e = 0.015; // element size


SetFactory('OpenCASCADE');

// matrix
Point(1) = {0, 0, 0, e};
Point(2) = {mx, 0, 0, e};
Point(3) = {mx, my, 0, e};
Point(4) = {0, my, 0, e};
Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};
Line Loop(1) = {1, 2, 3, 4};
Plane Surface(1) = {1};

// fiber
Point(5) = {s, s, s, e};
Point(6) = {s, s-fr, s, e};
Point(7) = {s, s, s+fr, e};
Point(8) = {s, s+fr, s, e};
Point(9) = {s, s, s-fr, e};
Circle(5) = {6, 5, 7};
Circle(6) = {7, 5, 8};
Circle(7) = {8, 5, 9};
Circle(8) = {9, 5, 6};
Line Loop(2) = {5, 6, 7, 8};
Plane Surface(2) = {2};

Extrude {0, 0, mz} {Surface{1};}
Extrude {fa, 0, 0} {Surface{2};}

BooleanFragments{Volume{1,2}; Delete;}{}

Physical Volume("fiber") = {2};
Physical Volume("matrix") = {3};
Physical Surface("top") = {18};
Physical Surface("bottom") = {13};
Physical Surface("left") = {14};
Physical Surface("right") = {15};
Physical Surface("front") = {17};
Physical Surface("back") = {16};
