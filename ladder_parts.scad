module t_beam(
    beam_length,
    web_thickness,
    web_height,
    flange_width,
    flange_thickness
)
{
    union()
    {
        translate([-web_thickness / 2, 0, 0])
        cube([web_thickness, beam_length, web_height]);

        translate([-flange_width / 2, 0, web_height])
        cube([flange_width, beam_length, flange_thickness]);
    }
}

module c_guide(
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
)
{
    inner_width = flange_width + side_clear * 2;
    lip_width = (inner_width - web_thickness) / 2;
    guide_y = beam_length / 2 - guide_length / 2;

    top_plate_z = web_height + flange_thickness + top_clear;
    lip_top_z = web_height - bottom_clear;
    lip_bottom_z = lip_top_z - wall;

    side_wall_bottom_z = lip_bottom_z;
    side_wall_height = (top_plate_z + wall) - side_wall_bottom_z;

    // top plate
    translate([
        -inner_width / 2 - wall,
        guide_y,
        top_plate_z
    ])
    cube([
        inner_width + wall * 2,
        guide_length,
        wall
    ]);

    // left wall
    translate([
        -inner_width / 2 - wall,
        guide_y,
        side_wall_bottom_z
    ])
    cube([
        wall,
        guide_length,
        side_wall_height
    ]);

    // right wall
    translate([
        inner_width / 2,
        guide_y,
        side_wall_bottom_z
    ])
    cube([
        wall,
        guide_length,
        side_wall_height
    ]);

    // left lower lip
    translate([
        -inner_width / 2,
        guide_y,
        lip_bottom_z
    ])
    cube([
        lip_width,
        guide_length,
        wall
    ]);

    // right lower lip
    translate([
        web_thickness / 2,
        guide_y,
        lip_bottom_z
    ])
    cube([
        lip_width,
        guide_length,
        wall
    ]);
}



module hanging_plate(
    beam_length,
    guide_length,
    plate_height,
    plate_width,
    plate_thickness,
    plate_offset_z = 0,
    plate_center_x = 0
)
{
    guide_y = beam_length / 2 - guide_length / 2;
    plate_center_y = guide_y + guide_length / 2;

    translate([
        plate_center_x - plate_height / 2,
        plate_center_y - plate_width / 2,
        plate_offset_z
    ])
    cube([
        plate_height,
        plate_width,
        plate_thickness
    ]);
}



module hinged_top_board(
    beam_length,
    guide_length,
    plate_height,
    plate_width,
    plate_thickness,
    plate_offset_z,
    top_board_depth,
    top_board_thickness,
    hinge_x = 0,
    hinge_angle = 0
)
{
    guide_y = beam_length / 2 - guide_length / 2;
    plate_center_y = guide_y + guide_length / 2;

    // top edge of the hanging plate in X
    plate_top_x = plate_height / 2;

    translate([
        hinge_x + plate_top_x,
        plate_center_y,
        plate_offset_z
    ])
    rotate([0, -hinge_angle, 0])
    translate([
        0,
        -plate_width / 2,
        0
    ])
    cube([
        top_board_depth,
        plate_width,
        top_board_thickness
    ]);
}



module xy_block(cx, cy, cz, sx, sy, sz)
{
    translate([
        cx - sx / 2,
        cy - sy / 2,
        cz - sz / 2
    ])
    cube([sx, sy, sz]);
}

module xy_arm(x1, y1, x2, y2, z_center, z_thickness, arm_width, arm_x_width)
{
    hull()
    {
        xy_block(
            x1, y1, z_center,
            arm_x_width, arm_width, z_thickness
        );

        xy_block(
            x2, y2, z_center,
            arm_x_width, arm_width, z_thickness
        );
    }
}

module v_frame_in_c_spine_plane(
    beam_length,
    guide_length,
    flange_width,
    side_clear,
    wall,
    web_height,
    flange_thickness,
    top_clear,
    x_vertex_offset,
    z_thickness,
    arm_width,
    vertex_block_size,
    v_angle_deg = 0
)
{
    inner_width = flange_width + side_clear * 2;
    guide_y0 = beam_length / 2 - guide_length / 2;
    guide_y1 = guide_y0 + guide_length;
    guide_yc = (guide_y0 + guide_y1) / 2;

    z_center = web_height + flange_thickness + top_clear + wall / 2;

    arm_x_width = wall;
    x_shift = -wall - arm_x_width / 2;

    left_tip_x = -inner_width / 2 + x_shift;
    right_tip_x = -inner_width / 2 + x_shift;

    left_tip_y = guide_y0 + arm_width / 2;
    right_tip_y = guide_y1 - arm_width / 2;

    vertex_x = -x_vertex_offset + x_shift;
    vertex_y = guide_yc;

    hinge_x = left_tip_x + arm_x_width / 2;
    hinge_z = z_center + z_thickness / 2;

    translate([hinge_x, 0, hinge_z])
    rotate([0, v_angle_deg, 0])
    translate([-hinge_x, 0, -hinge_z])
    {
        xy_arm(
            left_tip_x, left_tip_y,
            vertex_x, vertex_y,
            z_center, z_thickness, arm_width, arm_x_width
        );

        xy_arm(
            right_tip_x, right_tip_y,
            vertex_x, vertex_y,
            z_center, z_thickness, arm_width, arm_x_width
        );

        xy_block(
            vertex_x, vertex_y, z_center,
            vertex_block_size, vertex_block_size, z_thickness
        );
    }
}