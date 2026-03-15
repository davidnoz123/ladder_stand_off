# Project Plan

## Objective

Build and integrate a robust adjustable ladder stand-off mechanism in OpenSCAD.

The mechanism creates an adjustable gap between a ladder and a wall using:

- a guide block on the wall side,
- a hanging plate on the ladder side,
- four wooden arms forming the linkage,
- guide-side eye-bolt hinges,
- hanging-plate rods that the arms will eventually latch onto via half-round notches.

## Current file roles

### `gap_mechanism.scad`
Current working mechanism model.

This file currently contains the latest accepted development state for:

- plate and guide positioning,
- four-arm linkage placement,
- reuse of hinge/arm code from `gap_mechanism_test.scad`,
- hanging-plate rods positioned with their axes on the plate edges.

### `gap_mechanism_test.scad`
Hinge and slotted-arm development file.

This file currently provides reusable modules for:

- `eye_bolt(...)`
- `arm(...)`
- arm slot geometry
- arm end rounding and hinge slot subtraction

`gap_mechanism.scad` currently references it with:

```scad
use <gap_mechanism_test.scad>
```

### `main.scad`
Broader ladder model that must now absorb the mechanism logic from `gap_mechanism.scad`.

### `ladder_parts.scad`
General ladder assembly modules.

### `ladder_calc.scad`
Cut-list / calculation helpers.

## What has been achieved so far

### 1. Guide-side hinge geometry established

The guide-side arm/eye-bolt geometry has been debugged in `gap_mechanism_test.scad`.

Key outcomes:

- eye-bolt ring and rod stock are matched,
- arm slot width is based on eye-bolt stock, not arm width,
- rounded arm nose geometry is working,
- `gap_mechanism.scad` reuses this hinge code rather than duplicating it.

### 2. Mechanism-specific standalone model exists

`gap_mechanism.scad` now acts as a standalone development model for the full four-arm mechanism.

This file includes:

- guide block,
- hanging plate,
- plate slots,
- guide eye bolts,
- four arms,
- hanging-plate rods.

### 3. Hanging-plate rods placed on the plate edges

The accepted rod placement is:

- one rod per side,
- rod axis on the guide-side plate edge,
- left rod axis at `X = gap`, `Z = -plate_w/2`,
- right rod axis at `X = gap`, `Z =  plate_w/2`,
- each rod vertically centred between the two arm heights on that side.

This is the currently accepted implementation.

### 4. Plate-end arm tangency work started

The current direction is to place the plate-side arm endpoints so the relevant side of each arm meets the same plate edge line as the rod axis.

This is preparation for adding:

- half-round notches in the arms,
- notch radius matching rod radius,
- latching onto the rods.

## Immediate next step

Integrate the current `gap_mechanism.scad` logic into the main model.

### Definition of done for this step

- the mechanism code now lives in the main assembly in the correct place,
- the rendered main model matches the standalone `gap_mechanism.scad` behavior,
- `gap_mechanism.scad` can be retained as a reference/debug file during transition,
- reuse of hinge code from `gap_mechanism_test.scad` is preserved unless there is a compelling reason to extract a separate shared file.

## Recommended integration approach

### Phase 1 — inspect and map

- Review `main.scad`, `ladder_parts.scad`, and any existing mechanism-related logic.
- Identify the portion of the main model that should be replaced by the current mechanism implementation.
- Determine whether the mechanism should remain inline in `main.scad` or be wrapped as a dedicated module.

### Phase 2 — transplant minimal working mechanism

- Copy or wrap only the required logic from `gap_mechanism.scad` into the main model.
- Preserve current parameter names where possible.
- Continue referencing `gap_mechanism_test.scad` with `use <gap_mechanism_test.scad>`.
- Keep changes localized for git review.

### Phase 3 — verify assembly alignment

- Confirm the guide location in the main model matches the standalone mechanism assumptions.
- Confirm the hanging plate is placed correctly relative to the ladder.
- Confirm the four arms still render in the intended crossed/non-crossed arrangement.
- Confirm the rods remain on the plate edges as currently accepted.

### Phase 4 — stabilize

- Add temporary debug geometry if needed.
- Once the integrated model matches the standalone mechanism, freeze that milestone before further feature work.

## After integration

Once the mechanism is correctly integrated into the main model, continue with plate-end engagement development:

### Next feature: rod latch geometry

1. Finalize plate-side arm positioning so the correct arm face meets the rod axis.
2. Add half-round notches to the arm ends.
3. Match notch radius to `plate_rod_r`.
4. Verify the arms can latch onto the rods in the deployed position.
5. Check that folding / assembly motion still makes sense.

### Later feature: locking / tightening mechanism

Potential future work includes:

- cam tightening mechanism,
- constrained plate slots,
- retention features preventing accidental disengagement,
- manufacturable timber/steel detail decisions.

## Constraints and design decisions to preserve

- Coordinate system:
  - `X` = distance from guide toward plate
  - `Y` = vertical
  - `Z` = across width / stack direction
- Guide face for the arms is at `X = 0`.
- Arms lean in the `X–Z` plane.
- `gap_mechanism.scad` is the current source of truth for mechanism behavior.
- Rod axis placement shown below is correct and should be preserved:

```scad
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
```

## Suggested Claude workflow in VS Code

For each change:

1. Start with a short description of the intended minimal edit.
2. Keep code changes localized and commented.
3. Prefer preserving existing names and modules.
4. Render after each small step.
5. Compare against `gap_mechanism.scad` as the baseline.
6. Only refactor after the integrated model is working.

## Near-term milestones

### Milestone A
Standalone mechanism logic fully understood and documented.

### Milestone B
Mechanism logic successfully integrated into `main.scad`.

### Milestone C
Plate-end rod engagement geometry works in the integrated model.

### Milestone D
Arm notches latch onto rods.

### Milestone E
Locking / tightening mechanism added.
