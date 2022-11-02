W = 0.03;
L1 = 0.05;
L2 = 0.08;
L3 = 0.12;
R = 0.01;
e = 0.005;

Point(1) = {0, 0, 0, e};
Point(2) = {0, W, 0, e};
Point(3) = {L1, W, 0, e};
Point(4) = {L2, W, 0, e};
Point(5) = {L3, W, 0, e};
Point(6) = {L3, 0, 0, e};
Point(7) = {L2, 0, 0, e};
Point(8) = {L1, 0, 0, e};

Point(9) = {L1/2, W/2, 0, e};
Point(10) = {L1/2+R, W/2, 0, e};
Point(11) = {L1/2, W/2+R, 0, e};
Point(12) = {L1/2-R, W/2, 0, e};
Point(13) = {L1/2, W/2-R, 0, e};

Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 5};
Line(5) = {5, 6};
Line(6) = {6, 7};
Line(7) = {7, 8};
Line(8) = {8, 1};
Line(9) = {3, 8};
Line(10) = {4, 7};

Circle(11) = {10, 9, 11};
Circle(12) = {11, 9, 12};
Circle(13) = {12, 9, 13};
Circle(14) = {13, 9, 10};

Line Loop(1) = {1, 2, 9, 8};
Line Loop(2) = {-9, 3, 10, 7};
Line Loop(3) = {-10, 4, 5, 6};
Line Loop(4) = {11, 12, 13, 14};

Plane Surface(1) = {4};
Plane Surface(2) = {1, 4};
Plane Surface(3) = {2};
Plane Surface(4) = {3};

Physical Line("left") = {1};
Physical Line("right") = {5};
Physical Line("top") = {2, 3, 4};
Physical Line("bottom") = {6, 7, 8};
Physical Surface("cp") = {1};
Physical Surface("cm") = {2};
Physical Surface("e") = {3};
Physical Surface("a") = {4};
