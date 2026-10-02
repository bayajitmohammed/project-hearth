---
tags: [game-design, navigation]
---

# Design Guide

Use this note as the map of the vault. The notes are organized from the broadest intent down to implementation and temporary work.

## Read these first

1. [[00 Start Here]] — the concise current direction and the ideas that are no longer part of it.
2. [[Design Questions]] — the accepted decision index. Use this when you want to know what has actually been decided.
3. [[Prototype and Vertical Slices]] — the production roadmap, implemented slice records, and current handoff.
4. [[Cumulative Slices 1-6 Playtest Checklist]] — the temporary active test plan. Delete it only through the completion process written inside the note.

## How information trickles down

```text
00 Start Here
  → Design Questions
    → one detailed subject note
      → Prototype and Vertical Slices
        → active playtest checklist
          → Godot implementation
```

- **Current direction:** [[00 Start Here]] is the short summary.
- **Accepted decisions:** [[Design Questions]] is the authoritative index.
- **Detailed reasoning:** the linked subject notes explain each system.
- **Production status:** [[Prototype and Vertical Slices]] says what the build proves and what remains deferred.
- **Temporary execution work:** notes in `90 Active Work` are checklists, not permanent design decisions.

If two notes appear to disagree, use that order of authority and update the lower-level note after the decision is settled.

## Browse by subject

### 01 Vision — what experience are we making?

Folder map: [[00 Vision Map|Vision Map]]

Read in this order:

1. [[World Premise]]
2. [[Player Fantasy]]
3. [[Core Play Loop]]
4. [[Session and Presentation]]

### 02 World and Play — what happens in the world?

Folder map: [[00 World and Play Map|World and Play Map]]

Start with [[World Shape and Building]], then follow the system you care about:

- [[Living World]] — NPC routines, settlement conditions, and remembered changes
- [[Exploration and Combat]] — discovery, travel, danger, and combat
- [[Stories and Consequences]] — stories, failure, death, and offline behavior
- [[Solo and Cooperative Play]] — solo value, cooperation, and 2–8 player scaling

### 03 Progression and Activities — why do players keep playing?

Folder map: [[00 Progression and Activities Map|Progression and Activities Map]]

- [[Player Progression]] — personal mastery and bounded power
- [[Shared World Progression]] — projects, settlements, and the chronicle
- [[Life Skills and Economy]] — gathering, production, trade, and currency
- [[PvP and Party Activities]] — opt-in contests, festivals, and social activities

### 04 Production — how is it built and validated?

Folder map: [[00 Production Map|Production Map]]

Read in this order:

1. [[Design Questions]] — accepted decision index
2. [[Prototype and Vertical Slices]] — cumulative roadmap and current status
3. [[First Vertical Slice]] — original “A New Home” proof
4. [[Technical and Business Research]] — platforms, architecture, hosting, and business constraints
5. [[AI Asset Policy]] — asset provenance and disclosure rules
6. [[Discord]] — deliberately deferred integration boundary

### 90 Active Work — what needs attention now?

Folder map: [[00 Active Work|Active Work]]

- [[Cumulative Slices 1-6 Playtest Checklist]] — the current temporary validation checklist

## Where to write new information

- Put a new accepted design decision in its subject note and summarize it in [[Design Questions]].
- Put a change to the overall pitch or direction in [[00 Start Here]].
- Put implementation scope and validation status in [[Prototype and Vertical Slices]].
- Put short-lived tasks and test checklists in `90 Active Work`.
- Keep code, exports, and technical test scripts in the Godot project rather than this vault.

---

Previous: [[00 Start Here]] · Next: [[Design Questions]]
