Design a complete production-quality mobile application UI for a smart public bus tracking platform called “SmartCrowd Transit”.

PRODUCT CONTEXT
This is a low-infrastructure real-time bus tracking system for tier-2/tier-3 cities and public transport networks such as TMT/BEST.

The core problem:
Many buses do not have dedicated GPS hardware. The official timetable only shows scheduled times, not where the bus actually is.

Our solution:
Passenger smartphones act as temporary location sensors. The system does NOT blindly trust every phone location. It verifies passenger movement using:
- route adherence
- speed consistency
- direction/heading
- movement continuity
- stop/dwell behavior
- GPS accuracy
- agreement with other passengers
- temporal and spatial clustering

A backend “RideTrust” verification engine filters unreliable signals and combines trusted signals to estimate a virtual real-time bus position.

IMPORTANT PRODUCT PRINCIPLE:
Never present uncertain information as exact.

Use:
“Estimated bus position”
“High confidence”
“Medium confidence”
“Limited live data”
“Possible service disruption”

Do NOT use:
“Exact bus location”
“8 seats available”
“Bus definitely broken down” unless confirmed.

The app should feel like a real public transport product, not an AI demo.

DESIGN STYLE
Create a professional, human-designed transportation app.

Use:
- light background: #F8FAFC
- dark navy text: #0F172A
- primary blue: #2563EB
- success green: #16A34A
- warning amber: #D97706
- danger red: #DC2626
- secondary grey: #64748B
- white surfaces
- subtle borders
- very subtle shadows
- 8px spacing system
- 8–12px corner radius
- Inter or Roboto typography

DO NOT use:
- neon colors
- purple/pink gradients
- glassmorphism
- cyberpunk styling
- excessive rounded pills
- giant headings
- 3D illustrations
- random AI-generated illustrations
- decorative blobs
- excessive cards
- chatbot interface
- gamification
- fake statistics
- unnecessary animations

The UI must look suitable for an actual government/public transport mobility application.

APP NAVIGATION

Bottom navigation:
1. Home
2. Live
3. Trips
4. Alerts
5. Profile

Keep navigation simple and consistent.

PASSENGER USER FLOW

Open App
→ Allow Location
→ Search destination / bus / stop
→ Select route
→ View estimated live bus position
→ View ETA and upcoming stops
→ Set “Notify Me”
→ Receive arrival alert
→ Optionally confirm boarding
→ Optionally share location while travelling
→ Automatically stop sharing when the ride ends.

IMPORTANT:
“I boarded this bus” is only a user claim.
The backend verifies the ride using movement and route signals.

Do not expose the RideTrust algorithm directly to normal passengers.

==================================================
SCREEN 1 — ONBOARDING
==================================================

Create a clean onboarding screen.

Title:
“Track your bus in real time”

Subtitle:
“See estimated bus locations and arrival times using verified passenger signals.”

Primary button:
“Get Started”

Secondary:
“Skip”

Show a simple minimal bus/map icon only if needed.

Do not use a large illustration.

==================================================
SCREEN 2 — LOCATION PERMISSION
==================================================

Title:
“Allow location access”

Description:
“Location helps us estimate bus movement and arrival times. Your location is used only with your permission.”

Buttons:
“Allow Location”
“Not Now”

Add a small privacy note:
“You can stop location sharing anytime.”

==================================================
SCREEN 3 — HOME
==================================================

Main header:
“Where are you going?”

Search field:
“Search bus, stop or destination”

Below search:

Section:
“Nearby”

Example:
Thane Station West
2 buses nearby

Section:
“Saved”

Example:
Home
College

Section:
“Popular Routes”

Show a few realistic route examples:
TMT 1
TMT 2
TMT 50
BEST 251

Do not imply these are live unless live data exists.

Each bus result should clearly display:
Route number
Destination
Live / Scheduled / Limited Data status

Example:

TMT 50
Thane Station West → Manpada
LIVE
ETA 7 min

Another:
BEST 251
Vesava-Yari Road → Andheri
LIMITED DATA
Scheduled 10:25

Use clear status labels.

==================================================
SCREEN 4 — BUS SEARCH RESULTS
==================================================

Title:
“Buses to Manpada”

Search/filter area.

Each result:

TMT 50
Thane Station West → Manpada

Estimated arrival:
7 min

Status:
LIVE

Next stop:
Majiwada

Confidence:
High confidence

Another:

TMT 50
Thane Station West → Manpada

Scheduled:
10:25 AM

Status:
SCHEDULED

Do not display fake real-time information.

==================================================
SCREEN 5 — LIVE BUS MAP
==================================================

This is the most important passenger screen.

Create a realistic light map interface.

Display:
- selected bus route
- route line
- bus icon
- selected passenger stop
- upcoming stops
- current user location
- destination

DO NOT show individual passenger dots.

Instead, only show the estimated bus position.

Bus marker:
“TMT 50”

Under marker:
“Estimated position”

At the bottom create a compact information panel:

TMT 50
Thane Station West → Manpada

Estimated arrival
7 min

Next stop
Majiwada

Data quality
High confidence

Small text:
“Based on multiple verified passenger signals”

Buttons:
“Notify Me”
“View Route”

Add a small “last updated” timestamp.

Example:
“Updated 12 sec ago”

==================================================
SCREEN 6 — BUS DETAILS
==================================================

Title:
“TMT 50”

Show:
Thane Station West → Manpada

Status:
LIVE

Information:

Estimated arrival
7 min

Current area
Majiwada

Next stops:
Majiwada
Cadbury Junction
Manpada

Route progress:
●──────────────○
Current → Destination

Data quality:
High confidence

Explanation:
“Estimated from multiple verified passenger signals.”

Buttons:
“Notify Me”
“Share Location”

Keep this screen clean.

==================================================
SCREEN 7 — DESTINATION TRACKING
==================================================

Allow user to choose a destination.

Title:
“Track my destination”

Destination:
Manpada

Show:
Bus route
Current progress
Upcoming stops
Estimated arrival

Notification option:
“Notify me before my stop”

Options:
5 min before
At my stop

When the user is approaching destination:

“Your stop is next”

Then:

“Get ready — Manpada is approaching.”

The system should automatically reduce location sampling when the user is far from destination and increase update frequency near the destination.

Do not explain this technical logic in the UI.

==================================================
SCREEN 8 — BOARDING / LOCATION SHARING
==================================================

After selecting a bus:

Question:
“Did you board this bus?”

Buttons:
“Start Sharing”
“Not Now”

Supporting text:
“Your location helps improve the bus estimate for everyone.”

Privacy note:
“Sharing stops automatically when your ride ends.”

Show a small battery/privacy icon.

IMPORTANT:
Do not imply that pressing “Start Sharing” automatically proves the passenger is on the bus.

==================================================
SCREEN 9 — RIDE VERIFICATION STATE
==================================================

Create a subtle state for a newly started ride.

Header:
“Checking your ride”

Text:
“We’re verifying your movement with the selected bus route.”

Status:
“Verifying”

Then a verified state:

“Ride verified”

Small text:
“Your movement matches the route.”

This screen should feel like a normal system status, not a technical dashboard.

Do not show:
ML score
algorithm percentages
GPS coordinates
other passengers’ locations.

==================================================
SCREEN 10 — TRIPS
==================================================

Title:
“My Trips”

Show recent trips:

Today
TMT 50
Thane Station → Manpada
Completed

Yesterday
BEST 251
Andheri → Vesava
Completed

Allow:
View trip
Save route
Repeat journey

Keep it simple.

==================================================
SCREEN 11 — ALERTS
==================================================

Title:
“Alerts”

Example:

🚌 Bus approaching
TMT 50 is approximately 5 minutes away.

⚠️ ETA changed
TMT 50 arrival changed from 6 min to 10 min.

⚠️ Possible service disruption
A bus has stopped unexpectedly. Operator confirmation pending.

🔴 Confirmed service disruption
TMT 50 breakdown confirmed by operator.

Do not let passenger reports automatically appear as confirmed breakdowns.

==================================================
SCREEN 12 — BUS BREAKDOWN / INCIDENT FLOW
==================================================

This is an important feature.

Passengers should NOT have a direct button that instantly declares:
“Bus Broken Down.”

Instead, create:

“Report a Problem”

Options:
- Bus stopped unexpectedly
- Route blocked
- Accident / emergency
- Other

After passenger submits:

“Report received”

“Your report has been sent to the operator for verification.”

Status:
“Awaiting confirmation”

Driver/conductor receives the incident.

If driver confirms:

“Breakdown confirmed”

Then passengers see:

🔴 Service disruption

“TMT 50 has been reported as broken down.”

Show:
Last known bus position
Time of last update
Affected stops
Alternative route if available

If the driver does not respond but multiple verified passenger devices remain stationary outside an expected stop for a prolonged period:

Show:

🟡 Possible service disruption

“The bus appears to have stopped unexpectedly. Confirmation is pending.”

This is critical:
NEVER automatically display “Bus Breakdown” from a single passenger report.

==================================================
SCREEN 13 — DRIVER / CONDUCTOR MODE
==================================================

Create a separate driver/conductor interface.

This mode is accessed through a Driver login.

Header:
“Driver Mode”

Show assigned trip:

TMT 50
Thane Station West → Manpada

Trip status:
ACTIVE

Current status:
“Running”

Large simple controls:

“Report Breakdown”
“Temporary Stop”
“Route Blocked”
“Resume Service”

Also:

“End Trip”

When driver presses Report Breakdown:

Confirmation screen:

“Confirm bus breakdown?”

Buttons:
“Confirm Breakdown”
“Cancel”

After confirmation:

“Breakdown reported successfully.”

Passenger-facing status changes to:
“Confirmed service disruption”

Driver location acts as a trusted anchor when passenger signal strength is low.

Do not make driver mode visually complex.

==================================================
SCREEN 14 — DRIVER ROUTE DEVIATION
==================================================

If the bus unexpectedly leaves the planned route:

Driver sees:

⚠️ Route deviation detected

“Your current path differs from the planned route.”

Options:
“Confirm Detour”
“Return to Route”

If confirmed:

“Detour active”

Passengers then see:

⚠️ Route changed

“This bus is currently following a temporary route.”

Show:
Updated route
Skipped stops
New ETA

==================================================
SCREEN 15 — PASSENGER DETOUR ALERT
==================================================

If a bus skips a passenger’s stop:

Title:
“Route changed”

Example:

TMT 50
Temporary route detected

Your selected stop:
“Cadbury Junction”

Status:
“Stop may be skipped”

Alternative:
“Get down at Manpada”

Buttons:
“View Alternative”
“Keep Tracking”

Do not claim the route has changed from one GPS point alone.

The system should require persistent route divergence before showing a detour.

==================================================
SCREEN 16 — OCCUPANCY / CROWDING
==================================================

Show estimated crowding, NOT exact passenger count.

Example:

Crowding
MODERATE

Visual:
Low ─────●──── High

Text:
“Based on verified ride participation and passenger/operator reports.”

Possible states:

LOW
“Seats likely available”

MODERATE
“Some seats may be available”

HIGH
“Standing room likely”

VERY HIGH
“Crowded”

Do NOT display:
“8 seats available”
unless a verified operator/manual source provides that number.

Add optional passenger feedback:

“How crowded is the bus?”

Buttons:
“Seats available”
“Mostly occupied”
“Standing room only”

This feedback should contribute to the occupancy estimate, not directly become an exact passenger count.

==================================================
SCREEN 17 — LIVE DATA QUALITY
==================================================

Create a small expandable information panel.

Title:
“Live data quality”

High confidence:
“Multiple verified passenger signals are currently available.”

Medium confidence:
“Some verified signals are available.”

Limited data:
“Few live signals are available. ETA may change.”

Scheduled:
“No live signals are currently available. Showing scheduled information.”

This builds trust with users.

==================================================
SCREEN 18 — NO PASSENGERS / NO LIVE SIGNALS
==================================================

Important edge case.

If no passenger is currently sharing location:

Show:

“No live passenger signals”

Then:

“Live tracking is temporarily unavailable.”

Show:
Scheduled departure
Last known position
Last updated time

If driver/conductor location is available:

“Live tracking available through operator location.”

Otherwise:

“Showing scheduled information.”

NEVER fabricate a bus location.

==================================================
SCREEN 19 — LOW SIGNAL / NETWORK PROBLEM
==================================================

Create states for:

Poor GPS
No internet
Location permission denied
No contributors
Server unavailable

Example:

“Limited live data”

“We’re receiving fewer location signals right now.”

Buttons:
“Retry”
“View Schedule”

==================================================
SCREEN 20 — PROFILE
==================================================

Title:
“Profile”

Sections:

Account

Saved Stops
Saved Routes
Notifications
Location Permissions
Location Sharing
Privacy
Help & Support
About

Location Sharing:
“Only share location while travelling”

Toggle.

Privacy:
“Your individual location is not shown to other passengers.”

==================================================
SCREEN 21 — SETTINGS / PRIVACY
==================================================

Show:

Location access
Notifications
Ride sharing
Background location

Privacy explanation:

“We use aggregated and verified movement signals to estimate bus movement. Individual passenger locations are not shown on the map.”

Buttons:
“Manage Permissions”
“Stop Sharing”

==================================================
SCREEN 22 — BUS SEARCH WITH REAL PUBLIC TRANSPORT DATA
==================================================

Design the search system so it can support multiple operators.

Example:

TMT
TMT 50
Thane Station West → Manpada

BEST
BEST 251
Vesava-Yari Road → Andheri Station

The interface should support:
- operator
- route number
- origin
- destination
- stops
- timetable
- live status

Do not hard-code only one transport operator.

==================================================
SCREEN 23 — ROUTE / TIMETABLE
==================================================

Create a timetable page inspired by traditional public transport timetable documents but redesigned for mobile.

Header:
“TMT 50”

Route:
Thane Station West → Manpada

Tabs:
Live
Timetable
Stops

Timetable:

Morning
07:00
07:20
07:40
08:00
...

Afternoon
12:00
12:20
...

Evening
17:00
17:20
...

Clearly distinguish:
LIVE
SCHEDULED

Do not mix scheduled departure time with real-time ETA.

==================================================
SCREEN 24 — STOP DETAILS
==================================================

Example:

Majiwada

Upcoming buses:

TMT 50
LIVE
7 min

TMT 2
SCHEDULED
10:25 AM

BEST route if applicable

Allow:
“Notify Me”

==================================================
SYSTEM LOGIC TO REFLECT THROUGH UI STATES

The backend architecture is:

Passenger Phones
+
Optional Driver/Conductor Phone
↓
Location Preprocessing
↓
Map Matching
↓
RideTrust Verification
↓
Crowd Signal Fusion
↓
Virtual Bus Position
↓
ETA + Route Progress + Occupancy Estimate
↓
Passenger App

The UI should communicate the results of this system without exposing technical complexity.

==================================================
RIDETRUST LOGIC — DO NOT EXPOSE RAWLY TO USERS
==================================================

The system evaluates:

1. Route adherence
2. Speed consistency
3. Direction/heading
4. Movement continuity
5. Stop/dwell behavior
6. GPS accuracy
7. Peer agreement
8. Temporal/spatial consistency

Example:

A passenger waiting at a bus stop:
stationary → not considered a bus signal.

A passenger in a nearby car:
may follow the same road but have a different speed/stop pattern → down-weighted.

A passenger actually on the bus:
movement, route adherence and stop sequence align → higher trust.

Multiple verified passengers:
their trajectories cluster together → stronger bus estimate.

Do not show individual passenger tracks on the map.

==================================================
TRACKING MODES

The product should support four tracking states:

1. Operator Anchor
Driver/conductor smartphone provides trusted location.

2. Verified Crowd
Multiple verified passenger phones provide location signals.

3. Hybrid
Driver + passenger signals are combined.

4. Fallback
No live signals → last known position + scheduled timetable.

Reflect these states in the UI using simple status text.

==================================================
AUTOMATIC RIDE END

The passenger should not need to manually stop tracking every time.

After the system detects:
- destination reached
- user leaves bus movement pattern
- route ends
- prolonged separation from bus trajectory

show:

“Ride completed”

“Location sharing stopped.”

Allow manual:
“Stop Sharing Now”

==================================================
NOTIFICATION DESIGN

Create notification examples:

Bus approaching
“TMT 50 is approximately 5 minutes away.”

Bus arriving
“TMT 50 is approaching Majiwada.”

ETA changed
“Arrival estimate changed to 10 minutes.”

Route changed
“TMT 50 is following a temporary route.”

Possible disruption
“The bus appears to have stopped unexpectedly.”

Confirmed breakdown
“Bus breakdown confirmed by operator.”

Destination approaching
“Your stop is next.”

Do not create notification spam.

==================================================
COMPONENT SYSTEM

Create reusable Figma components:

Bus Card
Route Card
Stop Card
ETA Card
Status Badge
Confidence Indicator
Live Bus Marker
Bottom Navigation
Search Bar
Primary Button
Secondary Button
Notification Card
Incident Card
Timetable Row
Driver Status Card
Occupancy Indicator
Permission Card
Empty State
Error State
Loading State

Create variants for:
LIVE
SCHEDULED
LIMITED DATA
HIGH CONFIDENCE
MEDIUM CONFIDENCE
POSSIBLE DISRUPTION
CONFIRMED DISRUPTION

==================================================
MAP DESIGN

Use a realistic light map.

Keep roads visible but not visually overwhelming.

Bus route:
blue route line

Estimated bus:
blue bus marker

User:
small blue location dot

Destination:
simple destination marker

Do NOT show:
hundreds of passenger location dots
fake heatmaps
unnecessary map decorations.

==================================================
VISUAL HIERARCHY

Every screen must answer the user's main question quickly.

For the Live Bus screen:

1. Which bus?
2. Where is it estimated to be?
3. How long until it arrives?
4. How reliable is the information?
5. What happens next?

Do not bury ETA inside paragraphs.

==================================================
ACCESSIBILITY

Use:
- high contrast text
- minimum 14px body text
- clear button labels
- icons accompanied by text where necessary
- color + text together for status
- readable map labels
- touch targets at least 44px

Do not rely only on red/green color.

==================================================
PROTOTYPE FLOW

Create clickable prototype connections for:

Home
→ Search
→ Bus Results
→ Bus Details
→ Live Map
→ Notify Me

Home
→ Nearby Stop
→ Stop Details
→ Live Bus

Bus Details
→ Did You Board?
→ Start Sharing
→ Ride Verification
→ Ride Verified

Live Map
→ Destination Tracking
→ Destination Approaching

Alerts
→ Possible Disruption
→ Confirmed Breakdown

Profile
→ Location Sharing
→ Privacy Settings

Driver Login
→ Driver Dashboard
→ Report Breakdown
→ Confirmation
→ Passenger Alert

Driver Dashboard
→ Route Deviation
→ Confirm Detour
→ Updated Passenger Route

==================================================
IMPORTANT EDGE CASES TO DESIGN

Create visual states for:

1. No passengers on bus
2. Only driver location available
3. Multiple passenger signals available
4. One unreliable passenger signal
5. Passenger falsely claims boarding
6. Passenger waiting at stop
7. Passenger in nearby vehicle
8. Bus leaves planned route
9. Bus skips a stop
10. Bus stops unexpectedly
11. Driver confirms breakdown
12. Driver does not respond
13. Poor GPS accuracy
14. No network
15. Location permission denied
16. No live data
17. Destination reached
18. Ride automatically ended
19. High crowding
20. Low crowding

==================================================
FINAL DESIGN REQUIREMENT

Generate a complete, consistent mobile UI system, not isolated screens.

The app should look like a real public transport application that could be shown to:
- passengers
- transport operators
- government/public transport authorities
- hackathon judges

The strongest product idea must be visually clear:

“Passenger smartphones become trusted temporary sensors for buses without GPS hardware.”

The important differentiator is NOT simply GPS tracking.

The differentiator is:

NO DEDICATED BUS GPS
+
PASSENGER SMARTPHONES
+
RIDETRUST VERIFICATION
+
CROWD SIGNAL FUSION
+
VIRTUAL BUS POSITION
+
ETA
+
OPERATOR FALLBACK
+
VERIFIED INCIDENT DETECTION

Keep the final UI minimal, professional, practical and technically credible.
Do not create fake precision or unsupported information.