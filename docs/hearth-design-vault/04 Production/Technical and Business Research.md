---
tags:
  - game-design
  - research
  - technical
  - business
---

# Technical and Business Research

> [[00 Start Here|Home]] › [[01 Design Guide|Design Guide]] › **04 Production** · Decisions: [[Design Questions]]

**Questions:** 25 (platforms, networking, persistence, servers), 26 (sales and post-launch), and 27 (engine and technical structure)
**Sources checked:** 2026-10-01

## Recommended answer

### 25. Platforms, networking, persistence, and servers

- **Initial targets:** Ship **Windows desktop, desktop browser, and native Android** together. Keep iOS separate until there is a macOS/Xcode build-and-test path. Linux and macOS desktop are later options.
- **Shared performance target:** Build from Slice 1 with Godot's **Compatibility renderer**, scalable effects, responsive layouts, and keyboard/mouse, controller, and touch input. Browser and phone limits must shape the game from the start, not be treated as ports.
- **Network model:** Use an **authoritative host/server**. Clients send intentions; the server owns combat, inventory, NPCs, world changes, and saves.
- **Play modes:** Offer a device-local offline world, a native player-hosted LAN world, and a dedicated networked room. All three use the same authoritative simulation. Offline and hosted worlds use separate local saves so playing alone never requires internet access and never silently mutates a shared-room save.
- **Cross-platform transport:** Start with **secure WebSockets (`wss://`)** between every client and a headless Godot server. This is the simplest transport shared by browser, Windows, and Android. Do not base the core protocol on Steam Networking or ENet/UDP because browser clients cannot use them.
- **Hosting modes:** Begin with one capped official Linux VPS that hosts multiple rooms and sleeps empty worlds. Also provide a free headless server for technically confident groups. Browser clients need a trusted `wss://` endpoint, so self-hosting is an alternative—not the default browser experience.
- **LAN hosting:** Native clients may host a WebSocket room on the local network and play as the authority while friends join. Browser clients may join that room but cannot host a listening WebSocket server.
- **Browser rule:** A browser may run the local-authority offline mode for development or casual solo play, but it cannot host a listening room and should not be treated as a durable persistent-world authority. Background tabs can pause and browser-local storage can be unavailable or evicted.
- **Persistence:** The server stores one versioned save per world: world seed, changed regions, characters, inventories, quests, and event state. Save only changes to generated terrain, use atomic/checkpointed writes, keep rolling backups, and provide export/import. Official rooms use server storage; self-hosted worlds remain independent.
- **Simulation:** Pause ordinary world simulation when nobody is online. Resolve only selected time-based systems on the next login. This preserves persistence without paying to simulate empty worlds.
- **Launch capacity:** Do **not** begin with a fleet. Run the public test on one small Linux VPS, cap concurrent rooms, and add another server only when measured use requires it. Consider paid always-on worlds later if demand and measured cost justify them.
- **Early server choice:** Use a plain Linux VPS, not Kubernetes or a managed game-server fleet. AWS Lightsail is a predictable/global pilot; a 2 GB plan is currently **$12/month** and 4 GB is **$24/month**. Benchmark before promising how many rooms fit on one machine.

**Why this is realistic:** Browser and mobile players get a simple room-code flow, while sleeping empty worlds and capped capacity bound the developer's initial bill. Self-hosting remains an escape hatch for dedicated groups.

**Slice 1 hosting note:** Run the headless Godot process directly on the Mac for private-network tests; Docker adds no useful isolation or scaling at this stage. Reconsider Docker when deploying the exported dedicated server to Linux or automating multiple server instances. Godot supports containers, but treats them as an optional deployment approach rather than a requirement. [Godot dedicated servers](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_dedicated_servers.html)

### 26. Business model and post-launch

- Sell a **complete premium game per player**, with no required subscription, ads, loot boxes, power sales, or paid currency.
- **Price: Not decided.** Set it only after a playable slice establishes current player value, content depth, replayability, and comparable games. AI assistance should be disclosed, but price should reflect what the buyer receives rather than hours manually spent.
- **Initial distribution:** Steam is **not currently committed**. Use itch.io or a project website for the desktop-browser build and DRM-free Windows/Android downloads. Google Play is optional when store testing and support are worthwhile.
- An embedded itch.io browser game can accept donations but cannot itself be sold as paid access. If one purchase must unlock all three versions, that requires a downloadable paid project or a separate account/payment entitlement system. Decide this only after the slices prove demand.
- Treat Steam as a later Windows discovery/sales option. AI-generated assets are allowed if accurately disclosed and legally usable; Steam does not remove the need to document each asset's commercial rights and provenance.
- After launch: bug fixes and small world/content additions are free. Sell a substantial expansion only after the base game is stable. A cosmetic supporter pack is acceptable if it never affects power or separates friends.
- Keep the dedicated server and local hosting free. If official always-on worlds are later offered, sell them **per world**, not per player, with a clear player cap and cancellation/export path. Set the price only after measuring real server usage; do not subsidize it from uncertain future sales.
- Avoid a live-service promise. Publish a small, credible update schedule and expand it only when revenue supports the work.

**Why this is sustainable:** Revenue arrives with each copy while the base game creates no unavoidable per-player hosting cost. Optional recurring hosting pays for the recurring service it creates.

### 27. Engine and technical structure

- Use the current stable **Godot 4.x** release and **GDScript** for the first prototype and production unless profiling proves a hot system needs native code.
- Keep one project and one gameplay simulation. Export Windows, Web, Android, and a stripped headless Linux server from it, with small platform adapters for input, storage, and storefront features.
- Make the headless server authoritative from Slice 0. All three clients connect to the same room service, preventing a later multiplayer rewrite.
- Separate simulation rules from scenes, visuals, UI, and platform services. Store items, abilities, encounters, NPC schedules, and region templates as data rather than hard-coded branches.
- Generate regions from a seed and save only player/NPC changes in versioned region files. Use checkpoints, a small write journal, rolling backups, and save migration tests.
- Begin as a modular monolith: one room server, a small room directory, and versioned world saves. Slice 0 uses temporary owner/room tokens; add accounts only when cross-device ownership or payment requires them. Avoid microservices and Kubernetes.

**Why this fits:** Godot has no engine fee, exports to every intended platform, and supports headless dedicated servers. The risk is Web performance and networking, so every slice must run on Windows, desktop Web, and a representative Android phone before it counts as complete.

## Facts supporting the recommendation

- Godot 4 Web uses WebGL 2 with the Compatibility renderer; Forward+ and Mobile renderers are unavailable. Native mobile exports perform significantly better than Web. Web builds may lose persistence, pause when their tab is backgrounded, and support only HTTP, WebSocket client, and WebRTC networking. [Godot Web export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html)
- Godot's WebSocket multiplayer peer works with its high-level multiplayer API. WebRTC is built into Web exports but needs an external extension on native platforms, adding integration risk for the first slices. [Godot WebSocket peer](https://docs.godotengine.org/en/stable/classes/class_websocketmultiplayerpeer.html) · [Godot WebRTC](https://docs.godotengine.org/en/stable/tutorials/networking/webrtc.html)
- Godot supports native Android export. Google Play requires an Android App Bundle and signing; a Play Console account has a **US$25 one-time registration fee**, and new personal accounts have testing and device-verification requirements. [Godot Android export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html) · [Google Play registration](https://support.google.com/googleplay/android-developer/answer/6112435)
- Godot iOS export requires a Mac with Xcode. App Store distribution requires the Apple Developer Program, currently **US$99 per year**. This is why iOS is a separate launch decision, not assumed from Android support. [Godot iOS export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html) · [Apple membership](https://developer.apple.com/support/compare-memberships/)
- itch.io can host a browser build and platform downloads. Its HTML upload limits are 500 MB extracted, 200 MB per file, and 1,000 files. Embedded HTML games accept donations rather than paid access. itch.io asks creators to disclose generative AI and may remove minimally curated, predominantly automated projects from discovery. [itch.io HTML games](https://itch.io/docs/creators/html5) · [itch.io AI guidelines](https://itch.io/docs/creators/quality-guidelines#ai-disclosure)
- Steam does not ban generative-AI content. Its Content Survey requires disclosure of pre-generated and live-generated AI; developers must warrant that shipped material is legal and non-infringing, while live generation also requires guardrails. Steam separately forbids content the developer lacks rights to distribute. [Steam Content Survey](https://partner.steamgames.com/doc/gettingstarted/contentsurvey) · [Steam Direct rules](https://partner.steamgames.com/steamdirect/)
- A Steam release currently requires a **US$100 per-product fee**, recouped after **US$1,000 adjusted gross revenue**, plus a 30-day wait after paying, at least two weeks with a public Coming Soon page, and review. Valve's pricing guidance emphasizes customer value, comparable games, replayability, and current scope. [Steam Direct](https://partner.steamgames.com/steamdirect/) · [Steam pricing](https://partner.steamgames.com/doc/store/pricing)
- Steam Early Access must already be a playable product worth its current price; it is not intended for concept testing. Steam Playtest is free for controlled testing and cannot be sold. [Steam Early Access](https://partner.steamgames.com/doc/store/earlyaccess) · [Steam Playtest](https://partner.steamgames.com/doc/features/playtest)
- Epic Online Services offers free, engine/store-independent multiplayer services, including P2P, lobbies, and sessions. The SDK supports PC and Android, but the ready-made social overlay is not supported on macOS, Linux, or Android, so those platforms need custom invite/account UI. [EOS FAQ](https://onlineservices.epicgames.com/faq) · [EOS multiplayer](https://onlineservices.epicgames.com/multiplayer) · [EOS SDK](https://onlineservices.epicgames.com/sdk) · [EOS overlay limits](https://dev.epicgames.com/docs/epic-online-services/accounts-and-social/social-overlay/sdk-integration)
- Godot can export a headless dedicated server and strip client-only visuals. [Godot dedicated servers](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_dedicated_servers.html)
- Godot is MIT-licensed with no engine royalty, and its official export targets include Windows, macOS, Linux, Android, iOS, and Web. [Godot license](https://godotengine.org/license/) · [Godot platform support](https://docs.godotengine.org/en/stable/about/faq.html#which-platforms-are-supported-by-godot)
- AWS Lightsail currently lists predictable Linux VPS bundles at **$12/month for 2 GB RAM, 2 vCPUs, 60 GB SSD, 3 TB transfer**, or **$24/month for 4 GB RAM, 2 vCPUs, 80 GB SSD, 4 TB transfer**. Actual game capacity is unknown until measured. Snapshots cost **$0.05/GB-month**. [AWS Lightsail pricing](https://aws.amazon.com/lightsail/pricing/)
- Store economics vary. itch.io lets sellers choose its revenue share from 0–100% (10% default, plus payment processing). Epic currently charges 0% on the first $1 million of Epic-processed revenue per app per year, then 12%. These lower cuts do not guarantee enough customers to justify simultaneous launches. [itch.io payments](https://itch.io/docs/creators/payments) · [Epic revenue share](https://store.epicgames.com/en-US/news/new-epic-games-store-webshops-and-revenue-share-update)

## Decisions to validate with prototypes

1. How many 1–4 player rooms fit on the first VPS at the target simulation density?
2. How large and write-heavy does a 20-, 100-, and 500-hour world save become?
3. How many quiet and active worlds fit on a 2 GB and 4 GB VPS?
4. Does host migration matter, or is reconnecting to the owner/dedicated server acceptable?
5. Can the same encounter remain readable and responsive on desktop Web and a representative Android phone?
6. Is secure WebSocket latency acceptable for combat? If not, test WebRTC before changing the game design or dropping a target.
7. Can the browser build stay within itch.io's size limits and reach play quickly enough on ordinary connections?
