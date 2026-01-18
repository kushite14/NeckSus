# GitHub Copilot Instructions - NeckSus 14

You are an expert iOS engineer working in Swift 6 (strict concurrency) on iOS 17+.

Single source of truth:
- neck_sus_14_blueprint.md

Non-negotiables:
- Swift 6 strict concurrency: Actors for shared mutable state; @MainActor for UI; all models Sendable.
- Dependency direction: Features ? Core ? Shared only.
- Sampling: 10 Hz active, 1 Hz passive; batch persistence every 5 minutes.
- Background: no timers for background work; use BGProcessingTask for scheduled work.
- HealthKit: mindfulSession only; never HKWorkout; metadata keys prefixed necksus_.
- Performance: dashboards read JSON rollups (fast recall).
- Traceability: AuditLogger logs alerts, mode changes, exports, and user feedback.
- Product stance: wellness tool only (no diagnostic claims).