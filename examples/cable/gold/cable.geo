r0 = 6;
r1 = 20;
r2 = 30;
r3 = 34;

e = 3;
ee = 1;

pc = 1;
lc = 1;
llc = 1;
sc = 1;

cx = 0;
cy = 0;
Point(pc++) = {cx, cy, 0, ee};
Point(pc++) = {cx+r0, cy, 0, ee};
Point(pc++) = {cx, cy+r0, 0, ee};
Point(pc++) = {cx-r0, cy, 0, ee};
Point(pc++) = {cx, cy-r0, 0, ee};
Circle(lc++) = {pc-4, pc-5, pc-3};
Circle(lc++) = {pc-3, pc-5, pc-2};
Circle(lc++) = {pc-2, pc-5, pc-1};
Circle(lc++) = {pc-1, pc-5, pc-4};
Line Loop(llc++) = {lc-4, lc-3, lc-2, lc-1};
Plane Surface(sc++) = {llc-1};
Point {1} In Surface {1};

For i In {0:5:1}
  cx = (2*r0+1)*Cos(i*60*Pi/180);
  cy = (2*r0+1)*Sin(i*60*Pi/180);
  Point(pc++) = {cx, cy, 0, ee};
  Point(pc++) = {cx+r0, cy, 0, ee};
  Point(pc++) = {cx, cy+r0, 0, ee};
  Point(pc++) = {cx-r0, cy, 0, ee};
  Point(pc++) = {cx, cy-r0, 0, ee};
  Circle(lc++) = {pc-4, pc-5, pc-3};
  Circle(lc++) = {pc-3, pc-5, pc-2};
  Circle(lc++) = {pc-2, pc-5, pc-1};
  Circle(lc++) = {pc-1, pc-5, pc-4};
  Line Loop(llc++) = {lc-4, lc-3, lc-2, lc-1};
  Plane Surface(sc++) = {llc-1};
EndFor

cx = 0;
cy = 0;
Point(pc++) = {cx, cy, 0, e};
Point(pc++) = {cx+r1, cy, 0, e};
Point(pc++) = {cx, cy+r1, 0, e};
Point(pc++) = {cx-r1, cy, 0, e};
Point(pc++) = {cx, cy-r1, 0, e};
Circle(lc++) = {pc-4, pc-5, pc-3};
Circle(lc++) = {pc-3, pc-5, pc-2};
Circle(lc++) = {pc-2, pc-5, pc-1};
Circle(lc++) = {pc-1, pc-5, pc-4};
Line Loop(llc++) = {lc-4, lc-3, lc-2, lc-1};
Plane Surface(sc++) = {llc-1, llc-2, llc-3, llc-4, llc-5, llc-6, llc-7, llc-8};

cx = 0;
cy = 0;
Point(pc++) = {cx, cy, 0, e};
Point(pc++) = {cx+r2, cy, 0, e};
Point(pc++) = {cx, cy+r2, 0, e};
Point(pc++) = {cx-r2, cy, 0, e};
Point(pc++) = {cx, cy-r2, 0, e};
Circle(lc++) = {pc-4, pc-5, pc-3};
Circle(lc++) = {pc-3, pc-5, pc-2};
Circle(lc++) = {pc-2, pc-5, pc-1};
Circle(lc++) = {pc-1, pc-5, pc-4};
Line Loop(llc++) = {lc-4, lc-3, lc-2, lc-1};
Plane Surface(sc++) = {llc-1, llc-2};

cx = 0;
cy = 0;
Point(pc++) = {cx, cy, 0, e};
Point(pc++) = {cx+r3, cy, 0, e};
Point(pc++) = {cx, cy+r3, 0, e};
Point(pc++) = {cx-r3, cy, 0, e};
Point(pc++) = {cx, cy-r3, 0, e};
Circle(lc++) = {pc-4, pc-5, pc-3};
Circle(lc++) = {pc-3, pc-5, pc-2};
Circle(lc++) = {pc-2, pc-5, pc-1};
Circle(lc++) = {pc-1, pc-5, pc-4};
Line Loop(llc++) = {lc-4, lc-3, lc-2, lc-1};
Plane Surface(sc++) = {llc-1, llc-2};

Extrude {0, 0, 30} {
  Surface{9}; Surface{10}; Surface{8}; Surface{4}; Surface{1}; Surface{3}; Surface{2}; Surface{7}; Surface{6}; Surface{5}; Curve{33}; Curve{37}; Curve{38}; Curve{34}; Curve{35}; Curve{39}; Curve{40}; Curve{36}; Curve{32}; Curve{29}; Curve{30}; Curve{31}; Curve{19}; Curve{20}; Curve{17}; Curve{18}; Curve{15}; Curve{14}; Curve{13}; Curve{16}; Curve{11}; Curve{10}; Curve{9}; Curve{12}; Curve{6}; Curve{1}; Curve{2}; Curve{3}; Curve{4}; Curve{7}; Curve{8}; Curve{5}; Curve{25}; Curve{26}; Curve{27}; Curve{28}; Curve{24}; Curve{21}; Curve{22}; Curve{23}; 
}

Physical Volume("conductor") = {4, 5, 6, 7, 8, 9, 10};
Physical Volume("insulator") = {1};
Physical Volume("jacket") = {2};
Physical Volume("air") = {3};
Physical Surface("conductor_top") = {330, 440, 418, 396, 374, 352, 308};
Physical Surface("conductor_bottom") = {1, 2, 3, 4, 5, 6, 7};
Physical Surface("air_top") = {286};
Physical Surface("air_bottom") = {8};
Physical Surface("insulator_top") = {82};
Physical Surface("insulator_bottom") = {9};
Physical Surface("jacket_top") = {124};
Physical Surface("jacket_bottom") = {10};
Physical Surface("outer") = {107, 103, 99, 95};
Physical Point("center") = {1};
Physical Point("pinx") = {2};
Physical Point("piny") = {3};
