SetFactory("OpenCASCADE");

// Axisymmetry, unit: inch
pipe_e = 2.75;
pipe_t = 0.028;
pipe_Ri = 0.444/2;
pipe_Ro = pipe_Ri+pipe_t;
pipe_H = pipe_e+6.3125+pipe_e;
container_y = pipe_e;
container_H = 6.3125;
container_Ro = 4.5/2;
container_t = container_Ro-pipe_Ri-pipe_t;
top_t = 3/16;
bottom_t = 1/4;
medium_R = 3.8064/2;
medium_H = 5.4375;
medium_t = medium_R-pipe_Ro;

n_coil = 14; // number of coils
coil_R = 6; // coil turns radius, assuming a 5 mm gap
coil_w = 1; // coil cross section width
coil_t = 0.55; // coil cross section thickness
coil_L = 10; // coil span
coil_S = (coil_L-coil_t*n_coil)/(n_coil-1); // coil spacing
coil_y = (pipe_H-coil_L)/2;

insul_R = container_Ro+3;
insul_t = insul_R-pipe_Ro;
insul_H = (container_H+coil_L)/2;
fbrick_y = coil_y;

air_R = coil_R+coil_w/2+2;

// HT pipe
Rectangle(1) = {0, 0, 0, pipe_Ri, pipe_H, 0};
Rectangle(2) = {pipe_Ri, 0, 0, pipe_t, pipe_H, 0};

// Insulation
Rectangle(3) = {pipe_Ro, container_y, 0, insul_t, insul_H, 0};
Rectangle(4) = {pipe_Ro, fbrick_y, 0, insul_t, (coil_L-container_H)/2, 0};

// Container
Rectangle(5) = {pipe_Ro, container_y, 0, container_t, container_H, 0};
Rectangle(6) = {pipe_Ro, container_y+bottom_t, 0, medium_t, container_H-top_t-bottom_t, 0};

// Medium
Rectangle(7) = {pipe_Ro, container_y+bottom_t, 0, medium_t, medium_H, 0};

// Fragments
s() = BooleanFragments{ Surface{1}; Delete; }{ Surface{2:7}; Delete; };

// Mesh size
MeshSize{ PointsOf{ Surface{:}; }} = 0.2;

// Groups
Physical Surface("pipe") = {2};
Physical Surface("insulation") = {9};
Physical Surface("fbrick") = {4};
Physical Surface("container") = {8};
Physical Surface("medium") = {7};
Physical Surface("air") = {10};
Physical Line("bottom") = {9};
Physical Line("insulation_outer") = {11, 26};
