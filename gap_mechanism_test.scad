guide_t = 20;
guide_h = 140;
guide_w = 420;

arm_w = 16;      // width across stack
arm_t = 8;       // short dimension in folding plane
arm_len = 300;

eye_outer_r = 4;
eye_inner_r = 2.2;
eye_stem_len = 12;

slot_depth = 8;
slot_height_clearance = 0.20;
slot_width_clearance = 0.20;
slot_cut_oversize = 2;   // extra cut distance so slot definitely passes through

pair_spacing = arm_w + 1;

// derived eye-bolt stock radius so rod and ring match
ring_stock_r = (eye_outer_r - eye_inner_r) / 2;
eye_stem_r = ring_stock_r;

// eye centre distance from guide face is based on short dimension
pivot_x = arm_t / 2;
r = arm_t / 2;

// vertical placement
top_y = guide_h * 0.75;

y1 = top_y;
y2 = y1 - pair_spacing;
y3 = y2 - pair_spacing;
y4 = y3 - pair_spacing;

// hinge positions across guide
z_left  = -guide_w/2 + arm_w/2;
z_right =  guide_w/2 - arm_w/2;


// -----------------------

module guide()
{
    color([1,0.55,0])
    translate([-guide_t,0,-guide_w/2])
        cube([guide_t,guide_h,guide_w]);
}

module eye_bolt(x,y,z)
{
    color("red")
    translate([x,y,z])
    union()
    {
        rotate([90,0,0])
            rotate_extrude($fn=64)
                translate([(eye_outer_r + eye_inner_r)/2,0,0])
                    circle(r=ring_stock_r, $fn=32);

        translate([-eye_stem_len,0,0])
            rotate([0,90,0])
                cylinder(h=eye_stem_len, r=eye_stem_r, $fn=32);
    }
}

// 2D arm profile in local XY
// x = arm length direction, away from guide
// y = short dimension in folding plane
module arm_profile(len)
{
    union()
    {
        translate([0, -arm_t/2])
            square([len, arm_t]);

        intersection()
        {
            circle(r = r, $fn = 64);
            translate([-r, -r])
                square([r, 2*r]);
        }
    }
}

// 2D slot profile in the same local XY plane as the arm profile.
// The slot opens from the rounded nose and extends inward.
// Height hugs the eye OD.
module arm_eye_slot_profile()
{
    slot_h = 2 * eye_outer_r + slot_height_clearance;

    translate([-r - 0.2, -slot_h/2])
        square([slot_depth + r + 0.2, slot_h]);
}

// Extrude the slot all the way through the arm width, with oversize,
// so the subtraction definitely cuts the full slot.
module arm_eye_slot_cut()
{
    slot_w = arm_w + 2 * slot_cut_oversize;

    translate([0,0,-slot_w/2])
        linear_extrude(height = slot_w, center = false)
            arm_eye_slot_profile();
}

module arm(len)
{
    color([0.82,0.82,0.82])
    difference()
    {
        rotate([90,0,0])
            linear_extrude(height = arm_w, center = true)
                arm_profile(len);

        rotate([90,0,0])
            arm_eye_slot_cut();
    }
}

module arm_at(p, angle_deg)
{
    translate(p)
        rotate([0, -angle_deg, 0])
            arm(arm_len);
}


// -----------------------

guide();

eye_bolt(pivot_x, y1, z_left);
eye_bolt(pivot_x, y2, z_left);
eye_bolt(pivot_x, y3, z_right);
eye_bolt(pivot_x, y4, z_right);

arm_at([pivot_x, y1, z_left], 15);
arm_at([pivot_x, y2, z_left], 30);
arm_at([pivot_x, y3, z_right], -25);
arm_at([pivot_x, y4, z_right], -10);