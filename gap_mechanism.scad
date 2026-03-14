guide_t = 20;
guide_h = 120;
guide_w = 420;

plate_t = 20;
plate_h = 120;
plate_w = 700;

gap = 320;

arm_w = 16;
arm_t = 8;
arm_gap = 0;

arm_extra_past_plate = 60;
cut_clearance = 0.5;

eye_outer_r = 8;
eye_inner_r = 4;
eye_stem_len = 14;
eye_stem_r = 2.6;

show_guide = true;
show_plate = true;
show_guide_eyes = true;

pair_spacing = arm_w + arm_gap;

// Y positions, top to bottom:
// left non-cross
// right cross
// left cross
// right non-cross

top_y = guide_h * 0.80;

left_noncross_y  = top_y;
right_cross_y    = left_noncross_y - pair_spacing;
left_cross_y     = right_cross_y - pair_spacing;
right_noncross_y = left_cross_y - pair_spacing;


// Guide end z positions:
// hinges at each guide end are inline

guide_left_z  = -guide_w/2 + arm_t/2;
guide_right_z =  guide_w/2 - arm_t/2;

guide_left_noncross_z  = guide_left_z;
guide_left_cross_z     = guide_left_z;

guide_right_cross_z    = guide_right_z;
guide_right_noncross_z = guide_right_z;


// Plate end z positions:
// left pair = non-cross, cross
// right pair = cross, non-cross

plate_left_noncross_z  = -plate_w/2 + arm_t/2;
plate_left_cross_z     = plate_left_noncross_z + arm_t;

plate_right_cross_z    = plate_w/2 - arm_t - arm_t/2;
plate_right_noncross_z = plate_w/2 - arm_t/2;


module guide_block()
{
    color([1.0, 0.55, 0.0])
    translate([-guide_t, 0, -guide_w/2])
        cube([guide_t, guide_h, guide_w]);
}

module plate_block()
{
    color([0.55, 0.80, 1.0])
    translate([gap, 0, -plate_w/2])
        cube([plate_t, plate_h, plate_w]);
}

module plate_cut_block()
{
    translate([gap - cut_clearance, -cut_clearance, -plate_w/2 - cut_clearance])
        cube([
            plate_t + 2 * cut_clearance,
            plate_h + 2 * cut_clearance,
            plate_w + 2 * cut_clearance
        ]);
}

module ring_y_axis(outer_r, inner_r)
{
    rotate([90, 0, 0])
        rotate_extrude($fn = 48)
            translate([(outer_r + inner_r) / 2, 0, 0])
                circle(r = (outer_r - inner_r) / 2, $fn = 32);
}

module eye_bolt_on_guide(x0, y0, z0)
{
    color("red")
    translate([x0, y0, z0])
    union()
    {
        ring_y_axis(eye_outer_r, eye_inner_r);

        translate([-eye_stem_len, 0, 0])
            rotate([0, 90, 0])
                cylinder(h = eye_stem_len, r = eye_stem_r, $fn = 24);

        sphere(r = eye_stem_r * 1.15, $fn = 24);
    }
}

module link_body(len, w, t)
{
    translate([0, -w/2, -t/2])
        cube([len, w, t]);
}

module draw_link_3d(p0, p1, arm_color = "silver", extra_len = 0)
{
    dx = p1[0] - p0[0];
    dy = p1[1] - p0[1];
    dz = p1[2] - p0[2];

    base_len_xy = sqrt(dx*dx + dy*dy);
    base_len = sqrt(dx*dx + dy*dy + dz*dz);

    ux = dx / base_len;
    uy = dy / base_len;
    uz = dz / base_len;

    yaw = atan2(dy, dx);
    pitch = -atan2(dz, base_len_xy);

    color(arm_color)
    difference()
    {
        translate(p0)
            rotate([0, pitch, yaw])
                link_body(base_len + extra_len, arm_w, arm_t);

        plate_cut_block();
    }
}

module plate_pivot_marker(x0, y0, z0)
{
    color([0.2, 0.2, 0.2])
    translate([x0, y0, z0])
        rotate([0, 90, 0])
            cylinder(h = 8, r = 3, center = true, $fn = 24);
}

module draw_guide_eyes()
{
    if (show_guide_eyes)
    {
        eye_bolt_on_guide(0, left_noncross_y,  guide_left_noncross_z);
        eye_bolt_on_guide(0, left_cross_y,     guide_left_cross_z);
        eye_bolt_on_guide(0, right_cross_y,    guide_right_cross_z);
        eye_bolt_on_guide(0, right_noncross_y, guide_right_noncross_z);
    }
}

module draw_plate_markers()
{
    plate_pivot_marker(gap, left_noncross_y,  plate_left_noncross_z);
    plate_pivot_marker(gap, right_cross_y,    plate_left_cross_z);
    plate_pivot_marker(gap, left_cross_y,     plate_right_cross_z);
    plate_pivot_marker(gap, right_noncross_y, plate_right_noncross_z);
}

module deployed_layout()
{
    if (show_guide)
        guide_block();

    if (show_plate)
        plate_block();

    // non-cross arms
    draw_link_3d(
        [0, left_noncross_y, guide_left_noncross_z],
        [gap, left_noncross_y, plate_left_noncross_z],
        [0.82, 0.82, 0.82],
        arm_extra_past_plate
    );

    draw_link_3d(
        [0, right_noncross_y, guide_right_noncross_z],
        [gap, right_noncross_y, plate_right_noncross_z],
        [0.82, 0.82, 0.82],
        arm_extra_past_plate
    );

    // cross arms
    draw_link_3d(
        [0, left_cross_y, guide_left_cross_z],
        [gap, left_cross_y, plate_right_cross_z],
        [0.55, 0.55, 0.55],
        arm_extra_past_plate
    );

    draw_link_3d(
        [0, right_cross_y, guide_right_cross_z],
        [gap, right_cross_y, plate_left_cross_z],
        [0.55, 0.55, 0.55],
        arm_extra_past_plate
    );

    draw_guide_eyes();
    draw_plate_markers();
}

deployed_layout();