# One More Flight — content and tuning (v0.3.3 flow)

The three chapters, story, artwork paths, ordinary-upgrade resets and permanent relics remain. The source is `One_More_Flight_Final_Codex_Spec.xlsx` (all five sheets reviewed). Economy & Mechanics records v0.1; it does not override the proposed content or confirmed rules. All existing content IDs are retained.

## Rules and provisional tuning

Confirmed rules: 10-second base workdays; one free reward per below-goal completed workday; three unique viable choices when available; 65% new / 35% owned level-up selection independently for each card, conditional on remaining candidates; exactly one event on below-goal chapter days 3, 6, 9, etc.; no event penalties or ordinary upgrade costs. Savings now act as milestones, without a manual ticket purchase. Events avoid consecutive repeats within a chapter.

Order: settle work earnings and interest → check the discounted savings milestone. If reached, enter the story immediately and skip reward/event choices. Otherwise choose one reward → resolve the third-day event → automatic transition to the next workday. If a goal discount or event gift reaches the milestone after work, enter the story then. The event is selected at shift completion and saved alongside offers. Neither choice is rerolled by loading. Reward cards show NEW or the resulting LEVEL. Workday input, floating earnings, combo feedback, pause and autosave remain.

The owner approved these gap resolutions: a shared +6-second extension cap; Cabrito can recur below 60 charges without a level cap; music has four levels; offer fewer than three cards if necessary; advance past the reward only when no candidates exist. Time abilities that cannot increase duration because fixed extensions already fill the cap are excluded.

Proposed names and numeric balance values are implemented for testing, not promoted to final balance decisions. In particular, Volaris Red-Eye and Girls’ Night Boost remain provisional names. The v0.3.3 owner direction supersedes the workbook’s earlier two-day cadence; events now occur every third completed chapter day, with no probability roll. Final positive event choices override stale gamble/loss notes. No random-outcome or loss handler is needed.

Tune amounts and levels in `resources/upgrades/*.tres`, events and relics in their matching folders, and shared timing/weight values in `resources/balance.tres`. Story prose stays in `resources/story.tres`.

| Stable ID | Upgrade | Effect / maximum |
| --- | --- | --- |
| appointment | Gringo Influence | +25% regular tap income/level; 4 levels |
| blessing | Jake's Protection | +25% event gift or burst charge payout/level; 2 levels |
| cabrito | Cabrito Power | Refill 20 double-earnings regular taps; 60 shared charges |
| cafecito | Jake Wants Meat | +2 seconds/day/level; 2 levels |
| empire | CEO | +1 base-tap equivalent/sec/level during work; 3 levels |
| facetime | FaceTime Date | +8 base taps every tenth tap/level; 3 levels |
| flights | Volaris Red-Eye | Current ticket multiplier ×0.92/selection; 2 selections/chapter |
| jar | Passive Income Princess | +2% savings interest/level at day end; 3 levels, 6% cap |
| love | Nicky Mode | +10% per rapid combo step/level; 3 levels, +90% overall cap |
| playlist | Carín León on Repeat | +0.5 seconds every fifth tap/level; 4 levels, +2 seconds/day |
| tips | One Wish Willow | +5 base taps every seventh tap/level; 3 levels |
| team | Girls’ Night Boost | +2 seconds/day/level; 2 levels; replaces old passive multiplier and immediate gift |

Fixed time from cafecito and team is applied first, capped at +6 seconds. Music uses the remaining shared budget, up to +2 seconds. A workday lasts 10–16 seconds. Combo uses the existing 0.6-second window and six-step counter. Interest is paid before the new reward, so a new interest level first affects the next day. Discounts compound against the current goal multiplier, retaining the old 50% floor. Passport applies its additional 12% reduction. Base tap income remains $5 with chapter scaling 1 / 2 / 3.5; goals remain $2,100 / $5,300 / $11,000.

All work earnings and event gifts receive Matching Underwear's +15%; interest does not. Steal Josh's Clothes gives +50% on the first ten regular taps. Unlimited FaceTime adds six base taps every tenth tap. Brian Merge gives two base taps/sec during work. Goodbye Kiss grants one Gringo Influence level after each chapter reset following acquisition.

## Events

Each event has two free positive outcomes. Gifts below are base-tap equivalents; bursts are double-earnings regular-tap charges. Jake's Protection multiplies the selected amount by 1.25 or 1.5, with fractional charge counts rounded up. All burst sources share the 60-charge cap; choosing burst at capacity adds zero charges, while the cash alternative remains available. Gifts also receive the earnings relic multiplier.

| ID | Name | First choice | Second choice |
| --- | --- | --- | --- |
| call | Josh Is Calling... Again | Answer: gift 12 | Decline: burst 20 |
| cancelled | Jake's Betrayal | Laugh: gift 8 | Attention: burst 15 |
| dinner | One More Episode | Sleep: gift 8 | Watch: burst 15 |
| gift | The Language Barrier | Help: gift 10 | Double down: burst 16 |
| rain | The Domino Incident | Carefully: gift 8 | Dramatic play: burst 18 |
| repair | Fede's Shopping List | Bring everything: burst 25 | Refuse: gift 6 |
| sale | Customs Has Questions | Explain: gift 8 | Call Fede: burst 16 |
| viral | Un Chico Serio | Serious: gift 12 | Truth: burst 20 |

## Measured balance and concerns

Seed 12345, selecting the first available preferred ability in order facetime/tips/love/appointment/empire/cafecito/flights, taking burst event alternatives and the first relic offer, completing chapters automatically at the settled milestone (winning-day choices skipped):

| Taps/sec | Denver / Italy / Future days | Active work |
| --- | --- | --- |
| 2 | 7 / 8 / 8 | 230 s |
| 3 | 6 / 6 / 7 | 190 s |
| 4 | 5 / 5 / 6 | 160 s |

These accelerated simulations use the real rules; they do not measure human 10–15 minute session pacing. Later chapters at faster tapping rates fall below provisional 7–9 / 9–12 day targets. Milestone rewards plus permanent relics produce substantial scaling despite lower passive income and interest. Goals have deliberately not been retuned. The shared time cap makes some time builds mutually redundant; exclusion avoids offering fully ineffective additional time levels. Cabrito level labels count acquisitions, while its effect remains a fixed refill. Human testing and additional seeds are needed before locking balance.

Automatic milestone validation retains the same goals and effects. The changed seeded results reflect the three-day event cadence and skipped winning-day choices changing subsequent RNG consumption; they are not a balance retune. Human playtime remains unmeasured.

The overview/start button is removed from ordinary and chapter-start flow. A 0.4-second input-safe transition displays the existing heart before the workday clock starts. This delay is not counted as tapping time or workdays.
