r_pipe = 0.01;
t_pipe = 0.025;
t_PCM = 0.3;
t_container = 0.025;
t_insulation = 0.05;
t = r_pipe + t_pipe + t_PCM + t_container + t_insulation;

H_PCM = 1;
H = H_PCM + 2*t_insulation + 2*t_container;

r_coil = 0.02;
n_coil = 10;
s_coil = H/(n_coil-1);
coil_center_x = t + 0.05;
coil_center_y = -H/2:H/2:s_coil;

t_air_x = 1;
t_air_y = 0.5;

e = 0.02;
e_metal = 0.005;
ee = 0.2;

Point(1) = {r_pipe, -H/2-t_air_y, 0, ee};
Point(2) = {r_pipe, -H/2, 0, e};
Point(3) = {r_pipe, H/2, 0, e};
Point(4) = {r_pipe, H/2+t_air_y, 0, ee};
Point(5) = {t+t_air_x, H/2+t_air_y, 0, ee};
Point(6) = {t+t_air_x, -H/2-t_air_y, 0, ee};

Point(7) = {r_pipe+t_pipe, -H/2, 0, e};
Point(8) = {r_pipe+t_pipe, -H/2+t_insulation, 0, e_metal};
Point(9) = {r_pipe+t_pipe, -H_PCM/2, 0, e};
Point(10) = {r_pipe+t_pipe, H_PCM/2, 0, e};
Point(11) = {r_pipe+t_pipe, H/2-t_insulation, 0, e_metal};
Point(12) = {r_pipe+t_pipe, H/2, 0, e};

Point(13) = {r_pipe+t_pipe+t_PCM, H_PCM/2, 0, e_metal};
Point(14) = {r_pipe+t_pipe+t_PCM, -H_PCM/2, 0, e_metal};

Point(15) = {r_pipe+t_pipe+t_PCM+t_container, H/2-t_insulation, 0, e_metal};
Point(16) = {r_pipe+t_pipe+t_PCM+t_container, -H/2+t_insulation, 0, e_metal};

Point(17) = {t, H/2, 0, e};
Point(18) = {t, -H/2, 0, e};

// pipe
Line(1) = {2, 3};
Line(2) = {3, 12};
Line(3) = {12, 11};
Line(4) = {11, 10};
Line(5) = {10, 9};
Line(6) = {9, 8};
Line(7) = {8, 7};
Line(8) = {7, 2};
Line Loop(1) = {1, 2, 3, 4, 5, 6, 7, 8};
Plane Surface(1) = {1};

// PCM
Line(9) = {10, 13};
Line(10) = {13, 14};
Line(11) = {14, 9};
Line Loop(2) = {-5, 9, 10, 11};
Plane Surface(2) = {2};

// container
Line(12) = {11, 15};
Line(13) = {15, 16};
Line(14) = {16, 8};
Line Loop(3) = {-4, 12, 13, 14, -6, -11, -10, -9};
Plane Surface(3) = {3};

// insulation
Line(15) = {12, 17};
Line(16) = {17, 18};
Line(17) = {18, 7};
Line Loop(4) = {-3, 15, 16, 17, -7, -14, -13, -12};
Plane Surface(4) = {4};

// coils (cross sections)
coilll[] = {};
coilp[] = {};
coils[] = {};
For i In {0:n_coil-1}
  idp = newp;
  idc = newc;
  idll = newll;
  ids = news;
  coilll += {idll};
  coilp += {idp+1};
  coilp += {idp+2};
  coilp += {idp+3};
  coilp += {idp+4};
  coils += {ids};

  Point(idp) = {coil_center_x, coil_center_y[i], 0, e};
  Point(idp+1) = {coil_center_x-r_coil, coil_center_y[i], 0, e};
  Point(idp+2) = {coil_center_x, coil_center_y[i]-r_coil, 0, e};
  Point(idp+3) = {coil_center_x+r_coil, coil_center_y[i], 0, e};
  Point(idp+4) = {coil_center_x, coil_center_y[i]+r_coil, 0, e};

  Circle(idc) = {idp+1, idp, idp+2};
  Circle(idc+1) = {idp+2, idp, idp+3};
  Circle(idc+2) = {idp+3, idp, idp+4};
  Circle(idc+3) = {idp+4, idp, idp+1};

  Line Loop(idll) = {idc, idc+1, idc+2, idc+3};
  Plane Surface(ids) = {idll};
EndFor

// air
idp = newp;
idll = newll;
ids = news;
airll[] = {idll};
For i In {0:n_coil-1}
  airll += {coilll[i]};
  Printf("coils[%.0f] = %.0f", i, coils[i]);
EndFor

For i In {0:n_coil}
  Printf("airll[%.0f] = %.0f", i, airll[i]);
EndFor

Line(idp) = {3, 4};
Line(idp+1) = {4, 5};
Line(idp+2) = {5, 6};
Line(idp+3) = {6, 1};
Line(idp+4) = {1, 2};
Line Loop(idll) = {idp, idp+1, idp+2, idp+3, idp+4, -8, -17, -16, -15, -2};
Plane Surface(ids) = {58, 18, 22, 26, 30, 34, 38, 42, 46, 50, 54};
// Plane Surface(ids) = airll;

Physical Surface("pipe") = {1};
Physical Surface("PCM") = {2};
Physical Surface("container") = {3};
Physical Surface("insulation") = {4};
Physical Surface("coil") = {18:54:4};
Physical Surface("air") = {58};
