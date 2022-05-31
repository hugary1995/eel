pipeir = 0.0056; // pipe inner radius
pipeor = 0.00635; // pipe outer radius
pipeh = 0.299; // pipe height
pcmor = 0.08; // PCM outer radius
pcmh = 0.1574; // PCM height

e = 1;

Point(1) = {0, pipeh/2, 0, e};
Point(2) = {pipeir, pipeh/2, 0, e};
Point(3) = {pipeor, pipeh/2, 0, e};
Point(4) = {0, pcmh/2, 0, e};
Point(5) = {pipeir, pcmh/2, 0, e};
Point(6) = {pipeor, pcmh/2, 0, e};
Point(7) = {pcmor, pcmh/2, 0, e};
Point(8) = {0, -pcmh/2, 0, e};
Point(9) = {pipeir, -pcmh/2, 0, e};
Point(10) = {pipeor, -pcmh/2, 0, e};
Point(11) = {pcmor, -pcmh/2, 0, e};
Point(12) = {0, -pipeh/2, 0, e};
Point(13) = {pipeir, -pipeh/2, 0, e};
Point(14) = {pipeor, -pipeh/2, 0, e};

Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {4, 5};
Line(4) = {5, 6};
Line(5) = {6, 7};
Line(6) = {8, 9};
Line(7) = {9, 10};
Line(8) = {10, 11};
Line(9) = {12, 13};
Line(10) = {13, 14};

Line(11) = {1, 4};
Line(12) = {2, 5};
Line(13) = {3, 6};
Line(14) = {4, 8};
Line(15) = {5, 9};
Line(16) = {6, 10};
Line(17) = {7, 11};
Line(18) = {8, 12};
Line(19) = {9, 13};
Line(20) = {10, 14};

Line Loop(1) = {11, 3, -12, -1};
Line Loop(2) = {12, 4, -13, -2};
Line Loop(3) = {14, 6, -15, -3};
Line Loop(4) = {15, 7, -16, -4};
Line Loop(5) = {16, 8, -17, -5};
Line Loop(6) = {18, 9, -19, -6};
Line Loop(7) = {19, 10, -20, -7};

Plane Surface(1) = {1};
Plane Surface(2) = {2};
Plane Surface(3) = {3};
Plane Surface(4) = {4};
Plane Surface(5) = {5};
Plane Surface(6) = {6};
Plane Surface(7) = {7};

Transfinite Line {1, 3, 6, 9} = 4 Using Progression 1;
Transfinite Line {2, 4, 7, 10} = 2 Using Progression 1;
Transfinite Line {5, 8} = 10 Using Progression 1.2;

Transfinite Line {11, 12, 13} = 6 Using Progression 1;
Transfinite Line {14, 15, 16, 17} = 11 Using Progression 1;
Transfinite Line {18, 19, 20} = 6 Using Progression 1;

Transfinite Surface {1, 2, 3, 4, 5, 6, 7};
Recombine Surface {1, 2, 3, 4, 5, 6, 7};

Physical Surface("gas") = {1, 3, 6};
Physical Surface("pipe") = {2, 4, 7};
Physical Surface("PCM") = {5};

Physical Line("PCM_left") = {16};
Physical Line("PCM_right") = {17};
Physical Line("inlet") = {9};
Physical Line("outlet") = {1};
Physical Line("wall") = {12, 15, 19};
Physical Line("insul") = {13, 5, 8, 20};
