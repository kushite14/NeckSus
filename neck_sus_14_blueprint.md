# NeckSus 14 Blueprint Anchor

This file is the single source of truth for architecture and implementation rules.
See the approved blueprint document in your project records.

Key non-negotiables:
- Swift 6 strict concurrency (actors/@MainActor/Sendable)
- 10 Hz active / 1 Hz passive sampling
- 5-minute batch persistence
- HealthKit mindfulSession only, metadata keys prefixed necksus_
- JSON rollups as dashboard backbone
- AuditLogger for traceability
- wellness tool (no diagnostic claims)