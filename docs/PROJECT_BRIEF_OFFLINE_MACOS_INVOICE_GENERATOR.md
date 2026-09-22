# Project Brief — Offline macOS Invoice Generator

## 1. Project Overview

Build a polished, native macOS invoice generator using **Swift and SwiftUI**.

The application should be **fully offline**, require **no account**, use **no backend**, and store all user data locally on the Mac. The product should feel like a proper macOS utility rather than a web app wrapped for desktop.

The core user flow is simple:

1. Open the app.
2. Create or select a client.
3. Add products/services to an invoice.
4. Configure invoice metadata, tax, discount, payment details, notes, and branding.
5. See a live invoice preview while editing.
6. Save the invoice locally.
7. Export the final invoice as PDF or PNG.
8. Track whether the invoice is unpaid, paid, overdue, or draft.

The application should prioritize:

- native macOS experience,
- fast local-first interaction,
- clean document design,
- privacy,
- reliability,
- high-quality PDF rendering,
- minimal dependencies,
- maintainable architecture.

---

## 2. Product Direction

The product is intended to sit somewhere between:

- a native macOS productivity utility,
- a lightweight invoicing tool for freelancers and small businesses,
- a local document generator.

The UI may take inspiration from invoice tools that use a **split editor + live preview** workflow, but the implementation should have its own visual identity.

The goal is **not** to clone another product pixel-for-pixel.

The target design language should feel closer to:

- native macOS,
- Things,
- Craft,
- Preview,
- Pages,
- Linear-level polish,

rather than a generic SaaS dashboard.

---

## 3. Core Principles

### 3.1 Offline First

The application must work completely without internet access.

There should be:

- no authentication,
- no remote API,
- no analytics dependency required for core functionality,
- no mandatory cloud sync,
- no remote database.

All core app functionality must remain available offline.

### 3.2 Native macOS

Prefer Apple frameworks whenever practical.

Preferred stack:

- Swift
- SwiftUI
- SwiftData
- PDFKit / Core Graphics
- StoreKit 2
- Swift Charts where appropriate
- AppKit interoperability only when SwiftUI is insufficient

Avoid unnecessary third-party dependencies.

### 3.3 User-Owned Data

All data should remain under the user's control.

The app should support:

- automatic local persistence,
- manual backup export,
- restore from backup,
- predictable storage behavior.

Future iCloud support may be considered, but must not be required for the initial version.

### 3.4 Document Quality Matters

The invoice itself is the main product output.

PDF quality, layout consistency, typography, spacing, pagination, and long-content handling should receive the same level of attention as the app UI.

---

## 4. Target Users

Primary users:

- freelancers,
- independent developers,
- designers,
- consultants,
- small businesses,
- small agencies,
- solo operators.

Initial localization focus may include Indonesian users, but the architecture should remain suitable for international users.

The app should support multiple currencies and configurable locale-sensitive formatting.

---

## 5. MVP Scope

The MVP should support the complete lifecycle of generating and managing invoices locally.

### 5.1 Dashboard

Dashboard should provide a lightweight summary of invoice activity.

Suggested metrics:

- total invoiced,
- total paid,
- total outstanding,
- overdue amount,
- invoice count,
- recent invoices.

Optional MVP chart:

- invoice totals by month,
- paid vs outstanding trend.

Do not overbuild analytics.

---

### 5.2 Invoice Management

Users must be able to:

- create invoice,
- edit invoice,
- duplicate invoice,
- delete invoice,
- search invoices,
- filter invoices,
- sort invoices,
- mark invoice as paid,
- mark invoice as unpaid,
- view invoice status.

Supported statuses:

- Draft
- Unpaid
- Paid
- Overdue
- Cancelled

Overdue status may be calculated automatically based on due date and payment state.

---

### 5.3 Invoice Editor

The invoice editor should use a split layout.

Recommended structure:

```text
┌─────────────┬──────────────────────────┬─────────────────────────────┐
│             │                          │                             │
│   Sidebar   │      Invoice Editor      │      Live Preview           │
│             │                          │                             │
│             │                          │                             │
└─────────────┴──────────────────────────┴─────────────────────────────┘
```

The left editor panel should be scrollable.

The preview should update immediately when invoice data changes.

Invoice fields:

- client,
- invoice number,
- issue date,
- due date,
- currency,
- products/services,
- quantity,
- price,
- optional unit,
- tax,
- discount,
- notes,
- payment details,
- optional custom fields.

---

### 5.4 Invoice Line Items

Each invoice item should support:

- description,
- quantity,
- unit price,
- computed amount.

Nice-to-have:

- optional SKU,
- optional unit,
- optional long description.

Users should be able to:

- add item,
- remove item,
- reorder items,
- pick an item from catalog,
- manually enter an item.

Calculations must use a reliable decimal representation suitable for money.

Avoid floating-point calculation errors.

---

## 6. Clients

The app should include a reusable client directory.

Client fields:

- display name,
- company name,
- email,
- phone,
- billing address,
- tax ID / optional identifier,
- notes.

Users should be able to:

- create,
- edit,
- delete,
- search,
- select clients while editing an invoice.

An invoice should preserve the client data relevant at the time it was issued.

Do not rely solely on live references to mutable client records if doing so would unexpectedly change historical invoice documents.

---

## 7. Catalog

The app should provide a reusable products/services catalog.

Catalog fields:

- name,
- description,
- default price,
- optional SKU,
- optional unit,
- default tax behavior.

Users should be able to quickly insert catalog items into invoices.

---

## 8. Business Profiles

Support business identity configuration.

Business profile fields:

- business name,
- logo,
- email,
- phone,
- address,
- tax ID,
- website,
- payment information,
- default currency,
- default invoice prefix,
- default payment terms,
- default invoice notes,
- accent color.

Architecture should support multiple business profiles, even if the free MVP initially exposes only one.

Each invoice should reference or snapshot the business profile used when the invoice was created.

---

## 9. Invoice Numbering

Provide configurable invoice numbering.

Example:

```text
INV-2026-001
INV-2026-002
INV-2026-003
```

Possible configuration:

- prefix,
- separator,
- year,
- padding,
- sequential number.

The system must prevent accidental duplicate invoice numbers.

Do not silently overwrite or reuse previously assigned invoice numbers.

---

## 10. Financial Calculations

The calculation engine should support:

- subtotal,
- percentage discount,
- fixed discount,
- percentage tax,
- optional multiple tax lines later,
- grand total.

Possible sequence:

```text
Subtotal
- Discount
+ Tax
= Total
```

The calculation layer should be separated from the UI and thoroughly testable.

Use `Decimal` or another money-safe representation.

---

## 11. Currency and Locale

The data model must support multiple currencies.

At minimum:

- IDR
- USD
- EUR
- SGD
- MYR

The architecture should not hard-code these currencies.

Use currency codes and locale-aware formatting.

For Indonesian users, ensure formatting like:

```text
Rp1.500.000
```

can be represented cleanly.

Currency symbol placement should follow selected formatting rules.

---

## 12. Indonesian-Friendly Features

The app should remain internationally usable but may offer additional convenience for Indonesian users.

Possible features:

- IDR formatting,
- PPN support,
- Indonesian invoice terminology,
- Indonesian and English invoice templates,
- Indonesian bank account details,
- QRIS image section,
- customizable payment instructions.

Do not make Indonesian assumptions mandatory in the core data model.

---

## 13. Invoice Templates

The MVP should support multiple visual invoice templates.

Suggested initial templates:

1. Minimal
2. Mono
3. Modern
4. Classic

Each template should consume the same invoice data model.

Do not duplicate business logic across templates.

Template-specific concerns should only include presentation.

Templates may support:

- accent color,
- logo positioning,
- typography differences,
- header layout,
- table styling,
- payment/footer layout.

---

## 14. Live Preview

A live invoice preview is a major product feature.

The preview should:

- closely represent final PDF output,
- update in real time,
- support zoom,
- support fit-to-page,
- show multiple pages when required.

Suggested controls:

- zoom out,
- zoom percentage,
- zoom in,
- fit page,
- template selector.

The preview architecture should ideally reuse the same document rendering primitives as final export.

Avoid maintaining completely separate layouts for preview and PDF if possible.

---

## 15. PDF Export

PDF export is a critical feature and should be treated as production-grade.

The exported document should:

- use actual document page sizes,
- preserve typography,
- preserve margins,
- correctly paginate,
- avoid clipping,
- render high-resolution logos,
- handle long client/business information,
- handle long invoice item descriptions,
- support large invoices.

Suggested page sizes:

- A4
- US Letter

A4 should be the default for Indonesian users.

Important edge cases:

- 1 item,
- 50+ items,
- multi-line descriptions,
- extremely long company name,
- large logo,
- no logo,
- discount and tax together,
- page break near subtotal,
- subtotal/total section overflowing to the next page,
- notes spanning several lines.

---

## 16. PNG Export

Users should optionally be able to export an invoice as a high-resolution PNG.

PNG output should use the same visual representation as the invoice template.

---

## 17. Local Persistence

Use SwiftData unless there is a clear technical reason not to.

Suggested entities:

```text
BusinessProfile
Client
CatalogItem
Invoice
InvoiceLineItem
PaymentRecord
AppSettings
```

Consider snapshot/value objects for invoice-specific client and business data.

The app should gracefully handle schema evolution.

Migration strategy must be considered from the beginning.

---

## 18. Data Safety and Backup

Because the product is offline-first, local data reliability is essential.

Provide automatic backup.

Possible strategy:

```text
Application Support/
└── AppName/
    ├── Data/
    └── Backups/
        ├── Daily/
        ├── Weekly/
        └── Monthly/
```

Recommended behavior:

- daily rolling backups,
- several recent daily versions,
- weekly snapshots,
- monthly snapshots.

Users should also be able to:

- Export Backup
- Restore Backup

Backup format can initially be an app-defined package or JSON/archive format.

Restoring should validate the backup before replacing current data.

---

## 19. App Navigation

Suggested sidebar:

```text
Dashboard
Invoices
Clients
Catalog

────────────

Business
Settings
```

Use native macOS sidebar behavior.

Prefer `NavigationSplitView` where practical.

Do not over-style native controls unnecessarily.

---

## 20. UI Design Direction

Visual direction:

- clean,
- calm,
- professional,
- compact but breathable,
- native macOS,
- restrained use of borders,
- restrained use of cards,
- minimal visual noise.

Avoid:

- excessive rounded cards,
- unnecessary gradients,
- web-dashboard-like visual density,
- generic Tailwind/SaaS aesthetic,
- oversized controls,
- decorative UI that does not improve usability.

Use native macOS materials and semantic system colors where appropriate.

Support:

- Light Mode
- Dark Mode

The invoice itself should remain print-oriented regardless of app appearance mode.

---

## 21. macOS Interaction Quality

Support native desktop interaction where practical.

Important behaviors:

- keyboard navigation,
- standard focus states,
- context menus,
- keyboard shortcuts,
- undo/redo,
- native menu commands,
- window resizing,
- native file picker,
- drag-and-drop logo,
- searchable lists.

Potential shortcuts:

```text
⌘N   New invoice
⌘S   Save
⌘P   Print
⌘E   Export PDF
⌘D   Duplicate invoice
⌘F   Search
⌘,   Settings
```

Actions should also appear in appropriate macOS menu items.

---

## 22. Saving Behavior

Prefer autosave for normal editing.

The user should not need to explicitly save every small change.

However, consider whether:

- draft creation,
- destructive navigation,
- unsaved new invoices,

need explicit UX.

If a visible Save button exists, its behavior should be meaningful rather than cosmetic.

---

## 23. Search and Filtering

Invoice list should support:

- full-text search,
- filter by status,
- filter by client,
- filter by date range,
- sort by date,
- sort by total,
- sort by invoice number.

Client and catalog lists should also be searchable.

---

## 24. Payments

For MVP, payment tracking can remain simple.

Invoice can contain:

- unpaid,
- paid,
- paid date,
- optional payment note.

The architecture may support a future `PaymentRecord` entity for:

- partial payments,
- multiple payments,
- payment methods.

Do not overbuild partial payments for initial MVP unless necessary.

---

## 25. Free / Pro Architecture

The codebase should support feature gating using StoreKit 2.

Potential free features:

- core invoice creation,
- local storage,
- basic templates,
- one business profile,
- PDF export,
- client management,
- basic catalog.

Potential Pro features:

- unlimited business profiles,
- premium templates,
- advanced appearance customization,
- PNG export,
- advanced backup options,
- custom fields,
- analytics,
- duplicate/preset workflows,
- additional branding controls.

Monetization should preferably support a **one-time purchase** rather than requiring a subscription.

Do not tightly couple core domain logic to StoreKit.

Feature entitlement should be isolated behind a service such as:

```swift
protocol EntitlementProviding
```

---

## 26. Suggested Architecture

Prefer a straightforward modular architecture.

Example:

```text
App/
├── AppEntry/
├── Domain/
│   ├── Models/
│   ├── Money/
│   ├── InvoiceCalculation/
│   └── Validation/
├── Data/
│   ├── Persistence/
│   ├── Repositories/
│   └── Backup/
├── Features/
│   ├── Dashboard/
│   ├── Invoices/
│   ├── Clients/
│   ├── Catalog/
│   ├── Business/
│   └── Settings/
├── Documents/
│   ├── Templates/
│   ├── Rendering/
│   ├── PDF/
│   └── ImageExport/
├── Services/
│   ├── Export/
│   ├── Backup/
│   ├── StoreKit/
│   └── FileSystem/
├── Shared/
│   ├── Components/
│   ├── Extensions/
│   └── Utilities/
└── Resources/
```

Avoid premature abstraction.

Use protocols primarily where they provide:

- testability,
- replaceability,
- clear architectural boundaries.

---

## 27. State Management

Prefer SwiftUI's native observation system.

Possible approach:

- `@Observable`
- environment-injected services,
- feature-specific view models only where useful.

Avoid introducing Redux/TCA-style global state unless there is a strong need.

The app should remain easy to reason about.

---

## 28. Document Rendering Architecture

Do not build document rendering directly inside the editor view.

Create reusable invoice presentation structures.

Conceptually:

```text
Invoice Data
    ↓
Invoice Document Model
    ↓
Template Renderer
    ↓
Preview / PDF / PNG
```

The same normalized document model should feed:

- live preview,
- PDF export,
- PNG export,
- print output.

This reduces visual mismatch between preview and exported output.

---

## 29. Reliability Requirements

The app should not crash or silently lose data when:

- quitting during edit,
- editing a large invoice,
- exporting large documents,
- loading a broken logo,
- restoring a backup,
- removing referenced catalog items,
- deleting a client used by old invoices.

Historical invoice integrity is more important than keeping all references live.

---

## 30. Testing Strategy

At minimum, provide unit tests for:

### Invoice calculations

Test:

- subtotal,
- tax,
- discounts,
- rounding,
- IDR,
- decimal currencies,
- zero quantity,
- zero price.

### Invoice numbering

Test:

- sequence increment,
- year changes,
- duplicate prevention.

### Backup

Test:

- export,
- validation,
- restore,
- corrupted backup handling.

### Invoice state

Test:

- overdue calculation,
- paid state,
- draft state.

### Rendering

Where feasible, provide snapshot or deterministic rendering tests for invoice templates.

---

## 31. Accessibility

Use native controls where possible.

Support:

- keyboard-only use,
- VoiceOver labels,
- sufficient contrast,
- semantic button labels,
- scalable interface where practical.

Do not communicate important state using color alone.

---

## 32. Performance Expectations

The app should:

- launch quickly,
- feel instant during invoice editing,
- render preview changes smoothly,
- avoid blocking the main thread during export,
- comfortably handle thousands of saved invoices,
- handle invoices with dozens or hundreds of line items.

Move expensive PDF/image generation off the main thread where appropriate.

---

## 33. Privacy

Core product positioning:

> Your invoices stay on your Mac.

No personal invoice information should leave the device unless the user explicitly exports or shares it.

If analytics or crash reporting are ever introduced later, they should not include invoice contents, client information, or business data.

---

## 34. Non-Goals for Initial MVP

Do **not** build the following initially:

- web app,
- Android app,
- iOS companion,
- online accounts,
- team collaboration,
- cloud backend,
- invoice email delivery service,
- payment gateway integration,
- recurring automatic billing,
- bookkeeping/accounting suite,
- inventory management,
- payroll,
- CRM,
- AI features.

These can be considered only after the core desktop product is polished.

---

## 35. Definition of Done for MVP

The MVP is considered usable when a user can:

1. Install and launch the app.
2. Configure their business profile.
3. Add a client.
4. Add products/services.
5. Create an invoice.
6. See the invoice update live while editing.
7. Apply discount and tax.
8. Select a template.
9. Save the invoice locally.
10. Close and reopen the app without losing data.
11. Export a professional PDF.
12. Print the invoice.
13. Mark the invoice as paid.
14. Search previously created invoices.
15. Export and restore a backup.

The resulting invoice should be good enough to send directly to a real client without manual cleanup.

---

## 36. Implementation Priority

Development should be staged.

### Phase 1 — Foundation

Implement:

- project structure,
- SwiftData models,
- application shell,
- navigation,
- business profile,
- clients,
- catalog,
- invoice domain model,
- invoice calculation engine.

### Phase 2 — Invoice Workflow

Implement:

- invoice list,
- invoice editor,
- line item editing,
- client selection,
- catalog selection,
- invoice numbering,
- statuses,
- autosave.

### Phase 3 — Document Engine

Implement:

- invoice document model,
- first template,
- live preview,
- pagination,
- A4 support,
- PDF export,
- print support.

Do not proceed to visual template expansion until the rendering engine is stable.

### Phase 4 — Product Polish

Implement:

- additional templates,
- zoom controls,
- drag reorder,
- keyboard shortcuts,
- menus,
- search and filtering,
- dark mode polish,
- empty states,
- validation,
- error handling.

### Phase 5 — Data Safety and Pro Features

Implement:

- local automatic backup,
- backup/restore UI,
- StoreKit 2,
- feature entitlements,
- Pro gates,
- PNG export,
- premium templates.

---

## 37. Critical Engineering Priorities

When trade-offs are necessary, prioritize in this order:

1. Data integrity
2. Financial calculation correctness
3. PDF/document correctness
4. Stable persistence
5. Native macOS UX
6. Performance
7. Visual polish
8. Additional features

Do not sacrifice document or data correctness for UI complexity.

---

## 38. Guidance for AI Coding Agent

When implementing this project:

- Inspect the existing codebase before making architectural decisions.
- Do not add external dependencies without a clear justification.
- Prefer Apple APIs.
- Keep business logic out of SwiftUI view bodies.
- Keep financial calculations deterministic and testable.
- Use `Decimal` for monetary values.
- Avoid giant SwiftUI views.
- Extract components only when they represent meaningful reusable concepts.
- Preserve native macOS behavior.
- Do not blindly reproduce web UI conventions.
- Keep preview and export rendering aligned.
- Handle persistence migrations deliberately.
- Add tests alongside critical domain logic.
- Prefer completing one vertical workflow over creating many incomplete screens.
- Do not implement non-MVP features unless required by foundational architecture.
- Do not leave placeholder architecture that complicates the project unnecessarily.

Before implementing a major subsystem, briefly document:

1. responsibility,
2. data flow,
3. important trade-offs,
4. expected failure cases.

---

## 39. First Development Milestone

The first milestone should produce a working local prototype containing:

- native app shell,
- sidebar,
- invoice list,
- client model,
- business model,
- invoice model,
- invoice calculation engine,
- basic invoice editor,
- one functional invoice template,
- live preview,
- local persistence.

No StoreKit, analytics, advanced templates, or cloud features should be implemented during this milestone.

The goal is to validate the application's core architecture and invoice-editing workflow first.

---

## 40. Final Product Standard

The finished application should feel like a small, focused Mac app that someone could confidently purchase from the Mac App Store.

It should not feel like:

- a tutorial project,
- a CRUD demo,
- an Electron clone,
- a generic AI-generated dashboard.

The benchmark is not feature quantity.

The benchmark is:

- clarity,
- reliability,
- document quality,
- polish,
- speed,
- native interaction,
- attention to detail.
