use <ladder_parts.scad>
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


color([0.82, 0.70, 0.52])
guide_side_packers(
    beam_length,
    guide_length,
    wall,
    web_height,
    flange_thickness,
    top_clear,
    plate_thickness,
    packer_length_y,
    packer_size_x,
    packer_offset_x,
    packer_back_offset_z
);










// ---------- arm parameters ----------
arm_size_x = 20;   // vertical size
arm_size_y = 18;   // sideways size
arm_size_z = 30;   // depth size

upper_hinge_drop_x = arm_size_x;
lower_hinge_drop_x = arm_size_x *2;

arm_hinge_back_offset_z = 0;



upper_arm_length = 500;
upper_arm_angle_deg = -35;

lower_arm_length = 500;
lower_arm_angle_deg = -35;

arm_clearance_z = 1;

// ---------- arm helper modules ----------
module yz_block(cx, cy, cz, sx, sy, sz)
{
    translate([
        cx - sx / 2,
        cy - sy / 2,
        cz - sz / 2
    ])
    cube([sx, sy, sz]);
}

module yz_arm_between_points(
    y1, z1,
    y2, z2,
    x_center,
    size_x,
    size_y,
    size_z
)
{
    hull()
    {
        yz_block(
            x_center, y1, z1,
            size_x, size_y, size_z
        );

        yz_block(
            x_center, y2, z2,
            size_x, size_y, size_z
        );
    }
}

module angled_yz_arm(
    hinge_x,
    hinge_y,
    hinge_z,
    arm_length,
    arm_angle_deg,
    size_x,
    size_y,
    size_z,
    y_sign = 1
)
{
    end_y = hinge_y + y_sign * arm_length * sin(arm_angle_deg);
    end_z = hinge_z + arm_length * cos(arm_angle_deg);

    yz_arm_between_points(
        hinge_y, hinge_z,
        end_y, end_z,
        hinge_x,
        size_x,
        size_y,
        size_z
    );
}


// ---------- derived guide / packer positions ----------
guide_y0 = beam_length / 2 - guide_length / 2;
guide_y1 = guide_y0 + guide_length;

left_packer_center_y  = guide_y0 + packer_length_y / 2;
right_packer_center_y = guide_y1 - packer_length_y / 2;

guide_top_x = web_height + flange_thickness + top_clear + wall;

guide_back_z = wall;
packer_back_z = guide_back_z + packer_back_offset_z + plate_thickness;

hinge_z = packer_back_z + arm_hinge_back_offset_z + arm_size_z / 2 + arm_clearance_z;

upper_hinge_x = guide_top_x - upper_hinge_drop_x;
lower_hinge_x = guide_top_x - lower_hinge_drop_x;


// ---------- draw the two arms ----------
color([0.45, 0.28, 0.16])
angled_yz_arm(
    upper_hinge_x,
    left_packer_center_y,
    hinge_z,
    upper_arm_length,
    upper_arm_angle_deg,
    arm_size_x,
    arm_size_y,
    arm_size_z,
    1
);

color([0.45, 0.28, 0.16])
angled_yz_arm(
    lower_hinge_x,
    right_packer_center_y,
    hinge_z,
    lower_arm_length,
    lower_arm_angle_deg,
    arm_size_x,
    arm_size_y,
    arm_size_z,
    -1
);