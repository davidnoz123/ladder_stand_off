use <ladder_parts.scad>
use <gap_mechanism.scad>
include <ladder_calc.scad>


beam_length = 2200;

// T beam dimensions
web_thickness = 30;
web_height = 40;

flange_width = 80;
flange_thickness = 10;

// guide settings
guide_length = 450;
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
    
    

packer_length_y = 80;                 // length along guide
packer_thickness_z = plate_thickness; // same thickness as hanging panel
packer_back_offset_z = guide_top_z - plate_thickness;        // extra gap behind guide for hinge clearance

packer_size_x = flange_width + (side_clear  + wall) * 2;
packer_offset_x = 0;
    // shared placement





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
    bottom_clear,
    include_top_plate = false   // guide_block() in deployed_layout_params provides the top face
);



// --- LOCAL CHANGE: hanging_plate replaced by plate_block_with_slots in deployed_layout_params ---
// color([0.85, 0.75, 0.55])
// hanging_plate(
//     beam_length, guide_length,
//     plate_height, plate_width, plate_thickness,
//     plate_offset_z, plate_center_x
// );
// --- END LOCAL CHANGE ---






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


// --- LOCAL CHANGE: guide_side_packers dropped (no longer needed) ---
// color([0.82, 0.70, 0.52])
// guide_side_packers( ... );
// --- END LOCAL CHANGE ---








// --- LOCAL CHANGE: gap mechanism integration ---
// Axis mapping:  gap_mech X (away from guide) -> main +Z
//                gap_mech Y (arm heights)     -> main +Y (along beam)
//                gap_mech Z (across width)    -> main -X
// Rotations applied inside-out: rotate([0,90,0]) maps axes, then rotate([0,0,90]) spins around main Z.
// Anchor: guide face coincides with c_spine_top face; centred along beam in Y.
mechanism_guide_w = flange_width + (side_clear + wall) * 2;

translate([-plate_height/2, beam_length/2, c_spine_top])
    rotate([0, 180, 0])
    rotate([0, 0, 90])
    rotate([0, 90, 0])
        deployed_layout_params(
            p_guide_t = wall,
            p_guide_h = mechanism_guide_w,
            p_guide_w = guide_length,
            p_plate_t = plate_thickness,
            p_plate_h = plate_height,
            p_plate_w = plate_width,
            p_gap     = plate_offset_z - c_spine_top,
            p_guide_y_offset = (plate_height - mechanism_guide_w) / 2
        );
// --- END LOCAL CHANGE ---










// ---------- OLD arm code (superseded by deployed_layout_params) ----------
// The variables and modules below are kept for reference but are no longer
// rendered.  See the deployed_layout_params() call above.

// arm_size_x = 20;  arm_size_y = 18;  arm_size_z = 30;
// upper_hinge_drop_x = arm_size_x;   lower_hinge_drop_x = arm_size_x * 2;
// arm_hinge_back_offset_z = 0;
// upper_arm_length = 500;  upper_arm_angle_deg = -35;
// lower_arm_length = 500;  lower_arm_angle_deg = -35;
// arm_clearance_z = 1;
// (yz_block, yz_arm_between_points, angled_yz_arm modules omitted)
// ---------- END OLD arm code ----------