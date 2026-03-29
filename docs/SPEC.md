# Shift Worker Sleep

## Product Specification

## Document Status

- Document: `SPEC.md`
- Product: Shift Worker Sleep
- Product Type: Consumer mobile application
- Intended Stack Context: React Native with Expo, SQLite local storage
- Pricing Model: `$0.99` one-time purchase
- Primary Platforms: iOS and Android phones
- Scope of This Document: App overview, product vision, target audience, feature summary, monetization, and platform scope
- Out of Scope for This Document: Detailed requirements, non-functional requirements, test planning, UI specs, data schemas, and implementation architecture

## 1. Overview

### 1.1 Purpose

Shift Worker Sleep is a mobile app built for people whose work schedules do not follow a stable day-oriented routine. The product helps users plan when to sleep, when to wake, whether to nap, and how to prepare for sleep when their next shift may start early, end late, rotate across days, or occur overnight.

The app exists because most sleep products assume regular bedtimes and consistent wake times. That assumption fails for workers whose schedules change weekly, daily, or even within the same week. Shift Worker Sleep addresses that gap by treating the work schedule as the starting point for all core guidance.

This document defines the product at a high level. It explains what the app is, who it serves, the value it aims to deliver, which feature areas are included in scope, how the app is monetized, and which platforms are targeted in the initial release.

### 1.2 Product Summary

Shift Worker Sleep is a specialized sleep-planning and recovery-support app for adults with irregular schedules. Users enter upcoming shifts, view recommended sleep windows, set shift-aware alarms, use guided wind-down tools, log sleep, check nap recommendations, review circadian visualizations, switch to a low-stimulation dark room mode, and optionally use white noise while preparing for sleep.

The product is not a general wellness platform and not a medical diagnostic tool. It is a practical utility app for people who need better sleep decisions under real-world constraints such as rotating shifts, short turnarounds, night work, split sleep, overtime, and noisy daytime rest.

### 1.3 Product Category

The product sits at the intersection of:

- Sleep utility app
- Schedule-aware planning tool
- Alarm and routine support app
- Personal recovery assistant for irregular work

It is intentionally narrower than a full health app and more specialized than a generic alarm or bedtime reminder app.

### 1.4 Core Problem

Many existing sleep apps break down when a user does not sleep on a normal night schedule. Shift workers often experience:

- Frequent changes in shift start and end times
- Daytime sleep after overnight work
- Compressed recovery time between shifts
- Difficulty deciding whether to sleep immediately, stay awake, or take a short nap
- Cognitive fatigue that makes planning harder
- High friction when manually calculating alarms and wake buffers
- Difficulty interpreting sleep history when sleep happens in fragments

Generic sleep products often assume a normal bedtime, a stable wake time, and a predictable weekly rhythm. Those assumptions make the recommendations feel irrelevant or impossible to follow for workers in hospitals, warehouses, transportation, manufacturing, public safety, hospitality, retail, logistics, and other around-the-clock operations.

### 1.5 Core Solution

Shift Worker Sleep solves this by making the schedule the first-class input. Instead of asking the user to force life into an idealized rhythm, the app:

- Collects shift timing
- Calculates rest opportunities around that timing
- Suggests realistic sleep windows
- Recommends wake times and alarm timing
- Helps users prepare for sleep
- Supports strategic naps
- Shows the consequences of schedule changes over time

The product aims to reduce planning effort and decision fatigue. The user should not need to do mental math after an exhausting shift or before an early start.

### 1.6 Product Positioning

Shift Worker Sleep is positioned as a focused paid mobile utility for nonstandard sleepers. It should feel:

- More specialized than a generic alarm clock
- More actionable than a passive sleep tracker
- More practical than a meditation-first wellness app
- Less clinical than a medical treatment product

The app should be recognized as a tool that understands shift work rather than a lifestyle brand that happens to include sleep content.

### 1.7 App Promise

The product promise is simple:

- Enter your shifts
- See your next best sleep option
- Wake on time with less guesswork
- Recover more intentionally when schedules change

### 1.8 Product Thesis

If the app makes the next sleep decision clearer and faster for shift workers, it creates value immediately. If it requires too much setup, too much interpretation, or too much routine maintenance, the product fails regardless of how much information it contains.

### 1.9 Value in One Sentence

Shift Worker Sleep helps people with changing schedules decide when to sleep, when to wake, and when to nap by turning work shifts into practical sleep guidance.

## 2. Vision

### 2.1 Vision Statement

Help shift workers sleep when they can, wake when they need to, and recover with less uncertainty.

### 2.2 Long-Term Vision

The long-term vision is to become the most useful and trusted sleep-planning app for workers whose schedules do not match a standard day-night rhythm. The app should be the place users open when they need a clear answer to questions such as:

- When should I sleep before my next shift?
- How much time do I realistically have for a full sleep block?
- Should I take a nap right now or wait?
- When should I start winding down?
- What time should my alarm go off if I want enough prep and commute time?
- How disrupted has my rhythm become this week?

The app should turn complex sleep and schedule tradeoffs into direct, understandable decisions.

### 2.3 Product Ambition

The ambition is not to become the broadest sleep app. The ambition is to become the most relevant sleep app for users with irregular schedules. That narrower focus is strategic. It improves clarity, product quality, and trust.

### 2.4 Product Principles

#### 2.4.1 Schedule First

The schedule is the foundation of the product. Recommendations that ignore real work timing are not credible.

#### 2.4.2 Action Before Analysis

The app should answer what the user should do next before it explains supporting context.

#### 2.4.3 Practical Over Perfect

Recommendations must remain useful when ideal sleep is impossible. The product should help users make a better decision, not demand a perfect one.

#### 2.4.4 Calm by Default

Many interactions happen when the user is tired, overstimulated, or about to sleep. The app should reduce effort and visual noise.

#### 2.4.5 Specialized, Not Generic

Every major feature should reinforce the app's identity as a shift-worker sleep tool. Generic wellness filler weakens the product.

#### 2.4.6 Respect for Real Constraints

Users may work overtime, miss routines, sleep in fragments, or deviate from recommendations. The product should adapt without guilt or punitive language.

#### 2.4.7 Useful Offline

The most important planning flows must remain available without reliable network access.

#### 2.4.8 Privacy Respecting

Shift schedules, sleep timing, and routines are personal data. The product should minimize unnecessary collection and keep critical records on device.

### 2.5 Vision Outcomes

If the vision is realized, users should experience:

- Less uncertainty before and after shifts
- Faster sleep planning
- More confidence in wake timing
- Better use of naps
- Greater awareness of rhythm disruption
- Lower friction when trying to sleep during the day or after stressful work

### 2.6 Brand-Level Vision

The brand should come to mean one thing clearly: a sleep app that actually understands shift work.

### 2.7 What the Product Should Feel Like

The experience should feel:

- Direct
- Dependable
- Quiet
- Focused
- Supportive
- Low-friction

### 2.8 What the Product Should Not Feel Like

The experience should not feel:

- Generic
- Clinical in tone
- Gamified
- Judgmental
- Advertising-driven
- Subscription-shaped
- Buried under educational content

## 3. Product Goals

### 3.1 Primary Product Goals

- Allow users to enter and maintain shift schedules quickly
- Convert schedule data into useful sleep windows
- Help users set reliable wake times for upcoming shifts
- Support faster transitions into sleep with routines and low-stimulation tools
- Help users decide when a nap is useful and when it is not
- Make it easier to understand how irregular schedules affect rest patterns

### 3.2 User Goals Supported by the Product

The product is designed to help users:

- Sleep enough to function better across changing work periods
- Reduce mental effort involved in planning rest
- Avoid alarm mistakes caused by fatigue
- Make better choices during short recovery windows
- Prepare for sleep more consistently
- Understand recent sleep disruption without needing expert knowledge

### 3.3 Product Quality Goals

The app should deliver:

- Clarity in the next recommendation
- Simplicity in interaction flow
- Reliability in local data access
- Consistency across iOS and Android
- A polished feel disproportionate to its low price

### 3.4 Business Goals

- Deliver obvious value at a low one-time cost
- Build trust through a straightforward purchase model
- Differentiate from subscription-heavy wellness apps
- Sustain a focused feature set that can be maintained by a small team

### 3.5 Product Success Definition

At a high level, the product is successful if users repeatedly return to it before major sleep decisions and feel that it saves time, reduces uncertainty, and improves planning around work.

## 4. Non-Goals

### 4.1 Product Non-Goals

The product is not intended to be:

- A medical diagnostic app
- A treatment platform for sleep disorders
- A full health dashboard
- A social community
- A meditation content library
- A wearable-first biometric coaching product
- An employer scheduling system
- A subscription wellness service

### 4.2 Scope Protection

These non-goals exist to protect the product from feature sprawl. The more the app tries to become a general health platform, the less credible and useful it becomes for shift workers.

## 5. Target Audience

### 5.1 Primary Audience

The primary audience is adults with irregular work schedules who need sleep guidance that adapts to changing shifts. These users often experience:

- Early starts on some days and late finishes on others
- Overnight shifts or rotating nights
- Long or variable commutes
- Short turnaround time between shifts
- Sleep during daylight hours
- Inconsistent weekly schedules

### 5.2 Primary Audience Segments

Primary audience segments include:

- Nurses
- Physicians in training
- Hospital and clinic staff
- EMTs and paramedics
- Firefighters
- Police and corrections officers
- Security workers
- Warehouse workers
- Factory and manufacturing workers
- Logistics and distribution workers
- Drivers and transportation staff
- Airline and airport workers
- Hospitality workers
- Retail workers with variable schedules
- Customer support staff in 24-hour operations
- Utility and infrastructure workers

### 5.3 Secondary Audience

The app may also appeal to adjacent users with nonstandard sleep demands, including:

- Freelancers with irregular overnight work
- Students in clinical or field placements
- Caregivers with rotating overnight responsibilities
- Parents alternating nighttime care schedules
- Contractors with changing site start times

The product is not optimized around these users, but they may still benefit from the core planning model.

### 5.4 Excluded Audience

The product is not primarily aimed at:

- People with stable nine-to-five schedules who only want general sleep hygiene tips
- Users seeking a meditation-first experience
- Users expecting advanced wearable-driven biometrics from day one
- Users who need clinician-supervised treatment workflows

### 5.5 Common User Characteristics

The intended users often share several characteristics:

- They open the app while tired
- They have low tolerance for setup friction
- They often make decisions under time pressure
- They may use the app in low light
- They may need one-handed or very short interactions
- They want direct recommendations instead of dashboards first

### 5.6 Core User Needs

The core needs behind the product are:

- Fast schedule entry
- Clear next sleep recommendation
- Reliable wake timing for work
- Help deciding whether to nap
- Better support for daytime sleep
- A quiet interface suitable for exhausted users
- Enough visibility into recent sleep to understand what is happening

### 5.7 User Constraints

The product must recognize that users may be:

- Sleep deprived
- Stressed after work
- In shared living situations
- Preparing for daytime sleep in noisy environments
- Working across changing days of the week
- Facing unpredictable overtime or last-minute schedule changes

### 5.8 Emotional Context

The emotional context matters. Users may feel:

- Drained
- Frustrated
- Behind on sleep
- Anxious about oversleeping
- Uncertain about what choice is best

The app should lower that emotional temperature rather than add pressure.

## 6. Personas

### 6.1 Persona A: Rotating Hospital Nurse

#### Profile

- Age Range: Late twenties to mid thirties
- Work Pattern: Mixed days, evenings, and nights
- Environment: High responsibility, high stress, variable weekly shifts

#### Problems

- Cannot maintain a stable bedtime
- Needs to recover between closely spaced shifts
- Often decides sleep timing while exhausted
- Struggles with shift transitions

#### Needs

- Easy batch shift entry
- Next best sleep recommendation
- Smart alarm timing tied to commute and prep
- Low-light usability during early hours

#### Success

The product works for this user if it helps them plan sleep in under a minute and reduces the need to manually calculate wake times.

### 6.2 Persona B: Fixed-Night Warehouse Worker

#### Profile

- Age Range: Late twenties to forties
- Work Pattern: Consistent nights with periodic overtime
- Environment: Physically demanding work, daytime sleep at home

#### Problems

- Daylight and noise interfere with sleep onset
- Days off can disrupt routine
- Sleep may break into fragments

#### Needs

- Stable daytime sleep windows
- Dark room mode and white noise support
- Simple recent-history view
- Wake timing that accounts for pre-shift routine

#### Success

The app succeeds if this user can maintain a more repeatable sleep window and quickly set reliable alarms after each shift.

### 6.3 Persona C: Firefighter on Extended Shifts

#### Profile

- Age Range: Thirties to forties
- Work Pattern: Long shifts with interrupted rest and recovery periods
- Environment: High unpredictability, disrupted overnight sleep

#### Problems

- Sleep is interrupted during duty
- Recovery time varies after each shift
- Nap decisions are difficult when fatigue is high

#### Needs

- Clear post-shift recovery suggestions
- Nap duration guidance
- Simple answers after fragmented sleep
- Minimal interaction burden

#### Success

The app is useful if it gives quick, credible guidance after a disrupted shift without requiring detailed input.

### 6.4 Persona D: Retail Worker With Weekly Schedule Changes

#### Profile

- Age Range: Early twenties to early thirties
- Work Pattern: Weekly schedules with openings, closings, and split availability
- Environment: Schedule varies based on staffing and promotions

#### Problems

- Hard to anticipate sleep across inconsistent workdays
- Early opens and late closes create abrupt changes
- Limited willingness to configure complex tools

#### Needs

- Fast weekly schedule entry
- Immediate sleep recommendations
- Alarm support for uneven start times
- Flexible guidance instead of rigid routines

#### Success

The product succeeds if the user can input next week quickly and see where sleep will be constrained before it becomes a problem.

### 6.5 Persona E: EMT With Irregular Overtime

#### Profile

- Age Range: Mid twenties to forties
- Work Pattern: Scheduled shifts plus occasional extension
- Environment: Operational stress, unpredictable end times

#### Problems

- Recommendations can become stale when shifts extend
- Rest opportunities may shrink suddenly
- Needs quick replanning after overtime

#### Needs

- Easy shift edits
- Updated sleep windows after changes
- Nap guidance during limited recovery time
- Dependable wake timing for next duty cycle

#### Success

The app provides value if it remains useful when real life deviates from the original plan.

## 7. Use Context

### 7.1 Typical Moments of Use

Users will most often open the app:

- After receiving a new schedule
- After editing a shift
- Before going to sleep
- After completing a shift
- Before setting an alarm for the next shift
- When deciding whether to nap
- While reviewing how the week has affected sleep

### 7.2 Environmental Conditions

Usage may happen:

- In bed
- In a dark room
- On a couch after a long shift
- On a noisy commute
- During a break
- In early morning or pre-dawn hours
- In daylight while preparing to sleep

### 7.3 Interaction Constraints

The app should assume:

- Low patience for long flows
- Reduced concentration
- Limited tolerance for bright screens
- Need for quick reading
- Need for simple, high-confidence recommendations

### 7.4 Why Context Matters

A product designed for shift workers cannot behave like a daytime productivity app. The moment of use is often defined by fatigue, urgency, or overstimulation. The interface and features must reflect that reality.

## 8. App Overview

### 8.1 Core Concept

Shift Worker Sleep is a schedule-driven sleep planning app. The central input is work timing. The central outputs are sleep windows, wake timing, nap guidance, and supporting tools that make it easier to follow through.

### 8.2 The Core Product Loop

The high-level product loop is:

1. The user enters or updates upcoming shifts.
2. The app identifies available rest opportunities.
3. The app recommends the best practical sleep window.
4. The user sets an alarm and optional wind-down support.
5. The user logs or confirms actual sleep.
6. The app uses recent sleep and upcoming shifts to support the next decision.

### 8.3 The Core Question the App Answers

Every important screen should support one of these questions:

- What is my next best sleep window?
- When should I wake up?
- Should I nap?
- How should I prepare for sleep now?
- How has my schedule affected my rest this week?

### 8.4 Main Product Inputs

The app primarily depends on:

- Shift start times
- Shift end times
- Optional user sleep goals
- Actual sleep logs
- Routine preferences

### 8.5 Main Product Outputs

The app primarily produces:

- Recommended sleep windows
- Alarm recommendations
- Wind-down timing
- Nap guidance
- Sleep history views
- Circadian and schedule visualizations

### 8.6 Product Characteristics

The app should be:

- Mobile-first
- On-device centered
- Fast to understand
- Useful with minimal configuration
- Consistent across platforms

### 8.7 What Makes the Product Distinct

The product is distinct because its recommendations are anchored in work schedule reality. It does not assume the user can simply "sleep earlier" or follow the same bedtime each day.

## 9. Feature Summary

### 9.1 Feature Scope Overview

The initial product includes the following major feature areas:

- Shift schedule input
- Optimal sleep windows
- Smart alarm
- Wind-down routines
- Sleep tracking
- Nap optimizer
- Circadian visualization
- Dark room mode
- White noise

Each of these features exists to support the main job of the app: helping shift workers make better rest decisions.

### 9.2 Shift Schedule Input

#### Summary

Users can create and maintain a schedule of upcoming shifts so the app can generate context-aware recommendations.

#### Why It Matters

Without shift data, the rest of the app becomes generic. This is the foundation of the product.

#### Core Outcomes

- Users can enter upcoming work periods
- Users can review and edit their plan
- The app can reason about next available sleep windows

#### Product Intent

Schedule entry must feel lightweight. Users should not feel as if they are doing administrative work.

### 9.3 Optimal Sleep Windows

#### Summary

The app recommends the best practical times to sleep based on upcoming shifts and available time.

#### Why It Matters

This is the core differentiator. It translates an irregular schedule into an actionable sleep plan.

#### Core Outcomes

- The user sees the next recommended sleep block
- The user can understand when to sleep before a shift
- The user can see a backup option if ideal sleep is not possible

#### Product Intent

Recommendations should prioritize usefulness over theoretical perfection.

### 9.4 Smart Alarm

#### Summary

The app helps users wake at the right time for the next shift by recommending alarm timing tied to the planned sleep window.

#### Why It Matters

Fatigue makes it easy to miscalculate wake times. Alarm support reduces risk and friction.

#### Core Outcomes

- The user gets a recommended wake time
- The app accounts for preparation and commute buffers where relevant
- Alarm setup becomes a natural extension of planning sleep

#### Product Intent

The smart alarm should feel like the result of planning, not a disconnected utility.

### 9.5 Wind-Down Routines

#### Summary

The app provides short, practical routines that help users transition from wakefulness into sleep preparation.

#### Why It Matters

Shift workers may need to sleep soon after work or at unusual hours. A small amount of routine support can reduce friction and overstimulation.

#### Core Outcomes

- Users can start a simple pre-sleep flow
- The app can prompt useful wind-down steps
- The experience can connect into dark room mode and white noise

#### Product Intent

Routines should be brief, supportive, and optional, not a second job.

### 9.6 Sleep Tracking

#### Summary

Users can log planned or actual sleep sessions so the app reflects what happened instead of only what was intended.

#### Why It Matters

Recommendations are more useful when the app can compare plan versus reality across a changing schedule.

#### Core Outcomes

- Users can record sleep sessions
- Daytime and nighttime sleep can both be represented
- Recent rest patterns become visible

#### Product Intent

Tracking should support planning rather than become a high-maintenance quantified-self system.

### 9.7 Nap Optimizer

#### Summary

The app recommends whether a nap is helpful and suggests timing and duration when appropriate.

#### Why It Matters

Naps are often important for shift workers, but poorly timed naps can interfere with the next main sleep opportunity.

#### Core Outcomes

- The user sees whether napping is advisable
- The app suggests an appropriate nap duration
- The user can make a fast decision without overthinking tradeoffs

#### Product Intent

The nap feature must deliver direct guidance in moments of fatigue.

### 9.8 Circadian Visualization

#### Summary

The app visualizes how recent and upcoming shifts relate to sleep timing and rhythm disruption.

#### Why It Matters

Users often know they feel off but cannot quickly see why. Visualization provides context that supports future decisions.

#### Core Outcomes

- Users can see shifts and sleep on a shared timeline
- Users can understand day-night inversion and drift
- The app can explain rhythm disruption without heavy scientific language

#### Product Intent

Visualizations should clarify patterns, not overwhelm users with data.

### 9.9 Dark Room Mode

#### Summary

The app includes a low-stimulation mode for use in dark environments or immediately before sleep.

#### Why It Matters

Many users will interact with the app when the lights are off or while trying to reduce stimulation before sleep.

#### Core Outcomes

- The interface becomes easier to tolerate in low light
- Key actions remain obvious with less visual noise
- The app feels compatible with sleep preparation

#### Product Intent

Dark room mode is functional, not decorative.

### 9.10 White Noise

#### Summary

The app offers white noise or similar masking audio as a supporting sleep-preparation feature.

#### Why It Matters

Shift workers often sleep during the day or in noisy environments. Audio masking can improve the transition into rest.

#### Core Outcomes

- Users can start simple masking audio
- White noise can be used during routines or pre-sleep setup
- The app better supports daytime or inconsistent sleeping environments

#### Product Intent

White noise is a supporting feature, not the product's main reason to exist.

### 9.11 Feature Coherence

The included features are intentionally connected. The app should not feel like a bundle of unrelated utilities. The value comes from the way these features support the same planning and recovery loop.

## 10. Feature Prioritization

### 10.1 Must-Have Features

The must-have product core is:

- Shift schedule input
- Optimal sleep windows
- Smart alarm
- Sleep tracking
- Nap optimizer

These capabilities define whether the app fulfills its main promise.

### 10.2 Should-Have Features

These features materially improve usefulness and identity:

- Wind-down routines
- Circadian visualization
- Dark room mode

### 10.3 Nice-to-Have Within Initial Identity

This feature strengthens the experience but is secondary to the planning engine:

- White noise

### 10.4 Prioritization Rationale

If tradeoffs are required, the product should protect the schedule-to-sleep planning loop first. Any feature that does not directly improve sleep timing decisions or follow-through should receive lower implementation priority.

## 11. User Value Proposition

### 11.1 Primary Value Proposition

Shift Worker Sleep helps users make better sleep decisions around irregular work schedules by translating upcoming shifts into practical recommendations.

### 11.2 Supporting Value Propositions

- It saves mental effort
- It reduces planning mistakes caused by fatigue
- It makes nap decisions easier
- It supports daytime sleep conditions
- It provides specialized value missing from generic bedtime apps

### 11.3 Value at Purchase

At `$0.99`, the value proposition should feel immediate and easy to understand:

- Pay once
- Enter your schedule
- Get useful sleep guidance
- Use practical tools that fit shift work

## 12. Monetization

### 12.1 Monetization Model

Shift Worker Sleep is sold as a one-time paid app or one-time paid unlock priced at `$0.99`.

### 12.2 Rationale for One-Time Pricing

The monetization model is part of the product identity, not just a billing choice. One-time pricing supports several strategic aims:

- It keeps the value proposition simple
- It lowers purchase friction
- It aligns with a focused utility-app positioning
- It avoids recurring-billing skepticism
- It reduces pressure to add filler features to justify a subscription

### 12.3 User Promise Implied by Pricing

A one-time payment implies:

- The core feature set is included
- The app should be immediately useful
- There are no recurring charges to continue normal use
- The purchase is for a complete practical tool, not a trial layer

### 12.4 Monetization Principles

The product should follow these monetization principles:

- No ads inside the core experience
- No manipulative upsell interruptions
- No subscription requirement for the primary feature set
- No feature crippling that undermines the app's core value

### 12.5 Monetization Boundaries

Out of scope for the current product definition:

- Subscription plans
- In-app advertising
- Consumable purchases
- Paid sleep content packs
- Employer licensing
- Marketplace add-ons

### 12.6 Pricing Positioning

The low price positions the app as an accessible, practical purchase. The product must therefore emphasize clarity and usefulness from the first session. Users will expect fast value rather than long onboarding.

### 12.7 Risks Related to Monetization

The price lowers friction but also creates pressure to feel polished quickly. A low-cost app that feels confusing or incomplete will be judged harshly because the product promise is straightforward.

## 13. Platform Scope

### 13.1 Primary Platform Scope

The initial platform scope includes:

- iOS phones
- Android phones

The app is defined in the context of a React Native application using Expo for cross-platform development and SQLite for local structured storage.

### 13.2 Primary Device Assumption

The smartphone is the main device because:

- Users carry it during workdays and commutes
- Sleep decisions often happen away from a desk
- Alarm interactions are naturally mobile
- Quick check-in behavior fits the phone form factor

### 13.3 Interaction Pattern Assumption

The app is designed for short, repeated interactions rather than long sessions. It should support:

- Fast updates to shifts
- Quick review of the next recommendation
- Immediate alarm setup
- Brief sleep logging
- Rapid access to sleep-support tools

### 13.4 Excluded Platforms

The following are outside the initial platform scope:

- Tablet-optimized first-class layouts
- Desktop applications
- Web applications
- Smartwatch-first standalone experiences
- TV platforms

These may be considered later, but they are not part of the initial product definition.

### 13.5 Platform Behavior Expectations

The platform scope assumes:

- Local storage is available and reliable
- Notifications and alarms can be supported through mobile capabilities
- Core features should remain useful without constant network access
- Users may switch between daytime and nighttime use contexts frequently

### 13.6 Expo Context

Using Expo and React Native implies a shared mobile codebase with platform-aware adaptations where needed. From a product standpoint, this supports:

- Consistent feature availability across iOS and Android
- Faster iteration on mobile flows
- A mobile-first design system
- Product parity across major user journeys

### 13.7 SQLite Context

SQLite is the intended local storage layer for structured records such as:

- Shift schedules
- Sleep sessions
- Routine definitions
- Alarm planning metadata
- Visualization inputs

This supports an on-device-first product model where the app remains useful even with limited connectivity.

### 13.8 Offline-First Product Implications

The platform scope should support core functionality without requiring a live backend for routine use. That matters because users may need the app:

- During commutes with poor connectivity
- Inside facilities with weak signal
- At odd hours when they expect immediate response
- In contexts where waiting on sync would feel broken

### 13.9 Platform Limitations to Respect

Different mobile platforms may impose different behavior around alarms, notifications, background activity, and audio. The product scope should remain credible and avoid promising system behaviors that are not dependable across both platforms.

## 14. Product Boundaries

### 14.1 Scope Boundary

The product boundary is centered on sleep planning and sleep support for people with irregular schedules. Every major feature should contribute to one or more of the following:

- Choosing when to sleep
- Choosing when to wake
- Deciding whether to nap
- Preparing for sleep
- Understanding the impact of recent schedule changes

### 14.2 Features That Belong

A feature belongs in the product if it:

- Improves sleep timing decisions
- Reduces friction around sleep execution
- Helps explain schedule-related rest patterns
- Supports use under fatigue or in low-light conditions

### 14.3 Features That Do Not Belong

A feature likely does not belong if it:

- Exists only as generic wellness filler
- Requires a content business to make sense
- Pulls the app toward social engagement
- Depends on an ongoing subscription narrative
- Does not materially improve sleep decisions for irregular schedules

## 15. Usage Scenarios

### 15.1 Scenario: Preparing for a Night Shift

A nurse opens the app after reviewing tomorrow's overnight schedule. The app shows the best daytime sleep window, suggests a wind-down start time, and recommends an alarm that leaves time to get ready and commute. The user follows the plan without manually calculating each step.

### 15.2 Scenario: Recovering After an Interrupted Shift

A firefighter finishes a long duty period with broken sleep. The app reviews the next scheduled work block and recommends whether a short nap is appropriate. The user avoids taking a poorly timed nap that would make later sleep harder.

### 15.3 Scenario: Weekly Schedule Planning

A retail worker receives the next week's schedule and enters it into the app. The product immediately shows which days are tight, which shifts require earlier sleep, and where wake timing will be most demanding.

### 15.4 Scenario: Daytime Sleep at Home

A warehouse worker on nights gets home after sunrise. The user opens the app in dark room mode, starts white noise, confirms the planned wake time, and begins a short wind-down routine for daytime sleep.

### 15.5 Scenario: Fast Decision While Exhausted

A user only wants one answer: sleep now, nap now, or stay awake until the next main sleep window. The app surfaces that answer quickly without forcing the user to study charts or edit settings.

## 16. Product Tone

### 16.1 Tone Goals

The product tone should be:

- Calm
- Practical
- Direct
- Supportive
- Nonjudgmental

### 16.2 Language Guidance

The product should avoid:

- Excessive wellness language
- Guilt-inducing messages
- Overly technical sleep jargon
- Long educational explanations in primary flows

The product should prefer:

- Plain language
- Short labels
- Clear recommendations
- Confidence without overclaiming

### 16.3 Tone and Audience Fit

This tone is important because the users are often tired and time-constrained. The app should feel like a helpful tool, not a coach demanding compliance.

## 17. Competitive Differentiation

### 17.1 Differentiation Thesis

Shift Worker Sleep differentiates by treating irregular schedules as the main use case rather than an edge case.

### 17.2 Main Differentiators

- Shift schedule as the primary input
- Sleep windows tailored to work timing
- Nap guidance tied to upcoming duty periods
- Low-stimulation design for tired users
- One-time purchase instead of subscription pressure
- Focus on specialized utility rather than broad wellness sprawl

### 17.3 Why Specialization Matters

Many sleep apps implicitly assume nighttime sleep and stable routines. Shift Worker Sleep becomes valuable by rejecting that assumption and designing for the actual constraints of shift-based life.

## 18. Risks and Considerations

### 18.1 Risk: Overpromising Sleep Science

The app must avoid presenting heuristic guidance as medical certainty. Recommendations should be confident and useful without implying diagnosis or precise biological prediction.

### 18.2 Risk: Feature Creep

Sleep and wellness are broad categories. The product will lose coherence if it tries to become a generic health platform.

### 18.3 Risk: Schedule Entry Friction

If schedule setup is too slow or annoying, users will not stay engaged long enough to benefit from the planning tools.

### 18.4 Risk: Alarm Interpretation

Users may assume "smart alarm" means advanced sleep-stage detection. Product language should stay clear about what the feature actually does in this app.

### 18.5 Risk: Low Price, High Expectation

The one-time price lowers purchase friction but leaves little room for a confusing first impression. The app must feel immediately useful.

## 19. Assumptions

### 19.1 Product Assumptions

This specification assumes:

- Users will enter shift data if the return is immediate and obvious
- On-device functionality is sufficient for core value
- Simple planning beats broad feature coverage
- Visual explanations of rhythm disruption are useful if kept concise
- A low-cost one-time payment fits the target market better than a subscription

### 19.2 Audience Assumptions

This specification also assumes:

- Many users have inconsistent schedules week to week
- Many users do not want another subscription
- Many users are not interested in deep sleep science education
- Many users will use the app while tired and need quick answers

## 20. Out-of-Scope Future Directions

### 20.1 Not Included in Initial Product Scope

The following may be considered later but are not part of this product specification:

- Wearable integrations
- Cloud sync
- Employer schedule imports
- Family coordination features
- Advanced fatigue scoring
- AI chat coaching
- Clinician portals
- Tablet-first layout design
- Web companion apps

### 20.2 Why They Are Excluded

These areas are excluded to preserve focus. The product should first prove it can deliver a tight, trustworthy mobile experience for shift-based sleep planning.

## 21. Summary

### 21.1 Product Summary

Shift Worker Sleep is a paid mobile app for adults with irregular schedules who need practical help deciding when to sleep, when to wake, and when to nap. It uses shift schedule input as the foundation for sleep windows, alarm guidance, routines, tracking, circadian views, low-light usage, and white noise support.

### 21.2 Strategic Summary

The product is intentionally narrow. It is not trying to win by becoming a broad wellness platform. It is trying to win by being useful, specialized, and credible for shift workers whose sleep problems are shaped by changing schedules.

### 21.3 User Summary

The target user is tired, busy, and often making sleep decisions under pressure. The app should help that user quickly understand the next best action without heavy setup, jargon, or recurring billing.

### 21.4 Scope Summary

This specification covers:

- App overview
- Product vision
- Target audience
- Feature summary
- Monetization
- Platform scope

Detailed requirements, technical architecture, data modeling, UI specifications, and test artifacts belong in separate documents.
