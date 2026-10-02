---
tags: [active-work, playtest, checklist, temporary]
status: ready
---

# Cumulative Slices 1–6 Playtest Checklist

> [!IMPORTANT]
> This is a temporary execution note. Do **not** delete it merely because a test session ended. After every required item is checked, mark the completion gate at the bottom and give this note back to Codex. Codex will first record the durable results in [[Prototype and Vertical Slices]], then delete this checklist after your confirmation.

## Purpose

Validate that a fresh player can understand and complete the cumulative game from **A New Home** through **Gather and Celebrate**, and that the same saved world works on desktop Web, Windows, and native Android.

The tester should receive controls and connection information, but no explanation of objectives or solutions unless the session is blocked. Record every place where help was required.

## Test record

- Date:
- Build or commit:
- Server machine:
- Tester names or labels:
- Tester familiarity with the game:
- Desktop Web browser/version:
- Windows device/version:
- Android device/version:
- Room code:
- Fresh save path or identifier:

## 1. Prepare one controlled build

- [ ] Choose one exact build/commit for every client and record it above.
- [ ] Rebuild the desktop Web, Windows, and Android clients from that same revision.
- [ ] Start the authoritative server with a new room code and a genuinely fresh save.
- [ ] Confirm no previous world or player data appears after the first connection.
- [ ] Prepare a way to record observations, screenshots, device details, and defects without coaching the tester.
- [ ] Give the tester only the connection address, room code, and basic controls.

## 2. Fresh-player understanding

- [ ] A fresh player connects without developer intervention.
- [ ] The player understands the current objective from the world and UI.
- [ ] The player can identify interaction, movement, camera, attack, and crafting controls.
- [ ] Every time the player asks what to do, record the exact location and confusion before helping.
- [ ] Record any unreadable label, overlapping UI, unclear landmark, or misleading prompt.
- [ ] At the end, ask what the player believes happened to the world.
- [ ] At the end, ask what the player would want to do next.

## 3. Complete the cumulative journey

### Slice 1 — A New Home

- [ ] Meet Mara and understand the cottage request.
- [ ] Gather wood and herbs and recover the lost supplies.
- [ ] Craft the repair kit.
- [ ] Complete all three cottage repairs.
- [ ] Confirm the repaired home, reputation, rumor, and chronicle entry appear.

### Slice 2 — A Place That Remembers

- [ ] Talk to Mara after repairing the cottage.
- [ ] Find and light all three welcome lanterns.
- [ ] Confirm Mara’s location, lit lanterns, morale, reputation, and chronicle entry change persistently.

### Slice 3 — Beyond the Road

- [ ] Follow the northern rumor and discover Northwood.
- [ ] Discover the Old Stone Ruins and see the shared map update.
- [ ] Encounter and defeat the ruin guardian.
- [ ] Exercise the failure loop at least once: cooperative revive or solo return to safety.
- [ ] Restore the ruin waystone and use both directions of fast travel.
- [ ] Confirm the restored route and chronicle entry persist.

### Slice 4 — Choose a Life

- [ ] Understand the neighborhood food need without explanation.
- [ ] Harvest all four moonroot plots.
- [ ] Cook two hearth stews.
- [ ] Deliver both stews to the market.
- [ ] Confirm Farming, Cooking, and Trade mastery credit goes to the contributing player.
- [ ] Confirm the produce stall, morale, reputation, and chronicle entry appear.

### Slice 5 — Our Shared World

- [ ] Confirm the HUD reports the correct active-player count out of eight.
- [ ] Disconnect and reconnect without losing personal or shared progress.
- [ ] Confirm a second active client cannot use the same player identity.
- [ ] Leave the room empty long enough for bounded pantry catch-up, then reconnect.
- [ ] Confirm catch-up never exceeds three pantry provisions and causes no decay or damage.
- [ ] Take one personal trail provision.
- [ ] Become downed away from home and return to safety, leaving a recovery pack.
- [ ] Recover the pack with its owner or another player and confirm the provision returns to the owner.
- [ ] Restart the server and confirm the world, provisions, and any unrecovered pack persist.

### Slice 6 — Gather and Celebrate

- [ ] Find the Hearthlight Festival and understand how to opt into the circuit.
- [ ] Enroll at least two players before starting the run.
- [ ] Confirm a player who did not opt in cannot advance the circuit.
- [ ] Complete all three checkpoints in order.
- [ ] Confirm the authoritative first finisher is shown consistently to every client.
- [ ] Confirm every finisher receives exactly one cosmetic ribbon.
- [ ] Confirm mastery, provisions, and equipment provide no competitive advantage.
- [ ] Confirm the first completion adds decorations, morale, reputation, and the fifth chronicle entry.
- [ ] Start a second circuit and confirm the activity is replayable without duplicating the first-completion world reward.

## 4. Cross-client multiplayer

- [ ] Run at least two clients simultaneously on different target types where possible.
- [ ] Confirm Web and Windows players can see one another move and interact.
- [ ] Confirm Web and Android players can see one another move and interact.
- [ ] Confirm shared objectives update on every connected client.
- [ ] Confirm individual mastery and festival ribbons remain attached to the correct identity.
- [ ] Confirm a player may join late or leave without resetting the current shared-world objectives.
- [ ] Confirm reconnecting never creates duplicated resources, rewards, or active player copies.
- [ ] Record latency, stutter, disconnections, or inconsistent state seen by only one client.

The automated eight-client capacity probe already checks the room limit. A human eight-device session is optional unless the smaller cross-platform test exposes a scaling problem.

## 5. Target-platform runtime pass

### Desktop Web

- [ ] Export loads in a fresh Chromium profile with no blocking console errors.
- [ ] Connection, keyboard movement, interaction, attack, crafting, and camera toggle work.
- [ ] First-person and over-the-shoulder presentation remain readable throughout the journey.
- [ ] Reconnect and save persistence work.

### Windows desktop

- [ ] The exported build launches with its `.pck` present.
- [ ] It reaches the authoritative server over the private network.
- [ ] Keyboard/mouse and controller controls used during the test work correctly.
- [ ] Rendering, UI scaling, camera, reconnect, and persistence show no platform-specific blocker.

### Native Android

- [ ] The APK installs and launches on the chosen device or emulator.
- [ ] Touch movement, right-side camera drag, Use, Attack, Craft, and View controls work.
- [ ] UI remains readable without covering essential world information or controls.
- [ ] Connection, reconnect, background/resume behavior, and persistence work.
- [ ] Performance and device temperature remain acceptable for the full session.

## 6. Persistence and regression

- [ ] Stop every client, then restart the server and reconnect.
- [ ] Confirm cottage repairs, lanterns, discoveries, waystone, produce stall, festival decorations, reputation, morale, and chronicle remain correct.
- [ ] Confirm personal mastery, provisions, recovery packs, and festival ribbons remain assigned correctly.
- [ ] Confirm completed resources and rewards cannot be collected twice.
- [ ] Run the repository’s complete headless test suite after the manual session.
- [ ] Re-run the focused two-client festival probe after any networking fix.
- [ ] Re-run the exported desktop Web check after any code or presentation fix.

## 7. Findings and fixes

- [ ] Every blocker has a written reproduction case.
- [ ] Every platform-specific issue names the device, OS, and build.
- [ ] All release-blocking defects found during this pass are fixed and retested.
- [ ] Non-blocking improvements are either completed or deliberately moved to a durable backlog/design note.
- [ ] No unresolved issue is hidden by marking the broader checkbox complete.

### Findings

- None recorded yet.

## Completion gate

- [ ] All required checkboxes above are complete.
- [ ] No release-blocking defect remains open.
- [ ] The full cumulative journey passed on desktop Web.
- [ ] The full cumulative journey passed on Windows desktop.
- [ ] The full cumulative journey passed on native Android.
- [ ] A fresh player completed the journey and their comprehension feedback was recorded.
- [ ] Final result: **PASS**
- [ ] I have given this completed note to Codex for archival and deletion.

> [!CAUTION]
> **Deletion rule:** Keep this note until Codex has copied the lasting test result, platform details, and any deferred findings into [[Prototype and Vertical Slices]]. After you confirm that archival is correct, Codex may delete this temporary checklist.

---

Home: [[00 Start Here]] · Guide: [[01 Design Guide]] · Permanent status: [[Prototype and Vertical Slices]]
