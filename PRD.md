# **Product Requirements Document (PRD): Vault & Edge**

**Version:** 1.0

**Status:** Draft / Ready for Prototyping

**Platform:** iOS Native

**Vibe:** Vibrant Minimalist (Premium Wellness)

---

## **1. Executive Summary**

**Vault & Edge** is a high-performance video analysis and scoring tool designed specifically for coaches of **Figure Skating** and **Gymnastics**. The app allows coaches to review program footage, timestamp specific elements, and apply sport-specific scoring logic (IJS or Code of Points). By leveraging **iOS Shared Albums**, the app provides a zero-cost cloud solution for video storage while maintaining elite-level data privacy.

---

## **2. Target Personas**

| Persona | Goals | Pain Points |
| --- | --- | --- |
| **The "Pro" Coach** | Quickly review run-throughs, track consistency, and provide data-backed feedback. | Messy camera rolls; manual math; repetitive parent questions. |
| **The Developing Athlete** | Understand technical deductions; visualize progress over a season. | Forgetting verbal cues; lack of "video-to-score" connection. |
| **The Invested Parent** | See child’s progress and understand the "why" behind the scores. | High cost of lessons; confusion over complex scoring systems. |

---

## **3. Functional Requirements**

### **3.1 Multi-Sport Configuration**

* **Sport Toggle:** Profile-level setting to switch between **Figure Skating** and **Gymnastics**.
* **Logic Engine:** * **Skating:** $Base Value + (GOE \times Scale Factor)$.
* **Gymnastics:** $D-Score - \sum(Deductions)$.


* **PPC (Planned Program Content):** Ability to pre-load a sequence of elements for a "one-tap" review experience.

### **3.2 The Analyzer (Review Interface)**

* **iOS Native Player:** Support for 240fps slow-motion scrubbing and pinch-to-zoom.
* **Smart Syncing:** A "Sync" button that drops a metadata pin on the video timeline to link it to a specific element.
* **The Scoring Tray:** * **Skating:** A vibrant slider ranging from -5 to +5.
* **Gymnastics:** Quick-tap "Deduction Chips" (-0.1, -0.3, -0.5, -1.0).


* **Landing Module:** Specific buttons for **Stuck, Hop, Step,** and **Fall**.

### **3.3 Storage & Privacy (The iCloud Architecture)**

* **Local-First / Shared Album:** The app does not host video. It references files within a selected **iCloud Shared Album**.
* **CloudKit Metadata:** Only text-based data (scores, timestamps, notes) is synced to the cloud.
* **Privacy Compliance:** No athlete video is stored on third-party servers, ensuring COPPA/GDPR safety.

---

## **4. User Experience & Design**

### **4.1 Visual Identity**

* **Palette:** Cloud White/Soft Grey base.
* **Accents:** **Electric Mint** (#00FFCC) for positive scores/stuck landings; **Soft Coral** (#FF7F7F) for deductions/falls.
* **Typography:** System (San Francisco) with "Large Title" hierarchy.

### **4.2 Haptics & Feedback**

* **Taptic Engine:** Distinct haptic patterns for "Stuck" landings (success buzz) vs. "Deductions" (short taps).
* **Micro-Animations:** Score total "bubbles" or glows when a high-value element is completed cleanly.

---

## **5. Information Architecture (Swift Models)**

```swift
enum SportType: String, Codable {
    case skating, gymnastics
}

struct ElementScore: Identifiable, Codable {
    var id = UUID()
    var elementCode: String
    var timestamp: Double // Video offset in seconds
    var executionValue: Double // GOE or Deduction sum
    var landing: LandingType
    var coachNote: String?
}

struct RunThrough: Identifiable, Codable {
    var id = UUID()
    var athleteID: UUID
    var videoLocalIdentifier: String // Reference to iOS Photo Library
    var date: Date
    var totalScore: Double
    var elements: [ElementScore]
}

```

---

## **6. Performance Metrics (Dashboard)**

### **6.1 The Consistency Heatmap**

A visual grid of all elements performed across the last 10 runs.

* **Green/Mint:** Avg Execution > 80% of max.
* **Coral/Orange:** Avg Execution < 50% of max.

### **6.2 The Trend Spline**

A SwiftUI Chart showing the progression of the "Total Score" over the course of the season.

---

## **7. Roadmap / Future Scope**

* **v1.1:** Side-by-side video comparison (Video A vs. Video B).
* **v1.2:** "Burn-in" export (Exporting the video with the score overlaid on the frame).
* **v1.3:** Apple Watch remote "Tagging" (Coach taps watch while filming to drop pins).

---

**Next Step:** Would you like me to generate a **SwiftUI code snippet** for the "Scoring Tray" to demonstrate how the Mint/Coral logic and iOS Haptics would be implemented?