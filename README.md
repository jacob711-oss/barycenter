# Barycenter

A 3D gravity sandbox that runs in your browser. Build star systems, add famous stars, planets and black holes, collide worlds, and run time from hours to 100 years per second.

**Play:** https://jacob711-oss.github.io/barycenter/

No install or account needed. Works on computers, tablets and phones.

**Also try Biosphere**, a living-world sandbox where plants and animals eat, breed and evolve: https://jacob711-oss.github.io/barycenter/life/

## Controls
- Drag to orbit the camera, right-drag to pan, scroll to zoom toward the cursor
- W A S D to move, Q E to rotate, R F up and down
- Double-click any object to fly to it
- Search bar: type a name (Antares, TON 618, Titan…) to fly to it or add it

Gravity is real Newtonian N-body physics using real masses and orbits where known; some visuals are artistic approximations.


## World leaderboard
The stars leaderboard uses a free Supabase database. To switch it on, run `supabase-setup.sql` in your Supabase project's SQL Editor, then put the project URL and the public (anon / publishable) key into `SB_URL` and `SB_KEY` in `index.html`.
