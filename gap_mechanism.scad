use <gap_mechanism_test.scad>

guide_t = 20;
guide_h = 120;
guide_w = 420;

plate_t = 20;
plate_h = 120;
plate_w = 700;

gap = 300;

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

// keep these defined because the referenced modules use them
ring_stock_r = (eye_outer_r - eye_inner_r) / 2;
eye_stem_r = ring_stock_r;

slot_depth = 8;
slot_height_clearance = 0.20;
slot_width_clearance = 0.20;
slot_cut_oversize = 2;

show_guide = true;
show_plate = true;
show_guide_eyes = true;

// --- LOCAL CHANGE: hanging plate rods ---
show_plate_rods = true;
plate_rod_r = 4;
// rod spans both arms on a side
plate_rod_len = (arm_w + arm_gap) * 2 + 8;
// --- END LOCAL CHANGE ---

// use the same arm spacing convention as the test arm module
pair_spacing = arm_w + arm_gap;

// eye centre sits half the arm thickness proud of guide face
guide_pivot_x = arm_t / 2;
arm_r = arm_t / 2;

// Y positions, top to bottom:
// left cross
// left and right non-cross (same Y)
// right cross

top_y = guide_h * 0.80;

left_cross_y     = top_y;
left_noncross_y  = left_cross_y   - pair_spacing;
right_noncross_y = left_noncross_y;              // same Y as left non-cross
right_cross_y    = left_noncross_y - pair_spacing;

// Guide end z positions

guide_left_z  = -guide_w/2 + arm_t/2;
guide_right_z =  guide_w/2 - arm_t/2;

guide_left_noncross_z  = guide_left_z;
guide_left_cross_z     = guide_left_z;

guide_right_cross_z    = guide_right_z;
guide_right_noncross_z = guide_right_z;

// --- LOCAL CHANGE: calculated plate-side z so arm outer face just touches plate edge ---
plate_left_edge_z  = -plate_w/2;
plate_right_edge_z =  plate_w/2;

plate_left_noncross_z  = plate_touch_z(guide_left_noncross_z,  plate_left_edge_z);
plate_left_cross_z     = plate_touch_z(guide_right_cross_z,    plate_left_edge_z);

plate_right_cross_z    = plate_touch_z(guide_left_cross_z,     plate_right_edge_z);
plate_right_noncross_z = plate_touch_z(guide_right_noncross_z, plate_right_edge_z);
// --- END LOCAL CHANGE ---

// ---------- helpers ----------

function v_sub(a, b) = [a[0]-b[0], a[1]-b[1], a[2]-b[2]];

function mechanism_pair_spacing() = arm_w + arm_gap;

// --- LOCAL CHANGE: solve plate-side arm centre z so arm edge is tangent to plate edge line ---
function plate_touch_z(guide_z, edge_z) =
    let(
        dx = gap - guide_pivot_x,
        m  = arm_t / 2,
        c  = edge_z - guide_z,
        a  = 1 - (m * m) / (dx * dx),
        t  = (m / dx) * sqrt(dx * dx + c * c - m * m),
        dz = (c + sign(c) * t) / a
    )
    guide_z + dz;
// --- END LOCAL CHANGE ---

module guide_block()
{
    color([1.0, 0.55, 0.0])
    translate([-guide_t, 0, -guide_w/2])
        cube([guide_t, guide_h, guide_w]);
}

module eye_bolt_on_guide(x0, y0, z0)
{
    translate([x0, y0, z0])
        eye_bolt(0, 0, 0);
}

module draw_link_3d(p0, p1, arm_color = [0.82, 0.82, 0.82], extra_len = 0)
{
    d = v_sub(p1, p0);
    dx = d[0];
    dz = d[2];
    base_len = sqrt(dx*dx + dz*dz);
    angle_deg = atan2(dz, dx);

    color(arm_color)
    translate(p0)
        rotate([0, -angle_deg, 0])
            arm(base_len + extra_len);
}

module slot_for_arm(p0, p1)
{
    d = v_sub(p1, p0);
    dx = d[0];
    dz = d[2];
    base_len = sqrt(dx*dx + dz*dz);
    angle_deg = atan2(dz, dx);

    slot_len = plate_t + slot_extra_len;
    slot_w = arm_w + slot_w_clearance;
    slot_t = arm_t + slot_t_clearance;

    translate([p1[0], p1[1], p1[2]])
        rotate([0, -angle_deg, 0])
            translate([-slot_len/2, -slot_w/2, -slot_t/2])
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

// --- LOCAL CHANGE: hanging plate rods ---
module plate_rod(x0, y0, z0, rod_len = plate_rod_len, rod_r = plate_rod_r)
{
    color([0.75, 0.75, 0.75])
    translate([x0, y0 - rod_len/2, z0])
        rotate([-90, 0, 0])
            cylinder(h = rod_len, r = rod_r, $fn = 32);
}

module draw_plate_rods()
{
    if (show_plate_rods)
    {
        // tangent to guide-side plate face
        plate_rod_x = gap;

        // tangent to the outer side edges of the plate
        left_rod_z  = -plate_w/2;
        right_rod_z =  plate_w/2;

        // one rod per side, centred between the two arm heights on that side
        left_rod_y  = (left_noncross_y + right_cross_y) / 2;
        right_rod_y = (left_cross_y + right_noncross_y) / 2;

        plate_rod(plate_rod_x, left_rod_y,  left_rod_z);
        plate_rod(plate_rod_x, right_rod_y, right_rod_z);
    }
}
// --- END LOCAL CHANGE ---

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

    // --- LOCAL CHANGE: hanging plate rods ---
    draw_plate_rods();
    // --- END LOCAL CHANGE ---
}

deployed_layout();

// --- LOCAL CHANGE: parameterised entry point for main assembly integration ---

// Variant of plate_touch_z that takes p_gap as an explicit argument
// instead of reading the global `gap`, so deployed_layout_params() can
// compute correct tangency for any gap value.
function plate_touch_z_p(guide_z, edge_z, p_gap, p_arm_t = arm_t) =
    let(
        dx = p_gap - arm_t / 2,
        m  = p_arm_t / 2,
        c  = edge_z - guide_z,
        a  = 1 - (m * m) / (dx * dx),
        t  = (m / dx) * sqrt(dx * dx + c * c - m * m),
        dz = (c + sign(c) * t) / a
    )
    guide_z + dz;

// Full mechanism with externally supplied dimensions.
// All parameters default to the existing globals so deployed_layout() and
// the standalone gap_mechanism.scad render are completely unaffected.
//
// Parameter mapping from main.scad:
//   p_guide_t  = wall                                    (guide face thickness)
//   p_guide_h  = guide_length                            (guide height / length along Y)
//   p_guide_w  = flange_width + (side_clear + wall) * 2  (guide total width in Z)
//   p_plate_t  = plate_thickness
//   p_plate_h  = plate_width                             (plate extent in Y)
//   p_plate_w  = plate_height                            (plate extent in Z)
//   p_gap      = plate_offset_z - c_spine_top            (X distance guide-face to plate)
module deployed_layout_params(
    p_guide_t = guide_t,
    p_guide_h = guide_h,
    p_guide_w = guide_w,
    p_plate_t = plate_t,
    p_plate_h = plate_h,
    p_plate_w = plate_w,
    p_gap     = gap,
    p_guide_y_offset = 0,   // shifts guide block in Y without moving arms or plate
    p_top_y_override = -1,  // if >= 0, overrides the default 80% formula
    p_show_guide     = show_guide,
    p_show_arms      = true,
    p_show_plate     = show_plate,
    p_show_eyes      = show_guide_eyes,
    p_show_rods      = show_plate_rods
)
{
    // ---- derived arm layout (mirrors top-level globals logic) ----
    p_pair_spacing      = arm_w + arm_gap;
    p_pivot_x           = arm_t / 2;
    p_top_y             = (p_top_y_override >= 0) ? p_top_y_override : p_guide_h * 0.80;

    p_left_cross_y      = p_top_y;
    p_left_noncross_y   = p_left_cross_y   - p_pair_spacing;
    p_right_noncross_y  = p_left_noncross_y;              // same Y as left non-cross
    p_right_cross_y     = p_left_noncross_y - p_pair_spacing;

    p_guide_left_z      = -p_guide_w/2 + arm_t/2;
    p_guide_right_z     =  p_guide_w/2 - arm_t/2;

    p_plate_left_edge_z  = -p_plate_w/2;
    p_plate_right_edge_z =  p_plate_w/2;

    p_pl_noncross_z = plate_touch_z_p(p_guide_left_z,  p_plate_left_edge_z,  p_gap);
    p_pl_cross_l_z  = plate_touch_z_p(p_guide_right_z, p_plate_left_edge_z,  p_gap);
    p_pl_cross_r_z  = plate_touch_z_p(p_guide_left_z,  p_plate_right_edge_z, p_gap);
    p_pl_noncross_r = plate_touch_z_p(p_guide_right_z, p_plate_right_edge_z, p_gap);

    // ---- guide block ----
    if (p_show_guide)
    color([1.0, 0.55, 0.0])
    translate([-p_guide_t, p_guide_y_offset, -p_guide_w/2])
        cube([p_guide_t, p_guide_h, p_guide_w]);

    // ---- arms ----
    if (p_show_arms)
    {
        draw_link_3d(
            [p_pivot_x, p_left_noncross_y,  p_guide_left_z],
            [p_gap,     p_left_noncross_y,  p_pl_noncross_z],
            [0.82, 0.82, 0.82], arm_extra_past_plate);

        draw_link_3d(
            [p_pivot_x, p_right_noncross_y, p_guide_right_z],
            [p_gap,     p_right_noncross_y, p_pl_noncross_r],
            [0.82, 0.82, 0.82], arm_extra_past_plate);

        draw_link_3d(
            [p_pivot_x, p_left_cross_y,  p_guide_left_z],
            [p_gap,     p_left_cross_y,  p_pl_cross_r_z],
            [0.55, 0.55, 0.55], arm_extra_past_plate);

        draw_link_3d(
            [p_pivot_x, p_right_cross_y, p_guide_right_z],
            [p_gap,     p_right_cross_y, p_pl_cross_l_z],
            [0.55, 0.55, 0.55], arm_extra_past_plate);
    }

    // ---- plate with slots ----
    if (p_show_plate)
    {
        p_slot_len = p_plate_t + slot_extra_len;
        p_slot_w   = arm_w + slot_w_clearance;
        p_slot_t   = arm_t + slot_t_clearance;

        color([0.55, 0.80, 1.0])
        difference()
        {
            translate([p_gap, 0, -p_plate_w/2])
                cube([p_plate_t, p_plate_h, p_plate_w]);

            // left non-cross
            translate([p_gap, p_left_noncross_y, p_pl_noncross_z])
            {
                d = v_sub([p_gap, p_left_noncross_y, p_pl_noncross_z],
                          [p_pivot_x, p_left_noncross_y, p_guide_left_z]);
                rotate([0, -atan2(d[2], d[0]), 0])
                    translate([-p_slot_len/2, -p_slot_w/2, -p_slot_t/2])
                        cube([p_slot_len, p_slot_w, p_slot_t]);
            }

            // right cross (to left plate edge)
            translate([p_gap, p_right_cross_y, p_pl_cross_l_z])
            {
                d = v_sub([p_gap, p_right_cross_y, p_pl_cross_l_z],
                          [p_pivot_x, p_right_cross_y, p_guide_right_z]);
                rotate([0, -atan2(d[2], d[0]), 0])
                    translate([-p_slot_len/2, -p_slot_w/2, -p_slot_t/2])
                        cube([p_slot_len, p_slot_w, p_slot_t]);
            }

            // left cross (to right plate edge)
            translate([p_gap, p_left_cross_y, p_pl_cross_r_z])
            {
                d = v_sub([p_gap, p_left_cross_y, p_pl_cross_r_z],
                          [p_pivot_x, p_left_cross_y, p_guide_left_z]);
                rotate([0, -atan2(d[2], d[0]), 0])
                    translate([-p_slot_len/2, -p_slot_w/2, -p_slot_t/2])
                        cube([p_slot_len, p_slot_w, p_slot_t]);
            }

            // right non-cross
            translate([p_gap, p_right_noncross_y, p_pl_noncross_r])
            {
                d = v_sub([p_gap, p_right_noncross_y, p_pl_noncross_r],
                          [p_pivot_x, p_right_noncross_y, p_guide_right_z]);
                rotate([0, -atan2(d[2], d[0]), 0])
                    translate([-p_slot_len/2, -p_slot_w/2, -p_slot_t/2])
                        cube([p_slot_len, p_slot_w, p_slot_t]);
            }
        }
    }

    // ---- guide-side eye bolts ----
    if (p_show_eyes)
    {
        eye_bolt_on_guide(p_pivot_x, p_left_noncross_y,  p_guide_left_z);
        eye_bolt_on_guide(p_pivot_x, p_left_cross_y,     p_guide_left_z);
        eye_bolt_on_guide(p_pivot_x, p_right_cross_y,    p_guide_right_z);
        eye_bolt_on_guide(p_pivot_x, p_right_noncross_y, p_guide_right_z);
    }

    // ---- plate-edge rods ----
    if (p_show_rods)
    {
        p_rod_x      = p_gap;
        p_left_rod_z  = -p_plate_w/2;
        p_right_rod_z =  p_plate_w/2;
        p_left_rod_y  = (p_left_noncross_y  + p_right_cross_y)   / 2;
        p_right_rod_y = (p_left_cross_y     + p_right_noncross_y) / 2;

        plate_rod(p_rod_x, p_left_rod_y,  p_left_rod_z);
        plate_rod(p_rod_x, p_right_rod_y, p_right_rod_z);
    }
}
// --- END LOCAL CHANGE ---
