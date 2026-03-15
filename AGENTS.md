# AGENTS.md

## Project context

This repository contains an OpenSCAD model for a ladder stand-off / wall-gap mechanism.

Current relevant files:

- `gap_mechanism.scad` — current standalone development model for the gap mechanism. This is the authoritative source for the current mechanism work.
- `gap_mechanism_test.scad` — reusable hinge/arm test code currently referenced by `gap_mechanism.scad` via `use <gap_mechanism_test.scad>`.
- `main.scad` — the broader ladder assembly model.
- `ladder_parts.scad` — reusable modules for the main ladder assembly.
- `ladder_calc.scad` — calculation / cut-list helpers for the broader ladder project.

The immediate next step is to integrate the current `gap_mechanism.scad` logic into the main ladder model, replacing the mechanism logic currently in `main.scad` or related files.

## Ground rules for edits

1. Treat `gap_mechanism.scad` as the current source of truth for the mechanism geometry.
2. Keep changes localized and easy to review in git diffs.
3. Prefer adding small helper functions/modules over large rewrites.
4. Preserve existing working geometry unless the task explicitly requires changing it.
5. Avoid speculative refactors while the mechanism is still evolving.
6. When moving logic into `main.scad`, preserve parameter names and coordinate conventions unless there is a strong reason not to.
7. Keep `gap_mechanism_test.scad` usable as a hinge/arm debug file until the integration is stable.
8. When uncertain, add temporary debug geometry rather than guessing.

## Coordinate system

OpenSCAD coordinate conventions for the mechanism:

- `X` = distance away from the guide surface / toward the hanging plate
- `Y` = vertical direction
- `Z` = across the width of the guide / hanging plate / arm stacking direction

Important plane/edge conventions:

- The guide face that the arms hinge from is at `X = 0`.
- In `gap_mechanism.scad`, the hanging plate starts at `X = gap` and extends to `X = gap + plate_t`.
- The rods on the hanging plate have their axes coincident with the plate edge lines at:
  - `X = gap`
  - `Z = -plate_w/2` on the left side
  - `Z =  plate_w/2` on the right side

## Current mechanism design assumptions

### Guide-side hinges

- Eye-bolt hinge geometry is developed in `gap_mechanism_test.scad`.
- `gap_mechanism.scad` reuses that code with `use <gap_mechanism_test.scad>`.
- The eye-bolt rod radius must match the ring stock radius.
- The arm pivot centre is offset from the guide face by `arm_t / 2`.
- Arm rounding is centred on the eye centre.

### Arms

- Arms are rectangular timber strips.
- `arm_w` is the width across the stack.
- `arm_t` is the thickness in the folding plane.
- The arms lean in the `X–Z` plane.
- `draw_link_3d()` currently treats arm direction using only `dx` and `dz`, not `dy`.
- This is intentional for the current mechanism model.

### Hanging plate rods

The current accepted rod placement is:

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

This should be treated as correct unless the user explicitly changes the design.

### Plate-end arm intent

The current design intent is that:

- each side has one rod,
- both arms on that side engage that rod,
- the rod axis lies on the plate edge,
- the arms should be positioned so the correct side of the arm meets the rod axis,
- the arms will eventually receive half-round notches with the same radius as the rod so they can latch onto it.

## Immediate priority

Integrate the current `gap_mechanism.scad` behavior into the main assembly.

That means:

1. Identify where the gap mechanism belongs in `main.scad` and related included files.
2. Replace the older mechanism code with the newer mechanism code from `gap_mechanism.scad`.
3. Preserve the working hinge reuse via `gap_mechanism_test.scad` unless and until there is a better dedicated shared file.
4. Keep the integration incremental and verifiable.

## Preferred way of working

When making changes:

1. First explain the minimal change set.
2. Then edit only the necessary code.
3. Keep comments marking new work, for example:

```scad
// --- LOCAL CHANGE: ... ---
...
// --- END LOCAL CHANGE ---
```

4. Avoid silently renaming lots of variables.
5. Preserve the currently accepted geometry choices even if a different design might be cleaner.

## Things to be careful about

- Do not accidentally move arm stacking from `Y` to `Z` or vice versa without checking the current design intent.
- Do not replace the currently accepted rod-edge positioning logic.
- Do not change `gap_mechanism_test.scad` in a way that breaks reuse from `gap_mechanism.scad` unless integration requires it.
- Do not introduce large structural refactors during mechanism development.
- Remember that some previous attempts picked the wrong tangent solution for plate-side arm placement.

## Suggested short-term workflow

1. Keep `gap_mechanism.scad` rendering correctly.
2. Port its logic into the main assembly in small steps.
3. Use temporary debug geometry when alignment is unclear.
4. Once integrated, resume work on plate-side rod engagement and arm notches.
