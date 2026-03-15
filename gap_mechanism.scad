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

arm_extra_past_plate = 80;

slot_w_clearance = 2;
slot_t_clearance = 2;
slot_extra_len = 40;

eye_outer_r = 6;
eye_inner_r = 3;
eye_stem_len = 14;
eye_stem_r = 2.2;

show_guide = true;
show_plate = true;
show_guide_eyes = true;

pair_spacing = arm_t + arm_gap;

// eye centre sits half the arm width proud of guide face
guide_pivot_x = arm_w / 2;
arm_r = arm_w / 2;

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

// Guide end z positions

guide_left_z  = -guide_w/2 + arm_t/2;
guide_right_z =  guide_w/2 - arm_t/2;

guide_left_noncross_z  = guide_left_z;
guide_left_cross_z     = guide_left_z;

guide_right_cross_z    = guide_right_z;
guide_right_noncross_z = guide_right_z;

// Plate slot centre z positions

plate_left_noncross_z  = -plate_w/2 + arm_t/2;
plate_left_cross_z     = plate_left_noncross_z + arm_t;

plate_right_cross_z    =  plate_w/2 - arm_t - arm_t/2;
plate_right_noncross_z =  plate_w/2 - arm_t/2;

// ---------- helpers ----------

function v_sub(a, b) = [a[0]-b[0], a[1]-b[1], a[2]-b[2]];
function v_len(v) = sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2]);
function v_unit(v) = let(L = v_len(v)) [v[0]/L, v[1]/L, v[2]/L];

module guide_block()
{
    color([1.0, 0.55, 0.0])
    translate([-guide_t, 0, -guide_w/2])
        cube([guide_t, guide_h, guide_w]);
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

// local arm profile:
// x = arm length direction
// y = arm width in the motion plane
// pivot is at local origin
//
// arm is rectangle plus only the FORWARD semicircle of radius arm_r,
// so it has a D-shaped timber end instead of a washer-like full circle.
module wooden_arm_profile(len, w)
{
    r = w / 2;

    union()
    {
        translate([0, -w/2])
            square([len, w], center = false);

        intersection()
        {
            circle(r = r, $fn = 48);
            translate([0, -r])
                square([r, 2*r], center = false);
        }
    }
}

module wooden_arm_body(len, w, t)
{
    linear_extrude(height = t, center = true)
        wooden_arm_profile(len, w);
}

module draw_link_3d(p0, p1, arm_color = [0.82, 0.82, 0.82], extra_len = 0)
{
    d = v_sub(p1, p0);
    len_xy = sqrt(d[0]*d[0] + d[1]*d[1]);
    base_len = v_len(d);

    yaw = atan2(d[1], d[0]);
    pitch = -atan2(d[2], len_xy);

    color(arm_color)
    translate(p0)
        rotate([0, pitch, yaw])
            wooden_arm_body(base_len + extra_len, arm_w, arm_t);
}

module slot_for_arm(p0, p1)
{
    d = v_sub(p1, p0);
    u = v_unit(d);

    len_xy = sqrt(d[0]*d[0] + d[1]*d[1]);
    yaw = atan2(d[1], d[0]);
    pitch = -atan2(d[2], len_xy);

    slot_len = plate_t + slot_extra_len;
    slot_w = arm_w + slot_w_clearance;
    slot_t = arm_t + slot_t_clearance;

    translate([
        p1[0] - u[0] * slot_len/2,
        p1[1] - u[1] * slot_len/2,
        p1[2] - u[2] * slot_len/2
    ])
        rotate([0, pitch, yaw])
            translate([0, -slot_w/2, -slot_t/2])
                cube([slot_len, slot_w, slot_t]);
}

module plate_block_with_slots()
{
    color([0.55, 0.80, 1.0])
    difference()
    {
        translate([gap, 0, -plate_w/2])
            cube([plate_t, plate_h, plate_w]);

        slot_for_arm(
            [guide_pivot_x, left_noncross_y, guide_left_noncross_z],
            [gap, left_noncross_y, plate_left_noncross_z]
        );

        slot_for_arm(
            [guide_pivot_x, right_cross_y, guide_right_cross_z],
            [gap, right_cross_y, plate_left_cross_z]
        );

        slot_for_arm(
            [guide_pivot_x, left_cross_y, guide_left_cross_z],
            [gap, left_cross_y, plate_right_cross_z]
        );

        slot_for_arm(
            [guide_pivot_x, right_noncross_y, guide_right_noncross_z],
            [gap, right_noncross_y, plate_right_noncross_z]
        );
    }
}

module draw_guide_eyes()
{
    if (show_guide_eyes)
    {
        eye_bolt_on_guide(guide_pivot_x, left_noncross_y,  guide_left_noncross_z);
        eye_bolt_on_guide(guide_pivot_x, left_cross_y,     guide_left_cross_z);
        eye_bolt_on_guide(guide_pivot_x, right_cross_y,    guide_right_cross_z);
        eye_bolt_on_guide(guide_pivot_x, right_noncross_y, guide_right_noncross_z);
    }
}

module deployed_layout()
{
    if (show_guide)
        guide_block();

    draw_link_3d(
        [guide_pivot_x, left_noncross_y, guide_left_noncross_z],
        [gap, left_noncross_y, plate_left_noncross_z],
        [0.82, 0.82, 0.82],
        arm_extra_past_plate
    );

    draw_link_3d(
        [guide_pivot_x, right_noncross_y, guide_right_noncross_z],
        [gap, right_noncross_y, plate_right_noncross_z],
        [0.82, 0.82, 0.82],
        arm_extra_past_plate
    );

    draw_link_3d(
        [guide_pivot_x, left_cross_y, guide_left_cross_z],
        [gap, left_cross_y, plate_right_cross_z],
        [0.55, 0.55, 0.55],
        arm_extra_past_plate
    );

    draw_link_3d(
        [guide_pivot_x, right_cross_y, guide_right_cross_z],
        [gap, right_cross_y, plate_left_cross_z],
        [0.55, 0.55, 0.55],
        arm_extra_past_plate
    );

    if (show_plate)
        plate_block_with_slots();

    draw_guide_eyes();
}

deployed_layout();