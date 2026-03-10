function cuboid_volume(x, y, z) =
    x * y * z;

function cut_row(name, material, x, y, z, qty=1) =
    [name, material, x, y, z, qty, cuboid_volume(x, y, z) * qty];

function row_name(row) = row[0];
function row_material(row) = row[1];
function row_x(row) = row[2];
function row_y(row) = row[3];
function row_z(row) = row[4];
function row_qty(row) = row[5];
function row_volume(row) = row[6];

function guide_inner_width(flange_width, side_clear) =
    flange_width + side_clear * 2;

function guide_lip_width(flange_width, side_clear, web_thickness) =
    (guide_inner_width(flange_width, side_clear) - web_thickness) / 2;

function guide_top_plate_z(web_height, flange_thickness, top_clear) =
    web_height + flange_thickness + top_clear;

function guide_lip_top_z(web_height, bottom_clear) =
    web_height - bottom_clear;

function guide_lip_bottom_z(web_height, bottom_clear, wall) =
    guide_lip_top_z(web_height, bottom_clear) - wall;

function guide_side_wall_bottom_z(web_height, bottom_clear, wall) =
    guide_lip_bottom_z(web_height, bottom_clear, wall);

function guide_side_wall_height(web_height, flange_thickness, top_clear, bottom_clear, wall) =
    (guide_top_plate_z(web_height, flange_thickness, top_clear) + wall)
    - guide_side_wall_bottom_z(web_height, bottom_clear, wall);

function sum_volumes(rows, i=0) =
    i >= len(rows)
        ? 0
        : row_volume(rows[i]) + sum_volumes(rows, i + 1);

function build_cut_rows() =
    let(
        inner_width = guide_inner_width(flange_width, side_clear),
        lip_width = guide_lip_width(flange_width, side_clear, web_thickness),
        side_wall_height = guide_side_wall_height(
            web_height,
            flange_thickness,
            top_clear,
            bottom_clear,
            wall
        )
    )
    [
        cut_row(
            "T web",
            "timber",
            web_thickness,
            beam_length,
            web_height,
            1
        ),
        cut_row(
            "T flange",
            "timber",
            flange_width,
            beam_length,
            flange_thickness,
            1
        ),
        cut_row(
            "Guide top",
            "timber",
            inner_width + wall * 2,
            guide_length,
            wall,
            1
        ),
        cut_row(
            "Guide left wall",
            "timber",
            wall,
            guide_length,
            side_wall_height,
            1
        ),
        cut_row(
            "Guide right wall",
            "timber",
            wall,
            guide_length,
            side_wall_height,
            1
        ),
        cut_row(
            "Guide left lip",
            "timber",
            lip_width,
            guide_length,
            wall,
            1
        ),
        cut_row(
            "Guide right lip",
            "timber",
            lip_width,
            guide_length,
            wall,
            1
        ),

        cut_row(
            "Hanging plate",
            "plywood",
            plate_height,
            plate_width,
            plate_thickness,
            1
        ),

        cut_row(
            "Top hinged board",
            "plywood",
            top_board_depth,
            plate_width,
            top_board_thickness,
            1
        )
    ];

module echo_cut_row(row)
{
    echo(
        str(
            row_name(row),
            " | material=",
            row_material(row),
            " | size=",
            row_x(row), " x ",
            row_y(row), " x ",
            row_z(row),
            " mm | qty=",
            row_qty(row),
            " | volume=",
            row_volume(row),
            " mm^3"
        )
    );
}

module echo_cut_list(rows)
{
    for (r = rows)
        echo_cut_row(r);

    echo(str("TOTAL VOLUME = ", sum_volumes(rows), " mm^3"));
    echo(str("TOTAL VOLUME = ", sum_volumes(rows) / 1000000, " litres"));
}