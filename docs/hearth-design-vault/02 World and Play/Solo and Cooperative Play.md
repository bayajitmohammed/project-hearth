---
tags: [game-design, multiplayer]
---

# Solo and Cooperative Play

> [[00 Start Here|Home]] › [[01 Design Guide|Design Guide]] › **02 World and Play** · Previous: [[Stories and Consequences]] · Next section: [[Player Progression]]

## Solo

Solo play supports scouting, gathering, building, farming, crafting, trading, small requests, and personal story steps. Dangerous group content can be postponed or attempted with NPC help. Solo players are never forced to defend the world on a timer.

Solo play is available in a device-local offline world and does not require an internet connection or a separate server process. Offline worlds remain separate from hosted shared worlds unless a future explicit world-transfer feature is added.

## Ways to play together

- **LAN host:** one player's native game owns the authoritative world and save while up to seven nearby players join over the local network.
- **Networked room:** every player is a client of an authoritative dedicated room, suitable for friends who are not on the same network.
- **Offline:** the local game runs those same authoritative rules for one player without opening a network listener.

Browser builds can play offline or join LAN and networked rooms, but do not host a room because the browser platform cannot listen as a WebSocket server. The modes share world logic so changing from one transport to another does not create different gameplay rules.

## What friends change

Friends create parallel roles and interactions: one distracts a creature while another completes an objective; players carry complementary tools; a nearby braced Guardian can intercept one telegraphed hit for a companion; a prepared player can spend a trail provision to aid an injured friend; group choices provoke conversation; rescues, celebrations, and mistakes create stories. Cooperation opens approaches rather than only reducing difficulty. Guardian interception never replaces solo defense: every player can still brace or evade, and the threatened player's own brace resolves first.

The first direct inventory handoff lets a standing player give one carried trail provision to the nearest nearby standing friend who is already healthy. Downed friends are revived first, injured friends are aided first, and valid world interactions remain ahead of a handoff, so an ordinary interaction cannot quietly replace an urgent or intended action. Equal-distance recipients resolve by stable player identity. The transfer conserves exactly one item, grants no mastery or coin, and is simply unavailable when playing alone.

## Scaling from two to eight

Encounters scale their mix of threats and simultaneous jobs, not just health. Objectives expose more parallel tasks for larger groups. Loot is personal, shared project credit is automatic, and players can join or leave between moments without resetting the outing. Major irreversible choices require clear group consent.
