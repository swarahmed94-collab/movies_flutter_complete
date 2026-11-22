# Figma provenance and fidelity constraints

Figma design: https://www.figma.com/design/6LGaUNXaT3E6MID0KgYVGr/Movies--Copy-?node-id=55-1281

Direct Figma layers and variables were not accessible to the connected account. Only the 20 actual supplied PNG exports could be used. Nineteen are 430 × 932 and one Movie Details export is 430 × 2961. They are retained intact in `design_reference/screens/`.

Colors sampled from exports: #121312 background, #282A28 surfaces, #F6BD00 yellow accent, #E82626 red action. These are approximate raster RGB samples, **not** confirmed Figma color tokens. Original separate SVG layers were not in the attached ZIP; `assets/icons/` contains **recreated** vector icons rather than claiming byte-identical original exports. The avatar and onboarding art images were extracted/cropped from the user-supplied PNGs and are used as legitimate component assets, not as full-screen UI.

Full interactive pixel-to-pixel verification requires compiling Flutter on a reference device and comparing screenshots; this could not be done here. `docs/SCREEN_COVERAGE.md` maps all 20 exports to routes or states.
