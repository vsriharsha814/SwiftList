# To-Do App Revamp — Plan & Work Breakdown

## Overview
Revamp the existing Flutter to-do app into **"Zen Studio"** with hierarchical tasks, dual-mode timers with foreground persistence, RFC 5545 recurrence, escalating reminders, and a three-pillar UI (List, Focus Mode, Pulse Dashboard).

---

## 1. Feature Breakdown (WBS)

### A. Hierarchical Work Breakdown Structure
| Step | Description |
|------|-------------|
| A1 | **Data model**: Every task is a *Node* with `parent_id` (null = root). Add `weight` (int) per task for weighted progress. |
| A2 | **Weighted progress**: Compute parent progress = sum(weight × completed) / sum(weight) for direct children. Expose in DB/DAO. |
| A3 | **Drill-down UI**: Main list shows one level (e.g. roots or children of selected parent). Tap parent → "zoom in" to its children; show back/up to go to parent level. |
| A4 | **Breadcrumb**: Display parent chain as tag (e.g. `[Project X]`) on each card. |

### B. Option Timer System
| Step | Description |
|------|-------------|
| B1 | **Dual mode**: Each task can start a **Countdown** (Pomodoro, configurable duration) or **Stopwatch** (count-up). Store mode + duration in UI state / prefs. |
| B2 | **Foreground persistence (Android)**: On timer start, start a **Foreground Service**; show persistent notification with live countdown/stopwatch and **Pause** / **Complete** actions. |
| B3 | **Temporal logging**: On Pause/Complete, create a **Time Entry** (time_logs: task_id, start_time, end_time, duration_seconds). Feed into Pulse dashboard. |

### C. RFC 5545 Recurrence Engine
| Step | Description |
|------|-------------|
| C1 | **RRULE storage**: Store `rrule` (TEXT) on task. Use **rrule** package to parse and compute next instances. |
| C2 | **Ghost vs real**: Do not create thousands of rows. Show *current instance* for today/now; on "Done", log completion and compute *next* instance from RRULE (and optionally store next_due or derive on read). |
| C3 | **EXDATE**: Support "Delete this occurrence only". Store exdates (e.g. in a table or JSON column); when resolving current instance, skip dates in EXDATE. |

### D. Deadline & Proactive Reminders
| Step | Description |
|------|-------------|
| D1 | **Escalating alerts**: Per deadline, schedule: **Gentle** (e.g. 1h before), **Standard** (15 min), **Critical** (at deadline). Store reminder state so we don’t re-schedule past ones. |
| D2 | **WorkManager**: Use WorkManager to re-schedule upcoming reminders after boot / app update so alarms survive reboots. |
| D3 | **Time-to-leave**: Optional later: geofence "Work" and remind earlier if user not at Work (placeholder in plan only). |

---

## 2. UI/UX — "The Zen Studio"

### Visual language
- **Palette**: Deep Charcoal `#121212`, Slate Gray `#2C2C2E`, one **Action Accent** (e.g. Electric Blue or Vivid Orange).
- **Typography**: Clean sans-serif (Inter or Roboto), **tabular figures** for timer so digits don’t shift.

### Three-pillar layout
1. **Infinite List (Main view)**  
   - Card: rounded rectangle; left: circular checkbox; center: title + breadcrumb tag; right: play icon + time estimate (e.g. 25:00).  
   - Long-press: multi-select to move between parents/projects.  
   - Pinch-to-zoom: zoom out = collapse subtasks; zoom in = expand hierarchy (optional enhancement).

2. **Focus Mode (Timer view)**  
   - Minimal: rest of app fades; center = large thin-stroke circular progress ring (empties for countdown).  
   - Below: "Next up" scroller of subtasks for current goal.

3. **Pulse (Dashboard)**  
   - **Heatmap**: grid of focus intensity (e.g. darker = more tracked time that day; 8+ hrs = darkest).  
   - **Focus Velocity**: line chart (Bezier) of productivity by time-of-day (e.g. 40% more at 10:00 than 16:00).  
   - **Milestone cards**: e.g. "50 tasks this week — top 5%."

---

## 3. Technical Implementation

### Database (Drift/SQL)
- **tasks**: `id`, `parent_id`, `title`, `rrule`, `deadline`, `weight`, `is_completed`, optional `project_name`/tag for breadcrumb.
- **time_logs**: `id`, `task_id`, `start_time`, `end_time`, `duration_seconds`.
- **exdates**: `id`, `task_id`, `exception_date` (for "this occurrence only" skip).
- **reminders**: Optional table for scheduled reminder IDs (or derive from deadline + offsets).

### Performance & polish
- **Skeleton loaders** on dashboard.
- **Implicit animations**: `AnimatedContainer`, `AnimatedList` for hierarchy and list changes.

### Dependencies to add
- **drift** + **drift_flutter** + **sqlite3_flutter_libs** (DB).
- **rrule** (RFC 5545).
- **workmanager** (re-schedule after reboot).
- **flutter_foreground_task** (Android foreground service for timer).
- **uuid** (IDs).
- **google_fonts** (Inter/Roboto), **fl_chart** or **syncfusion_flutter_charts** (dashboard charts; prefer lightweight option).

---

## 4. Execution Order (Phases)

| Phase | Content |
|-------|---------|
| **1** | Foundation: Drift schema, Zen Studio theme, app shell with bottom nav (List / Focus / Pulse). |
| **2** | Hierarchical WBS: CRUD for nodes, weights, drill-down list, progress computation. |
| **3** | Option Timer: countdown/stopwatch UI, foreground service, time_logs. |
| **4** | Recurrence: rrule parsing, current instance, EXDATE, "done → next instance". |
| **5** | Reminders: escalating alerts, WorkManager. |
| **6** | Pulse: heatmap, focus velocity chart, milestone cards, skeleton loaders. |

---

## 5. File Structure (Target)

```
lib/
├── main.dart
├── app.dart                    # MaterialApp + theme
├── core/
│   ├── theme/
│   │   ├── app_theme.dart      # Zen Studio colors & typography
│   │   └── app_colors.dart
│   └── constants.dart
├── data/
│   ├── database/
│   │   ├── app_database.dart   # Drift database
│   │   ├── tables.dart        # tasks, time_logs, exdates
│   │   └── daos/
│   ├── repositories/
│   │   ├── task_repository.dart
│   │   ├── time_log_repository.dart
│   │   └── recurrence_service.dart
│   └── services/
│       ├── timer_service.dart
│       ├── reminder_scheduler.dart
│       └── foreground_timer_service.dart  # Android
├── features/
│   ├── list/
│   │   ├── list_screen.dart
│   │   ├── task_card.dart
│   │   ├── task_node_tile.dart
│   │   └── drill_down_provider.dart
│   ├── focus/
│   │   ├── focus_screen.dart
│   │   ├── timer_ring.dart
│   │   └── next_up_list.dart
│   └── pulse/
│       ├── pulse_screen.dart
│       ├── heatmap_widget.dart
│       ├── focus_velocity_chart.dart
│       └── milestone_cards.dart
├── shared/
│   ├── widgets/
│   │   ├── skeleton_loader.dart
│   │   └── animated_list.dart
│   └── utils/
└── l10n/ (if needed later)
```

Execution starts with **Phase 1** (foundation), then proceeds in order through Phase 6.
