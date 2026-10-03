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

### Visual experience

The target is a welcoming, dreamlike fantasy place that feels good to inhabit before the player does anything productive. Environments use stylized natural shapes, rich but controlled color, soft atmospheric depth, warm pools of settlement light, readable magical accents, and weather and time-of-day ambience. Night should feel inviting and mysterious rather than flat, pitch-black, or hostile: moonlight, window glow, lantern paths, firelight, mist, foliage motion, insects, and restrained particles lead the eye and make travel emotionally appealing.

Characters are deliberately less anatomically detailed than the environment. Use compact, appealing proportions, clean silhouettes, simplified faces, modest clothing, and expressive posture and animation. Hands, held tools, and attack poses may be visible where interaction readability needs them, but avoid realistic anatomy, skin detail, or fully featured human rendering. The result should be clearly more shaped and organic than Minecraft-style cubes while remaining stylized, modular, and performant. Creatures follow the same silhouette-first language rather than graphic realism.

The interface may choose its final visual language during the dedicated art and UX pass, but it must feel crafted, beautiful, calm, and satisfying. Favor a small set of polished surfaces, legible typography, coherent iconography, gentle responsive motion, immediate feedback, and smooth transitions. UI should support immersion rather than cover the world, expose the next useful action without visual noise, and scale cleanly across desktop browser, Windows, and Android. Motion must respect reduced-motion needs, text and controls need accessible contrast and sizing, and important state cannot rely on color alone.

This direction becomes a production focus after the core systems and representative content loops are stable enough to build a reusable environment kit, character kit, lighting stack, and UI component library. Current prototype geometry may stay functional until then, but new visual work should not contradict this target. Before broad asset production, create and validate one representative beauty slice covering daytime, nighttime, one interior/exterior transition, first-person hands, a third-person character, and the core HUD on desktop and Android.

The implementation supports full 360° looking with captured mouse movement, controller right stick, or right-side touch drag. Desktop mouse look does not require holding a button; **Escape** releases the cursor. **V**, right-stick click, or the touch **View** button switches between first person and over-the-shoulder third person. Mouse wheel adjusts the stored third-person distance, and movement follows the camera direction.

On Android, use a Minecraft-like split-screen touch layout. The whole left half is a floating analog movement zone, while the whole right half is unobstructed for camera drag and direct taps on nearby world targets. A soft center crosshair changes when it finds a valid target; non-combat targets show one contextual action such as **Talk**, **Pick up**, or **Repair** near that target. Tapping a nearby creature attacks it, and tapping another valid target uses it. Crafting remains in the quest card when available. The joystick and contextual action scale within sensible limits for the screen, respect device safe areas, and stay softly translucent so they do not hide the world. Desktop browser, keyboard/mouse, and controller behavior remain unchanged.
