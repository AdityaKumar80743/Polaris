# POLARIS — Path to Reach the Top (Flutter Mobile Application)

A cross-platform **Flutter** mobile application (Android & iOS) designed with a native OLED dark interface inspired by **Apple Health, Things 3, and Wise**.

## Included Features
1. **Summary Dashboard**: Apple Fitness-style custom-painted Activity Ring (`CustomPainter`), Move/Exercise/Hydration stack, and 2×2 quick-action tiles.
2. **Workouts**: Add training sessions (e.g., `10 Pushups`) with **Daily (24h)**, **Every 6 Hours**, or **Custom** intervals, plus an integrated active session stopwatch.
3. **Tasks & Visual Schedule**: Create tasks with optional deadlines and repeat rules (**Once, Daily, Weekly, Custom**). View tasks across a **7-Day Horizon**, **Monthly Calendar**, **Hourly Timeline**, and a pinned **No-Deadline Backlog** at the bottom.
4. **Water Drinking Tracker**: Track daily hydration with `+100ml`, `+250ml`, `+500ml`, custom intake, and editable daily target.
5. **Nutrition & Biometric Diet Planner**: Set targets for Calories, Protein, Carbs, Fiber, and Fats; log meals with auto-calculated macros by weight (grams); compute BMR & TDEE using the **Mifflin-St Jeor** equation based on Age, Height, Weight, Sex, Activity Level, and Goal.
6. **Expense Tracker**: Track spending across preset and user-created custom categories.
7. **Voice & Text Journal**: Record timed voice memos and written entries with mood tags.
8. **Activity Timeline**: Automatic chronological ledger of every action taken in the app.

## Running on Android & iOS Devices
```bash
flutter pub get
flutter run
```

To build a release APK for Android devices:
```bash
flutter build apk --release --split-per-abi
```
