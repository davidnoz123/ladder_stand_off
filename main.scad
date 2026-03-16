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

// guide and beam sliding position
guide_centre_y        = beam_length / 2;
ladder_retraction     = -50;    // how far the ladder assembly is pulled back in X
beam_slide_percentage = 0.5;  // 0 = slid to one end, 1 = other end, 0.5 = centred
beam_slide_y          = (beam_slide_percentage - 0.5) * (beam_length - guide_length);

c_spine_top = web_height + flange_thickness + top_clear + wall;


plate_height = 180;     // X
plate_width = 600;      // Y
plate_thickness = 18;   // Z

// plate_offset_z: Z position of the plate face on the wall (primary anchor)
plate_offset_z = c_spine_top + 200;   // explicit — change this to move the plate in Z

// --- LOCAL CHANGE: animate stand_off_gap ---
// Use View > Animate in OpenSCAD; set FPS and Steps, then play.
// $t runs 0 -> 1 over the animation cycle.
stand_off_gap_min =  50;   // folded / retracted
stand_off_gap_max = 450;   // fully deployed — capped so V-tip can reach plate (must be < x_vertex_offset)
stand_off_gap = stand_off_gap_min + $t * (stand_off_gap_max - stand_off_gap_min);
// --- END LOCAL CHANGE ---

// derived: how far to shift the ladder assembly in Z so guide face meets plate - gap
ladder_z_offset = plate_offset_z - stand_off_gap - c_spine_top;

plate_center_x = 0;

top_board_depth = 200;
top_board_thickness = 18;
hinge_angle = 90;


guide_top_z = web_height + flange_thickness + top_clear + wall;

x_vertex_offset = 500;
v_z_thickness = 18;
v_arm_width = 18;
v_vertex_block_size = 24;

// --- LOCAL CHANGE: derive V-frame angle so tip just touches the plate face ---
// Mirrors the internal geometry of v_frame_in_c_spine_plane.
v_inner_width     = flange_width + side_clear * 2;
v_arm_x           = wall;
v_x_shift         = -wall - v_arm_x / 2;
v_hinge_x         = -v_inner_width / 2 + v_x_shift + v_arm_x / 2;
v_z_center        = web_height + flange_thickness + top_clear + wall / 2;
v_hinge_z_local   = v_z_center + v_z_thickness / 2;

v_dx              = (-x_vertex_offset + v_x_shift) - v_hinge_x;  // negative
v_dz              = v_z_center - v_hinge_z_local;                 // = -v_z_thickness/2

// Solve A*sin(a) + B*cos(a) = v_rhs  →  R*sin(a + phi) = v_rhs
v_A               = -v_dx;
v_B               = v_dz;
v_R               = sqrt(v_A * v_A + v_B * v_B);
v_phi             = atan2(v_B, v_A);
v_rhs             = stand_off_gap + c_spine_top - v_hinge_z_local;
v_frame_angle_deg = asin(v_rhs / v_R) - v_phi;

// V tip world position at current deployment
v_tip_x_local     = v_hinge_x + v_dx * cos(v_frame_angle_deg) + v_dz * sin(v_frame_angle_deg);
v_tip_world_x     = -ladder_retraction + v_tip_x_local;
v_board_thickness = 18;
// --- END LOCAL CHANGE ---




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

mechanism_guide_w = flange_width + (side_clear + wall) * 2;
mechanism_top_y   = plate_height / 2 + mechanism_pair_spacing();

// ---- ladder assembly: t_beam + c_guide + v_frame + guide_block + arms ----
// ---- adjust ladder_retraction (X) to retract ladder; stand_off_gap drives Z via ladder_z_offset ----
translate([-ladder_retraction, 0, ladder_z_offset])
{
    color([0.7, 0.45, 0.25])
    translate([0, guide_centre_y - beam_length/2 + beam_slide_y, 0])
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
        include_top_plate = false,  // guide_block() in deployed_layout_params provides the top face
        guide_centre_y    = guide_centre_y
    );



// --- LOCAL CHANGE: hanging_plate replaced by plate_block_with_slots in deployed_layout_params ---
// color([0.85, 0.75, 0.55])
// hanging_plate(
//     beam_length, guide_length,
//     plate_height, plate_width, plate_thickness,
//     plate_offset_z, plate_center_x
// );
// --- END LOCAL CHANGE ---






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
        v_angle_deg = v_frame_angle_deg
    );

    // guide block + arms (no plate) — moves with ladder assembly
    translate([plate_center_x - plate_height/2, guide_centre_y, c_spine_top])
        rotate([0, 180, 0])
        rotate([0, 0, 90])
        rotate([0, 90, 0])
            deployed_layout_params(
                p_guide_t        = wall,
                p_guide_h        = mechanism_guide_w,
                p_guide_w        = guide_length,
                p_plate_t        = plate_thickness,
                p_plate_h        = plate_height,
                p_plate_w        = plate_width,
                p_gap            = stand_off_gap,
                p_guide_y_offset = (plate_height - mechanism_guide_w) / 2,
                p_top_y_override = mechanism_top_y,
                p_show_plate     = false,
                p_show_rods      = true
            );
}

// ---- plate assembly: fixed to the wall ----

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


// --- LOCAL CHANGE: guide_side_packers dropped (no longer needed) ---
// color([0.82, 0.70, 0.52])
// guide_side_packers( ... );
// --- END LOCAL CHANGE ---

// --- LOCAL CHANGE: board from plate edge to V-frame tip ---
// Runs in X from the plate edge out to the V tip, sitting flush with the plate face.
// At the current deployment angle the V tip world Z = plate_offset_z, so the tip
// just touches the ladder-facing surface of this board.
color([0.7, 0.45, 0.25])
translate([
    v_tip_world_x,
    guide_centre_y - v_board_thickness / 2,
    plate_offset_z
])
    cube([
        (plate_center_x - plate_height / 2) - v_tip_world_x,
        v_board_thickness,
        plate_thickness
    ]);
// --- END LOCAL CHANGE ---

// --- LOCAL CHANGE: gap mechanism integration ---
// Axis mapping:  gap_mech X (away from guide) -> main +Z
//                gap_mech Y (arm heights)     -> main +Y (along beam)
//                gap_mech Z (across width)    -> main -X
// Rotations applied inside-out: rotate([0,90,0]) maps axes, then rotate([0,0,90]) spins around main Z.
// Anchor: guide face coincides with c_spine_top face; centred along beam in Y.

// plate with slots + rods (fixed to wall)
// Anchor at (plate_offset_z - stand_off_gap) so mechanism X=0 is the guide face;
// the plate face (at mechanism X = stand_off_gap) lands exactly at plate_offset_z.
translate([plate_center_x - plate_height/2, guide_centre_y, plate_offset_z - stand_off_gap])
    rotate([0, 180, 0])
    rotate([0, 0, 90])
    rotate([0, 90, 0])
        deployed_layout_params(
            p_guide_t        = wall,
            p_guide_h        = mechanism_guide_w,
            p_guide_w        = guide_length,
            p_plate_t        = plate_thickness,
            p_plate_h        = plate_height,
            p_plate_w        = plate_width,
            p_gap            = stand_off_gap,
            p_guide_y_offset = (plate_height - mechanism_guide_w) / 2,
            p_top_y_override = mechanism_top_y,
            p_show_guide     = false,
            p_show_arms      = false,
            p_show_eyes      = false,
            p_show_rods      = false
        );
// --- END LOCAL CHANGE ---








// ---------- OLD arm code (superseded by deployed_layout_params) ----------
// The variables and modules below are kept for reference but are no longer
// rendered.  See the deployed_layout_params() call above.










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