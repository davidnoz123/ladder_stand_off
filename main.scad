use <ladder_parts.scad>
include <ladder_calc.scad>


beam_length = 2200;

// T beam dimensions
web_thickness = 30;
web_height = 40;

flange_width = 80;
flange_thickness = 10;

// guide settings
guide_length = 1000;
wall = 18;

// clearances
side_clear = 2;
top_clear = 2;
bottom_clear = 2;

c_spine_top = web_height + flange_thickness + top_clear + wall;


plate_height = 180;     // X
plate_width = 600;      // Y
plate_thickness = 18;   // Z
plate_offset_z = c_spine_top + 200;

plate_center_x = 0;

top_board_depth = 200;
top_board_thickness = 18;
hinge_angle = 90;


guide_x_center = 0;
guide_top_z = web_height + flange_thickness + top_clear + wall;

x_vertex_offset = 500;
v_z_thickness = 18;
v_arm_width = 18;
v_vertex_block_size = 24;




bar_width = 18;
bar_depth = 18;

bar_bottom_z =
    web_height + flange_thickness + top_clear + wall / 2;
    
    

rows = build_cut_rows();
echo_cut_list(rows);

color([0.7, 0.45, 0.25])
t_beam(
    beam_length,
    web_thickness,
    web_height,
    flange_width,
    flange_thickness
);

color([0.9, 0.8, 0.6])
c_guide(
    beam_length,
    guide_length,
    wall,
    web_thickness,
    web_height,
    flange_width,
    flange_thickness,
    side_clear,
    top_clear,
    bottom_clear
);



color([0.85, 0.75, 0.55])
hanging_plate(
    beam_length,
    guide_length,
    plate_height,
    plate_width,
    plate_thickness,
    plate_offset_z,
    plate_center_x
);






color([0.80, 0.68, 0.50])
hinged_top_board(
    beam_length,
    guide_length,
    plate_height,
    plate_width,
    plate_thickness,
    plate_offset_z + plate_thickness,
    top_board_depth,
    top_board_thickness,
    plate_center_x + top_board_thickness,
    hinge_angle
);


color([0.55, 0.35, 0.20])
v_frame_in_c_spine_plane(
    beam_length,
    guide_length,
    flange_width,
    side_clear,
    wall,
    web_height,
    flange_thickness,
    top_clear,
    x_vertex_offset,
    v_z_thickness,
    v_arm_width,
    v_vertex_block_size,
    v_angle_deg = 45
);

