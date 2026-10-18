# One More Flight — nine-ability redesign

This owner-approved ability roster supersedes the earlier combo, refill, time-budget and level-cap rules. Story, artwork, chapter goals, event choices and keepsakes are unchanged. Numeric values are starting tuning values, not a claim of final balance or measured human pacing.

## Ability roster

All nine abilities last for the rest of the current chapter and can be selected repeatedly. max_level=0 means unlimited levels. Existing resource IDs remain stable.

| Stable ID | Ability | Effect at level L |
| --- | --- | --- |
| appointment | Gringo Influence | +25% regular tap income per level |
| love | Nicky Mode | Each successful tap adds 0.1% × L of chapter base tap value to subsequent regular taps |
| facetime | FaceTime Date | Every tenth tap adds 5 × L base-tap equivalents |
| cabrito | Cabrito Power | Chance of doubling regular taps = 1 − 0.9^L (10%, 19%, 27.1%, …) |
| team | Well Rested | +L seconds at the start of every workday |
| playlist | Norteno Playlist | Every 50 taps adds 0.5 × L seconds to the current workday |
| flights | Volaris Red-Eye | Each selection multiplies the remaining ticket price by 0.92 |
| jar | Passive Income Princess | Day-end interest is 20% at level one, plus 5 percentage points per additional level |
| tips | One Wish Willow | +50 × L base-tap equivalents at day-end |

CEO (empire), Jake Wants Meat (cafecito), and Jake’s Protection (blessing) are retired. Their unused .tres Resources and inactive blessing calculations have been removed. Their old artwork is retained; migration still discards retired IDs without loading those Resources.

## Earnings and time

Base taps remain $5 / $10 / $17.50 by chapter. Base ticket goals remain $2,100 / $5,300 / $11,000. The base workday is ten seconds.

Regular tap value is base × (1 + Gringo bonus + earned Nicky growth). Cabrito may double this regular component, independently of existing event charge boosts. The first-ten-tap hoodie keepsake and Matching Underwear retain their existing multipliers. FaceTime Date adds its milestone bonus separately, so Cabrito does not double it. The former Unlimited FaceTime keepsake no longer pays a tenth-tap bonus.

Nicky growth is earned after each tap’s payout, improves future taps, persists across workdays and saves, and resets at the chapter boundary. Buying a new Nicky level improves growth on subsequent taps; it does not retroactively multiply growth already earned. There is no combo, speed window or activation threshold.

The 50-tap music counter resets each workday; there is no shared or daily extension cap. Higher levels add more time at every activation. Well Rested and Norteno Playlist stack fully. Work still ends immediately upon reaching the flight goal. Very high music levels can sustain a workday if tapping is sufficiently fast, but the savings milestone still ends it; no hidden anti-sustain cap was introduced.

At day-end, settle Willow’s cash (including the earnings keepsake multiplier), then Princess interest on the resulting savings. For example, $500 plus level-one Willow ($250 in Denver) and level-one Princess yields $900. With Princess alone it yields $600. Interest is not directly multiplied by Matching Underwear. Both payouts happen exactly once before milestone checking, and a newly chosen reward first benefits a later workday.

Volaris has no old 50% discount floor. Each level reduces the remaining ticket price by 8%; Passport independently applies its 12% keepsake reduction. No time, level, Nicky-growth or interest gameplay caps were added. Finite-number validation on loaded data remains corruption protection.

## Rewards, events and migration

After each below-goal workday, offer three distinct abilities. Each card chooses the new category with 65% probability or owned with 35%, conditional on available candidates, then selects uniformly within the category. All-owned/all-new fallback remains supported. Cards and details show current → next effects.

After the reward, the existing event occurs on every third completed below-goal chapter day. Event choices, cash gifts, temporary double-tap charges (60 shared-charge limit), no-consecutive-repeat selection and persistence remain unchanged. Jake’s Protection is no longer offered, so events have no new amplifier. Negative automatic events are a separate future change.

Snapshot version 4 persists Nicky growth and the 64-bit gameplay RNG state as a decimal string to avoid browser JSON rounding and reload rerolls. Versions 1–3 still load. Retired ability IDs are ignored; owned old Cabrito refill counts migrate to one permanent chance level; old combo fields are ignored and Nicky starts without fabricated historical growth. Existing levels of retained abilities use their new effects. Remaining time is validated against starting time plus music activations earned by that day’s taps, rather than an obsolete 16-second cap. Completed local results and settings retain their separate formats and are not erased.

## Updated keepsakes

Mind Reader (stable ID postcard) retains automatic earnings of two chapter base taps per active second: $20/sec in Italy and $35/sec in the final chapter before Matching Underwear. Lip-Stained Passport (passport) retains a 12% ticket reduction. Their simpler titles and descriptions do not change mechanics.

Your Biggest Fan replaces Unlimited FaceTime while retaining the stable ID unlimited and its artwork path. Whenever the player confirms a free ability choice, it has a 25% chance to apply that same ability a second time. This adds exactly one extra level, never recursively rolls, and supports new or owned abilities. Both Volaris levels apply their individual 8% price reductions. Direct grants (including Goodbye Kiss), events, keepsake choices, invalid actions and duplicate confirmations do not roll. The result and RNG state are saved by the existing reward settlement before the next screen, so reloading does not reroll. A notice announces a successful bonus. Existing saves with unlimited receive the replacement behavior; no save format change is needed.

Human session duration and real-device interaction require playtesting. Seeded full-campaign simulation results belong in docs/VALIDATION.md; do not reuse timings measured under the old ability system.
