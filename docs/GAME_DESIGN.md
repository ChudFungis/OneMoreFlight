# One More Flight — content and tuning

Dani runs her spa in Monterrey to fund Denver, Italy, then a permanent move to the United States to be with Josh. Chapter illustrations and affectionate prose are placeholders. Money uses fictional dollar units; the economy is entertainment, not real travel pricing.

## Initial economy

Edit `resources/balance.tres` in the Inspector; defaults are declared in `scripts/data/flight_balance.gd`.

| Parameter | Default |
| --- | --- |
| Workday | 15 seconds |
| Base tap | $5 |
| Chapter income scaling | 1 / 2 / 3.5 |
| Ticket goals | $2,100 / $5,300 / $11,000 |
| Upgrade price scaling | 1 / 2 / 3.5 |
| Event interval / probability | Every 3 completed days / 40% |
| Rapid-tap window | 0.6 seconds |
| Coffee extension cap | 9 seconds |

Per-upgrade base prices and effect amounts live in `.tres` definitions. Repeat purchase prices increase 35% per owned level. Ticket reductions compound to a floor of 50% of the ordinary goal; the Passport relic then applies its own discount. FaceTime counts every tenth shift tap; tips every seventh; playlist every fifth. Combo is capped at six taps, +120% at multiple levels; interest at 40% per workday. Playlist extension is capped at three seconds per day. These guardrails and cadence rules are explicit in GameManager.

Simulated seeded games buying one useful upgrade on early days:

| Taps/sec | Denver / Italy / Future days | Active work |
| --- | --- | --- |
| 2 | 6 / 8 / 9 | 369 s |
| 3 | 5 / 6 / 5 | 240 s |
| 4 | 4 / 4 / 5 | 195 s |

The initial **10–15 minute session target** includes reading, upgrade comparison, events and illustrated scenes, with roughly 20 seconds of decisions per workday. It is not a measured human playtime result. A fast player skipping text can finish sooner. Fifteen-second shifts and only 5–7 days/chapter inherently provide about 4–6 minutes of active tapping; no forced wait was added to inflate that. Human pacing validation remains necessary. Slower tapping, random offers, optional spending and relic selection change these totals. Tune goals/scaling first after a real playtest.

## Ordinary upgrades

| ID | Upgrade | Effect | Base cost |
| --- | --- | --- | --- |
| cabrito | Cabrito Power | Double next 20 taps; refill by buying again | 65 |
| facetime | FaceTime Date | Every tenth tap adds 8 base taps | 95 |
| appointment | Extra Spa Appointment | +30% base tap income/level | 70 |
| cafecito | Cafecito Extra Fuerte | +3 seconds/day, up to +9 | 80 |
| empire | Spa Empire | 3 base taps/sec/level during work | 100 |
| flights | Josh Found Cheap Flights | Current goal reduced 12% | 60 |
| love | Long-Distance Love | Rapid consecutive tap multiplier | 90 |
| blessing | Abuela’s Blessing | One consumable negative-event shield | 45 |
| playlist | Monterrey Playlist | Every fifth tap extends shift by 0.15s | 75 |
| tips | Telenovela Tips | Every seventh tap adds 5 base taps | 85 |
| jar | Little Heart Savings Jar | 8% interest/day/level, capped | 80 |
| team | Spa Besties | Passive +50%/level and 12 base taps immediately | 85 |

Examples of interactions: Besties amplifies Empire and Postcard passive earnings. FaceTime stacks with Unlimited FaceTime. Coffee allows more passive ticks and tap milestones. Combo, appointments, Cabrito and Hoodie multiply regular tap earnings; Bracelet also amplifies milestone and passive income. Interest rewards keeping money instead of buying everything.

## Relics

Choose one of three unique offers after Denver and Italy. Previously selected relics are excluded. Relics do not reset.

| ID | Relic | Effect |
| --- | --- | --- |
| hoodie | Josh’s Hoodie | First 10 taps/shift earn 50% more |
| unlimited | Unlimited FaceTime | Every tenth tap adds 6 base taps |
| kiss | Goodbye Kiss | Free Appointment at each new chapter start, including immediately after choosing it |
| passport | Heart-Stamped Passport | Future tickets cost 12% less |
| bracelet | Matching Bracelets | All work earnings +15% |
| postcard | Monterrey Postcard | 2 base taps/sec during work |

## Events

All happen between workdays, before upgrades. Events cannot interrupt a shift. Protection is consumed only by an actual loss outcome, not by choosing a beneficial alternative.

| ID | Event | Outcome / choice |
| --- | --- | --- |
| cancelled | Appointment Canceled | Lose 12% savings |
| gift | Abuela’s Secret Envelope | +40 base taps |
| call | Josh Is Calling | +20 base taps or double next 40 taps |
| sale | Fare Alert! | Goal reduced 10% |
| repair | The Steamer Revolts | Lose 18% savings |
| viral | Monterrey Loves Your Spa | +55 base taps |
| dinner | Tacos or Travel? | +15 base taps or spend 10% savings for Appointment |
| rain | Rainy Day Rescue | Lose 8% savings or accept Josh’s 8-tap gift |

`negative` describes the default event for content editing; protection is resolved from the selected `loss` effect so choice-based events behave correctly.

## Future product decisions

Personalized artwork and final prose, soundtrack, accessibility options, actual device playtime feedback, and any content beyond the three chapters remain open. There is no combat, character death, paid economy, or offline production in this design. The roguelike structure comes from random upgrades/events and persistent keepsakes across chapter resets.
