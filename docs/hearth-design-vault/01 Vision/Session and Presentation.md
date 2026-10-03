---
tags: [game-design, sessions, presentation]
---

# Session and Presentation

> [[00 Start Here|Home]] › [[01 Design Guide|Design Guide]] › **01 Vision** · Previous: [[Core Play Loop]] · Next section: [[World Shape and Building]]

## Session rhythm

- **10–20 minutes:** tend, craft, trade, decorate, or complete one local request.
- **30–60 minutes:** explore a route, resolve an event, or improve a project.
- **60–120 minutes:** undertake a ruin, major journey, festival, or story chapter.

Players can return safely after most objectives. Long activities expose checkpoints, and scheduled events use generous windows rather than demanding attendance.

## Camera, controls, and style

Use a stylized, colorful 3D world viewed in first person by default, with an immediate toggle to a close over-the-shoulder third-person view. The third-person view stays around shoulder height rather than becoming a high or top-down camera. Shapes, animation, lighting, and color carry information so the game remains readable without dense UI.

Controls are controller-first with keyboard and mouse support. Combat uses a small action set; building switches to a precise placement mode. The art direction favors strong silhouettes and modular assets over realism, keeping a small team's content workload sustainable.

The implementation supports full 360° looking with captured mouse movement, controller right stick, or right-side touch drag. Desktop mouse look does not require holding a button; **Escape** releases the cursor. **V**, right-stick click, or the touch **View** button switches between first person and over-the-shoulder third person. Mouse wheel adjusts the stored third-person distance, and movement follows the camera direction.

On Android, use a Minecraft-like split-screen touch layout. The whole left half is a floating analog movement zone, while the whole right half is unobstructed for camera drag and direct taps on nearby world targets. A soft center crosshair changes when it finds a valid target; non-combat targets show one contextual action such as **Talk**, **Pick up**, or **Repair** near that target. Tapping a nearby creature attacks it, and tapping another valid target uses it. Crafting remains in the quest card when available. The joystick and contextual action scale within sensible limits for the screen, respect device safe areas, and stay softly translucent so they do not hide the world. Desktop browser, keyboard/mouse, and controller behavior remain unchanged.
