import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF121214),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const PolarisApp());
}

// ============================================================================
// DESIGN TOKENS — Apple Health / Things 3 / Wise Inspired Native Dark Palette
// ============================================================================
class PolarisColors {
  static const Color bg = Color(0xFF000000);
  static const Color surface = Color(0xFF1C1C1E);
  static const Color surfaceElevated = Color(0xFF2C2C2E);
  static const Color divider = Color(0xFF38383A);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93);

  static const Color coral = Color(0xFFFF5500);
  static const Color fitnessRed = Color(0xFFFA114F);
  static const Color green = Color(0xFF30D158);
  static const Color blue = Color(0xFF0A84FF);
  static const Color amber = Color(0xFFFF9F0A);
  static const Color purple = Color(0xFFBF5AF2);
}

class PolarisApp extends StatelessWidget {
  const PolarisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polaris',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: PolarisColors.bg,
        primaryColor: PolarisColors.coral,
        colorScheme: const ColorScheme.dark(
          primary: PolarisColors.coral,
          secondary: PolarisColors.green,
          surface: PolarisColors.surface,
        ),
        useMaterial3: true,
        fontFamily: '.SF Pro Text',
        cardTheme: CardThemeData(
          color: PolarisColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: const PolarisShell(),
    );
  }
}

// ============================================================================
// DATA MODELS (Immutable & JSON Serializable)
// ============================================================================
class WorkoutSession {
  final String id;
  final String name;
  final String category;
  final String freqType; // 'daily', '6hours', 'custom'
  final int customVal;
  final String customUnit;
  int completedToday;
  String nextDueText;

  WorkoutSession({
    required this.id,
    required this.name,
    required this.category,
    required this.freqType,
    this.customVal = 6,
    this.customUnit = 'hours',
    this.completedToday = 0,
    this.nextDueText = 'Due Now',
  });

  String get freqLabel {
    if (freqType == 'daily') return 'Daily (24h)';
    if (freqType == '6hours') return 'Every 6 Hours';
    return 'Every $customVal $customUnit';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'freqType': freqType,
        'customVal': customVal,
        'customUnit': customUnit,
        'completedToday': completedToday,
        'nextDueText': nextDueText,
      };

  factory WorkoutSession.fromJson(Map<String, dynamic> j) => WorkoutSession(
        id: j['id'] ?? '',
        name: j['name'] ?? '',
        category: j['category'] ?? 'Strength',
        freqType: j['freqType'] ?? 'daily',
        customVal: j['customVal'] ?? 4,
        customUnit: j['customUnit'] ?? 'hours',
        completedToday: j['completedToday'] ?? 0,
        nextDueText: j['nextDueText'] ?? 'Due Now',
      );
}

class TodoItem {
  final String id;
  final String title;
  final String priority; // 'high', 'medium', 'low'
  final String repeat; // 'none', 'daily', 'weekly', 'custom'
  final String customRepeat;
  bool hasDeadline;
  String date; // YYYY-MM-DD
  String time; // HH:mm
  bool completed;

  TodoItem({
    required this.id,
    required this.title,
    this.priority = 'medium',
    this.repeat = 'none',
    this.customRepeat = '',
    this.hasDeadline = true,
    this.date = '2026-10-25',
    this.time = '09:30',
    this.completed = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'priority': priority,
        'repeat': repeat,
        'customRepeat': customRepeat,
        'hasDeadline': hasDeadline,
        'date': date,
        'time': time,
        'completed': completed,
      };

  factory TodoItem.fromJson(Map<String, dynamic> j) => TodoItem(
        id: j['id'] ?? '',
        title: j['title'] ?? '',
        priority: j['priority'] ?? 'medium',
        repeat: j['repeat'] ?? 'none',
        customRepeat: j['customRepeat'] ?? '',
        hasDeadline: j['hasDeadline'] ?? false,
        date: j['date'] ?? '',
        time: j['time'] ?? '',
        completed: j['completed'] ?? false,
      );
}

class FoodItemRef {
  final String id;
  final String name;
  final int cal;
  final double carb;
  final double prot;
  final double fiber;
  final double fat;

  const FoodItemRef({
    required this.id,
    required this.name,
    required this.cal,
    required this.carb,
    required this.prot,
    required this.fiber,
    required this.fat,
  });
}

class LoggedMeal {
  final String id;
  final String name;
  final int qty;
  final String slot;
  final int cal;
  final int carb;
  final int prot;
  final int fiber;
  final int fat;
  final String time;

  LoggedMeal({
    required this.id,
    required this.name,
    required this.qty,
    required this.slot,
    required this.cal,
    required this.carb,
    required this.prot,
    required this.fiber,
    required this.fat,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'qty': qty,
        'slot': slot,
        'cal': cal,
        'carb': carb,
        'prot': prot,
        'fiber': fiber,
        'fat': fat,
        'time': time,
      };

  factory LoggedMeal.fromJson(Map<String, dynamic> j) => LoggedMeal(
        id: j['id'] ?? '',
        name: j['name'] ?? '',
        qty: j['qty'] ?? 100,
        slot: j['slot'] ?? 'Meal',
        cal: j['cal'] ?? 0,
        carb: j['carb'] ?? 0,
        prot: j['prot'] ?? 0,
        fiber: j['fiber'] ?? 0,
        fat: j['fat'] ?? 0,
        time: j['time'] ?? '',
      );
}

class ExpenseCategory {
  final String id;
  final String name;
  final String icon;
  final int colorValue;

  ExpenseCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'colorValue': colorValue,
      };

  factory ExpenseCategory.fromJson(Map<String, dynamic> j) => ExpenseCategory(
        id: j['id'] ?? '',
        name: j['name'] ?? 'General',
        icon: j['icon'] ?? '💳',
        colorValue: j['colorValue'] ?? 0xFF0A84FF,
      );
}

class ExpenseRecord {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String method;
  final String time;

  ExpenseRecord({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.method,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'category': category,
        'method': method,
        'time': time,
      };

  factory ExpenseRecord.fromJson(Map<String, dynamic> j) => ExpenseRecord(
        id: j['id'] ?? '',
        title: j['title'] ?? '',
        amount: (j['amount'] as num?)?.toDouble() ?? 0.0,
        category: j['category'] ?? 'Food & Dining',
        method: j['method'] ?? 'Card',
        time: j['time'] ?? '',
      );
}

class JournalEntry {
  final String id;
  final String type; // 'voice' or 'text'
  final String title;
  final String mood;
  final String duration;
  final String transcript;
  final String time;

  JournalEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.mood,
    required this.duration,
    required this.transcript,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'mood': mood,
        'duration': duration,
        'transcript': transcript,
        'time': time,
      };

  factory JournalEntry.fromJson(Map<String, dynamic> j) => JournalEntry(
        id: j['id'] ?? '',
        type: j['type'] ?? 'text',
        title: j['title'] ?? '',
        mood: j['mood'] ?? '🔥 Focused',
        duration: j['duration'] ?? '',
        transcript: j['transcript'] ?? '',
        time: j['time'] ?? '',
      );
}

class TimelineEvent {
  final String id;
  final String category; // 'workout', 'todo', 'water', 'meal', 'expense', 'journal'
  final String title;
  final String badge;
  final String time;

  TimelineEvent({
    required this.id,
    required this.category,
    required this.title,
    required this.badge,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'title': title,
        'badge': badge,
        'time': time,
      };

  factory TimelineEvent.fromJson(Map<String, dynamic> j) => TimelineEvent(
        id: j['id'] ?? '',
        category: j['category'] ?? 'journal',
        title: j['title'] ?? '',
        badge: j['badge'] ?? '',
        time: j['time'] ?? '',
      );
}

// ============================================================================
// MAIN APPLICATION SHELL & STATE CONTROLLER
// ============================================================================
class PolarisShell extends StatefulWidget {
  const PolarisShell({super.key});

  @override
  State<PolarisShell> createState() => _PolarisShellState();
}

class _PolarisShellState extends State<PolarisShell> {
  static const String _prefsKey = 'polaris_flutter_state_v1';

  static const List<FoodItemRef> foodCatalog = [
    FoodItemRef(id: 'oatmeal_protein', name: 'Oatmeal with protein', cal: 340, carb: 48, prot: 28, fiber: 8, fat: 6),
    FoodItemRef(id: 'chicken_breast', name: 'Grilled Chicken Breast', cal: 165, carb: 0, prot: 31, fiber: 0, fat: 3.6),
    FoodItemRef(id: 'rolled_oats', name: 'Rolled Oats', cal: 389, carb: 66, prot: 16.9, fiber: 10.6, fat: 6.9),
    FoodItemRef(id: 'whole_eggs', name: 'Whole Eggs', cal: 155, carb: 1.1, prot: 13, fiber: 0, fat: 11),
    FoodItemRef(id: 'brown_rice', name: 'Cooked Brown Rice', cal: 123, carb: 25.6, prot: 2.7, fiber: 1.8, fat: 1.0),
    FoodItemRef(id: 'greek_yogurt', name: 'Greek Yogurt', cal: 97, carb: 3.9, prot: 10, fiber: 0, fat: 5),
    FoodItemRef(id: 'whey_isolate', name: 'Whey Protein Isolate', cal: 370, carb: 6, prot: 82, fiber: 0, fat: 2),
    FoodItemRef(id: 'salmon_fillet', name: 'Atlantic Salmon Fillet', cal: 208, carb: 0, prot: 20.4, fiber: 0, fat: 13.4),
    FoodItemRef(id: 'paneer', name: 'Paneer / Cottage Cheese', cal: 265, carb: 3.4, prot: 18.3, fiber: 0, fat: 20.8),
    FoodItemRef(id: 'lentils', name: 'Cooked Dal / Lentils', cal: 116, carb: 20.1, prot: 9.0, fiber: 7.9, fat: 0.4),
  ];

  int _currentTab = 0; // 0: Summary, 1: Workouts, 2: Schedule/Todo, 3: Fuel, 4: Expenses, 5: Journal
  int _scheduleSubTab = 0; // 0: Visual Schedule, 1: Task Manager
  int _fuelSubTab = 0; // 0: Meals, 1: Diet Planner, 2: Water
  String _selectedDate = '2026-10-25';

  // Active Session Stopwatch
  Timer? _stopwatchTimer;
  int _stopwatchSeconds = 625;

  // Voice Note Recorder
  Timer? _voiceTimer;
  int _voiceSeconds = 0;
  bool _isRecordingVoice = false;

  // State Collections
  List<WorkoutSession> _workouts = [];
  List<TodoItem> _todos = [];
  int _waterCurrent = 1200;
  int _waterTarget = 2500;
  int _targetCal = 2500;
  int _targetCarb = 250;
  int _targetProt = 160;
  int _targetFiber = 35;
  int _targetFat = 75;

  // Biometric Planner Inputs
  int _age = 25;
  int _heightCm = 178;
  int _weightKg = 74;
  String _gender = 'male';
  double _activityFactor = 1.55;
  String _goal = 'leangain'; // 'loss', 'maintain', 'leangain', 'gain'

  List<LoggedMeal> _meals = [];
  List<ExpenseCategory> _expenseCategories = [];
  List<ExpenseRecord> _expenses = [];
  List<JournalEntry> _journals = [];
  List<TimelineEvent> _timeline = [];

  @override
  void initState() {
    super.initState();
    _seedDefaultData();
    _loadPersistedState();
  }

  @override
  void dispose() {
    _stopwatchTimer?.cancel();
    _voiceTimer?.cancel();
    super.dispose();
  }

  void _seedDefaultData() {
    _workouts = [
      WorkoutSession(id: 'w1', name: '10 Pushups', category: 'Strength', freqType: '6hours', completedToday: 2, nextDueText: 'Every 6 Hours'),
      WorkoutSession(id: 'w2', name: '50 Bodyweight Squats', category: 'Strength', freqType: 'daily', completedToday: 1, nextDueText: 'Daily (24h)'),
      WorkoutSession(id: 'w3', name: '90s Core Plank Hold', category: 'Core', freqType: 'custom', customVal: 4, customUnit: 'hours', completedToday: 1, nextDueText: 'Every 4 hours'),
    ];
    _todos = [
      TodoItem(id: 't1', title: 'Morning 10 Pushups & Mobility', priority: 'medium', repeat: 'daily', hasDeadline: true, date: '2026-10-25', time: '07:00', completed: true),
      TodoItem(id: 't2', title: 'Review Project Architecture', priority: 'high', repeat: 'daily', hasDeadline: true, date: '2026-10-25', time: '09:30', completed: false),
      TodoItem(id: 't3', title: 'High-Protein Lunch & Hydration', priority: 'medium', repeat: 'daily', hasDeadline: true, date: '2026-10-25', time: '12:30', completed: false),
      TodoItem(id: 't4', title: 'Read 30 Pages of Peak Performance', priority: 'low', repeat: 'none', hasDeadline: false, date: '', time: '', completed: false),
      TodoItem(id: 't5', title: 'Organize Home Gym Gear', priority: 'low', repeat: 'none', hasDeadline: false, date: '', time: '', completed: false),
    ];
    _meals = [
      LoggedMeal(id: 'm1', name: 'Oatmeal with protein', qty: 100, slot: 'Breakfast', cal: 340, carb: 48, prot: 28, fiber: 8, fat: 6, time: '08:15 AM'),
      LoggedMeal(id: 'm2', name: 'Grilled Chicken Breast', qty: 200, slot: 'Lunch', cal: 330, carb: 0, prot: 62, fiber: 0, fat: 7, time: '12:30 PM'),
      LoggedMeal(id: 'm3', name: 'Cooked Dal / Lentils', qty: 180, slot: 'Dinner', cal: 209, carb: 36, prot: 16, fiber: 14, fat: 1, time: '08:00 PM'),
    ];
    _expenseCategories = [
      ExpenseCategory(id: 'c1', name: 'Food & Dining', icon: '🥗', colorValue: 0xFF30D158),
      ExpenseCategory(id: 'c2', name: 'Transport', icon: '🚇', colorValue: 0xFF0A84FF),
      ExpenseCategory(id: 'c3', name: 'Fitness & Gym', icon: '🏋️', colorValue: 0xFFFF5500),
      ExpenseCategory(id: 'c4', name: 'Bills', icon: '⚡', colorValue: 0xFFFF9F0A),
    ];
    _expenses = [
      ExpenseRecord(id: 'e1', title: 'Whey Isolate & Oats', amount: 34.50, category: 'Food & Dining', method: 'Card', time: '09:20 AM'),
      ExpenseRecord(id: 'e2', title: 'Gym Membership', amount: 45.00, category: 'Fitness & Gym', method: 'Card', time: '11:15 AM'),
    ];
    _journals = [
      JournalEntry(
        id: 'j1',
        type: 'voice',
        title: 'Post-Workout Clarity Note',
        mood: '🔥 Focused',
        duration: '00:18',
        transcript: 'Completed all 6-hour pushup intervals on schedule today.',
        time: '03:00 PM',
      ),
      JournalEntry(
        id: 'j2',
        type: 'text',
        title: 'Evening Reflection',
        mood: '🧭 Reflective',
        duration: '',
        transcript: 'Keeping unscheduled tasks pinned at the bottom keeps the daily timeline clean.',
        time: '06:30 PM',
      ),
    ];
    _timeline = [
      TimelineEvent(id: 'tl1', category: 'journal', title: 'Saved Voice Note: Post-Workout Clarity', badge: '🎙️ 00:18', time: '03:00 PM'),
      TimelineEvent(id: 'tl2', category: 'meal', title: 'Logged Lunch: Grilled Chicken (200g)', badge: '+330 kcal • 62g P', time: '12:30 PM'),
      TimelineEvent(id: 'tl3', category: 'workout', title: 'Completed 10 Pushups', badge: 'Every 6 Hours', time: '08:00 AM'),
    ];
  }

  Future<void> _loadPersistedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      final Map<String, dynamic> data = jsonDecode(raw);
      setState(() {
        _waterCurrent = (data['waterCurrent'] as int?) ?? 1200;
        _waterTarget = (data['waterTarget'] as int?) ?? 2500;
        if (data['workouts'] != null) {
          _workouts = (data['workouts'] as List).map((e) => WorkoutSession.fromJson(e)).toList();
        }
        if (data['todos'] != null) {
          _todos = (data['todos'] as List).map((e) => TodoItem.fromJson(e)).toList();
        }
        if (data['meals'] != null) {
          _meals = (data['meals'] as List).map((e) => LoggedMeal.fromJson(e)).toList();
        }
        if (data['expenses'] != null) {
          _expenses = (data['expenses'] as List).map((e) => ExpenseRecord.fromJson(e)).toList();
        }
        if (data['journals'] != null) {
          _journals = (data['journals'] as List).map((e) => JournalEntry.fromJson(e)).toList();
        }
        if (data['timeline'] != null) {
          _timeline = (data['timeline'] as List).map((e) => TimelineEvent.fromJson(e)).toList();
        }
      });
    } catch (_) {}
  }

  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = jsonEncode({
        'waterCurrent': _waterCurrent,
        'waterTarget': _waterTarget,
        'workouts': _workouts.map((e) => e.toJson()).toList(),
        'todos': _todos.map((e) => e.toJson()).toList(),
        'meals': _meals.map((e) => e.toJson()).toList(),
        'expenses': _expenses.map((e) => e.toJson()).toList(),
        'journals': _journals.map((e) => e.toJson()).toList(),
        'timeline': _timeline.map((e) => e.toJson()).toList(),
      });
      await prefs.setString(_prefsKey, payload);
    } catch (_) {}
  }

  String _nowTimeStr() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, '0')}:$m $ampm';
  }

  void _logEvent(String category, String title, String badge) {
    HapticFeedback.lightImpact();
    setState(() {
      _timeline.insert(
        0,
        TimelineEvent(
          id: 'tl_${DateTime.now().millisecondsSinceEpoch}',
          category: category,
          title: title,
          badge: badge,
          time: _nowTimeStr(),
        ),
      );
    });
    _saveState();
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: PolarisColors.surfaceElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          duration: const Duration(milliseconds: 1600),
          content: Text(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      );
    }
  }

  // Computed Aggregates
  int get _totalWorkoutSets => _workouts.fold(0, (s, w) => s + w.completedToday);
  int get _completedTasksCount => _todos.where((t) => t.completed).length;
  int get _totalCalConsumed => _meals.fold(0, (s, m) => s + m.cal);
  int get _totalCarbConsumed => _meals.fold(0, (s, m) => s + m.carb);
  int get _totalProtConsumed => _meals.fold(0, (s, m) => s + m.prot);
  int get _totalFiberConsumed => _meals.fold(0, (s, m) => s + m.fiber);
  int get _totalFatConsumed => _meals.fold(0, (s, m) => s + m.fat);
  double get _totalExpenses => _expenses.fold(0.0, (s, e) => s + e.amount);

  double get _dailyScore {
    final wScore = math.min(1.0, _totalWorkoutSets / 4.0);
    final tScore = _todos.isEmpty ? 1.0 : _completedTasksCount / _todos.length;
    final hScore = math.min(1.0, _waterCurrent / math.max(1, _waterTarget));
    final nScore = math.min(1.0, _totalCalConsumed / math.max(1, _targetCal));
    return ((wScore + tScore + hScore + nScore) / 4.0).clamp(0.0, 1.0);
  }

  List<TodoItem> _tasksForDate(String dateStr) {
    final target = DateTime.tryParse(dateStr);
    return _todos.where((t) {
      if (!t.hasDeadline || t.date.isEmpty) return false;
      if (t.date == dateStr) return true;
      final start = DateTime.tryParse(t.date);
      if (start == null || target == null || target.isBefore(start)) return false;
      final diffDays = target.difference(start).inDays;
      if (t.repeat == 'daily') return true;
      if (t.repeat == 'weekly') return diffDays % 7 == 0;
      if (t.repeat == 'custom') {
        final match = RegExp(r'(\d+)').firstMatch(t.customRepeat);
        final step = match != null ? math.max(1, int.parse(match.group(1)!)) : 2;
        return diffDays % step == 0;
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PolarisColors.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: IndexedStack(
                    index: _currentTab,
                    children: [
                      _buildSummaryTab(),
                      _buildWorkoutsTab(),
                      _buildScheduleAndTasksTab(),
                      _buildFuelTab(),
                      _buildExpensesTab(),
                      _buildJournalAndTimelineTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ==========================================================================
  // TOP HEADER BAR
  // ==========================================================================
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: PolarisColors.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.explore_rounded, color: PolarisColors.coral, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Polaris',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.4),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() {
                  _currentTab = 2;
                  _scheduleSubTab = 0;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: PolarisColors.surface,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text('Calendar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showTimelineModal(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: PolarisColors.surface,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      const Text('Activity', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: PolarisColors.green,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${_timeline.length}',
                          style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // TAB 0: SUMMARY DASHBOARD (Apple Health / Fitness+ Style)
  // ==========================================================================
  Widget _buildSummaryTab() {
    final scorePct = (_dailyScore * 100).round();
    final waterPct = ((_waterCurrent / math.max(1, _waterTarget)) * 100).clamp(0, 100).round();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        const Text('Sunday, Oct 25', style: TextStyle(color: PolarisColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Summary', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
            Text('${3800 + scorePct * 12}m Peak', style: const TextStyle(color: PolarisColors.green, fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 16),

        // Activity Ring Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: PolarisColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: CustomPaint(
                  painter: _ActivityRingPainter(progress: _dailyScore),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$scorePct%', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                        const Text('Goal', style: TextStyle(color: PolarisColors.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 22),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Move', style: TextStyle(color: PolarisColors.fitnessRed, fontSize: 12, fontWeight: FontWeight.w700)),
                    Text('${145 + _totalWorkoutSets * 20}/500 KCAL', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    const Text('Exercise', style: TextStyle(color: PolarisColors.green, fontSize: 12, fontWeight: FontWeight.w700)),
                    Text(
                      '${(_stopwatchSeconds ~/ 60).toString().padLeft(2, '0')}:${(_stopwatchSeconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    const Text('Hydration', style: TextStyle(color: PolarisColors.blue, fontSize: 12, fontWeight: FontWeight.w700)),
                    Text('$waterPct%', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 2x2 Summary Tiles
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.05,
          children: [
            // Workout Tile
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: PolarisColors.surface, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Workouts', style: TextStyle(color: PolarisColors.coral, fontSize: 12, fontWeight: FontWeight.w700)),
                      Text('$_totalWorkoutSets Sets', style: const TextStyle(color: PolarisColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Text(
                    _workouts.isNotEmpty ? _workouts.first.name : 'Add Drill',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PolarisColors.coral,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () {
                        if (_workouts.isNotEmpty) {
                          setState(() => _workouts.first.completedToday++);
                          _logEvent('workout', 'Completed ${_workouts.first.name}', _workouts.first.freqLabel);
                        } else {
                          setState(() => _currentTab = 1);
                        }
                      },
                      child: const Text('Log Set', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),

            // Hydration Tile
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: PolarisColors.surface, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Water', style: TextStyle(color: PolarisColors.blue, fontSize: 12, fontWeight: FontWeight.w700)),
                      Text('${(_waterCurrent / 1000).toStringAsFixed(1)}L', style: const TextStyle(color: PolarisColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Text('$_waterCurrent / $_waterTarget ml', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: PolarisColors.surfaceElevated),
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: () {
                            setState(() => _waterCurrent += 100);
                            _logEvent('water', 'Drank Water (+100ml)', '$_waterCurrent/$_waterTarget ml');
                          },
                          child: const Text('+100', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PolarisColors.blue,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: () {
                            setState(() => _waterCurrent += 250);
                            _logEvent('water', 'Drank Water (+250ml)', '$_waterCurrent/$_waterTarget ml');
                          },
                          child: const Text('+250', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Nutrition Tile
            GestureDetector(
              onTap: () => setState(() => _currentTab = 3),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: PolarisColors.surface, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Nutrition', style: TextStyle(color: PolarisColors.green, fontSize: 12, fontWeight: FontWeight.w700)),
                    Text('$_totalCalConsumed kcal', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    Column(
                      children: [
                        _miniMacroRow('Protein', '$_totalProtConsumed/${_targetProt}g'),
                        const SizedBox(height: 3),
                        _miniMacroRow('Carbs', '$_totalCarbConsumed/${_targetCarb}g'),
                        const SizedBox(height: 3),
                        _miniMacroRow('Fiber', '$_totalFiberConsumed/${_targetFiber}g'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Tasks & Expenses Tile
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: PolarisColors.surface, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _currentTab = 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tasks', style: TextStyle(color: PolarisColors.amber, fontSize: 12, fontWeight: FontWeight.w700)),
                        Text('$_completedTasksCount/${_todos.length}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  const Divider(color: PolarisColors.surfaceElevated, height: 12),
                  GestureDetector(
                    onTap: () => setState(() => _currentTab = 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Spent Today', style: TextStyle(color: PolarisColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('\$${_totalExpenses.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        // Today's Tasks Preview
        const Text('Today\'s Tasks', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: PolarisColors.surface, borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: _todos.take(4).map((t) {
              return ListTile(
                onTap: () {
                  setState(() => t.completed = !t.completed);
                  if (t.completed) _logEvent('todo', 'Completed Task: ${t.title}', 'Done');
                },
                leading: Icon(
                  t.completed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: t.completed ? PolarisColors.green : PolarisColors.textSecondary,
                ),
                title: Text(
                  t.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: t.completed ? TextDecoration.lineThrough : null,
                    color: t.completed ? PolarisColors.textSecondary : Colors.white,
                  ),
                ),
                trailing: Text(
                  t.hasDeadline ? t.time : 'No Deadline',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: t.hasDeadline ? PolarisColors.blue : PolarisColors.amber,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _miniMacroRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: PolarisColors.textSecondary, fontSize: 11)),
        Text(val, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    );
  }

  // ==========================================================================
  // TAB 1: WORKOUTS (Daily, 6 Hours, Custom Intervals + Stopwatch)
  // ==========================================================================
  Widget _buildWorkoutsTab() {
    final nameCtrl = TextEditingController();
    String selectedFreq = 'daily';
    final customValCtrl = TextEditingController(text: '4');

    return StatefulBuilder(
      builder: (context, setLocalState) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            const Text('Workouts', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
            const SizedBox(height: 14),

            // Stopwatch Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: PolarisColors.surface, borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Session Timer', style: TextStyle(color: PolarisColors.textSecondary, fontSize: 12)),
                      Text(
                        '${(_stopwatchSeconds ~/ 60).toString().padLeft(2, '0')}:${(_stopwatchSeconds % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PolarisColors.green,
                          foregroundColor: Colors.black,
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () {
                          if (_stopwatchTimer?.isActive ?? false) {
                            _stopwatchTimer?.cancel();
                            setState(() {});
                          } else {
                            _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (_) {
                              setState(() => _stopwatchSeconds++);
                            });
                          }
                        },
                        child: Text((_stopwatchTimer?.isActive ?? false) ? 'Pause' : 'Start', style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          _stopwatchTimer?.cancel();
                          setState(() => _stopwatchSeconds = 0);
                        },
                        child: const Text('Reset', style: TextStyle(color: PolarisColors.textSecondary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // New Workout Form
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: PolarisColors.surface, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add Training Session', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g. 10 Pushups, 30 Squats',
                      filled: true,
                      fillColor: PolarisColors.surfaceElevated,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CupertinoSlidingSegmentedControl<String>(
                    groupValue: selectedFreq,
                    backgroundColor: PolarisColors.surfaceElevated,
                    children: const {
                      'daily': Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Daily', style: TextStyle(fontSize: 12))),
                      '6hours': Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Every 6h', style: TextStyle(fontSize: 12))),
                      'custom': Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Custom', style: TextStyle(fontSize: 12))),
                    },
                    onValueChanged: (v) {
                      if (v != null) setLocalState(() => selectedFreq = v);
                    },
                  ),
                  if (selectedFreq == 'custom') ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: customValCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Repeat every X hours',
                        filled: true,
                        fillColor: PolarisColors.surfaceElevated,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PolarisColors.coral,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        if (name.isEmpty) return;
                        final customHours = int.tryParse(customValCtrl.text) ?? 4;
                        final session = WorkoutSession(
                          id: 'w_${DateTime.now().millisecondsSinceEpoch}',
                          name: name,
                          category: 'Strength',
                          freqType: selectedFreq,
                          customVal: customHours.clamp(1, 168),
                        );
                        setState(() => _workouts.insert(0, session));
                        _logEvent('workout', 'Added Workout: $name', session.freqLabel);
                        nameCtrl.clear();
                      },
                      child: const Text('+ Add Training Session', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Workout Cards
            ..._workouts.map((w) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: PolarisColors.surface, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(w.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('${w.freqLabel} • ${w.completedToday} sets today', style: const TextStyle(color: PolarisColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PolarisColors.coral,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () {
                        setState(() => w.completedToday++);
                        _logEvent('workout', 'Completed ${w.name}', 'Set #${w.completedToday}');
                      },
                      child: const Text('+ Set', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  // ==========================================================================
  // TAB 2: SCHEDULE & TASKS (Month, Day-to-Day, Hourly + No-Deadline Bottom)
  // ==========================================================================
  Widget _buildScheduleAndTasksTab() {
    final titleCtrl = TextEditingController();
    String repeatMode = 'none';
    bool hasDeadline = true;
    String timeStr = '09:30';

    return StatefulBuilder(
      builder: (context, setLocalState) {
        final timedTasks = _tasksForDate(_selectedDate)..sort((a, b) => a.time.compareCompareTo(b.time));
        final noDeadlineTasks = _todos.where((t) => !t.hasDeadline).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Schedule', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
                CupertinoSlidingSegmentedControl<int>(
                  groupValue: _scheduleSubTab,
                  backgroundColor: PolarisColors.surface,
                  children: const {
                    0: Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('Visuals', style: TextStyle(fontSize: 12))),
                    1: Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('+ Task', style: TextStyle(fontSize: 12))),
                  },
                  onValueChanged: (v) {
                    if (v != null) setState(() => _scheduleSubTab = v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_scheduleSubTab == 1) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: PolarisColors.surface, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('New Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        hintText: 'Task title...',
                        filled: true,
                        fillColor: PolarisColors.surfaceElevated,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CupertinoSlidingSegmentedControl<String>(
                      groupValue: repeatMode,
                      backgroundColor: PolarisColors.surfaceElevated,
                      children: const {
                        'none': Text('Once', style: TextStyle(fontSize: 12)),
                        'daily': Text('Daily', style: TextStyle(fontSize: 12)),
                        'weekly': Text('Weekly', style: TextStyle(fontSize: 12)),
                        'custom': Text('Custom', style: TextStyle(fontSize: 12)),
                      },
                      onValueChanged: (v) {
                        if (v != null) setLocalState(() => repeatMode = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Assign Deadline', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      value: hasDeadline,
                      activeColor: PolarisColors.blue,
                      onChanged: (v) => setLocalState(() => hasDeadline = v),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          final t = titleCtrl.text.trim();
                          if (t.isEmpty) return;
                          final item = TodoItem(
                            id: 't_${DateTime.now().millisecondsSinceEpoch}',
                            title: t,
                            repeat: repeatMode,
                            hasDeadline: hasDeadline,
                            date: hasDeadline ? _selectedDate : '',
                            time: hasDeadline ? timeStr : '',
                          );
                          setState(() {
                            _todos.insert(0, item);
                            _scheduleSubTab = 0;
                          });
                          _logEvent('todo', 'Created Task: $t', hasDeadline ? _selectedDate : 'No Deadline');
                        },
                        child: const Text('+ Add Task', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // 1. Day-to-Day 7-Day Strip
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: PolarisColors.surface, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (idx) {
                    final dayNum = 21 + idx;
                    final dStr = '2026-10-$dayNum';
                    final names = ['Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Mon', 'Tue'];
                    final isSelected = dStr == _selectedDate;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDate = dStr),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? PolarisColors.coral : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Text(names[idx], style: TextStyle(fontSize: 10, color: isSelected ? Colors.white : PolarisColors.textSecondary)),
                            const SizedBox(height: 4),
                            Text('$dayNum', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Time-to-Time Hourly Timeline
              const Text('Hourly Timeline', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: PolarisColors.surface, borderRadius: BorderRadius.circular(20)),
                child: timedTasks.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: Text('No timed tasks for this date.', style: TextStyle(color: PolarisColors.textSecondary))),
                      )
                    : Column(
                        children: timedTasks.map((t) {
                          return ListTile(
                            leading: Text(t.time, style: const TextStyle(color: PolarisColors.blue, fontWeight: FontWeight.w700, fontSize: 13)),
                            title: Text(
                              t.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                decoration: t.completed ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            subtitle: Text('Repeat: ${t.repeat}', style: const TextStyle(color: PolarisColors.textSecondary, fontSize: 12)),
                            trailing: IconButton(
                              icon: Icon(
                                t.completed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                color: t.completed ? PolarisColors.green : PolarisColors.textSecondary,
                              ),
                              onPressed: () {
                                setState(() => t.completed = !t.completed);
                                if (t.completed) _logEvent('todo', 'Completed Task: ${t.title}', 'Done');
                              },
                            ),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 20),

              // 3. No-Deadline Tasks Pinned at the Bottom
              const Text('No Deadline (Unscheduled)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: PolarisColors.surface, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: noDeadlineTasks.map((t) {
                    return ListTile(
                      leading: Icon(
                        t.completed ? Icons.check_circle_rounded : Icons.circle_outlined,
                        color: t.completed ? PolarisColors.green : PolarisColors.amber,
                      ),
                      title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      trailing: TextButton(
                        onPressed: () {
                          setState(() {
                            t.hasDeadline = true;
                            t.date = _selectedDate;
                            t.time = '16:00';
                          });
                          _logEvent('todo', 'Scheduled Task: ${t.title}', '$_selectedDate 16:00');
                        },
                        child: const Text('Schedule Today', style: TextStyle(color: PolarisColors.amber, fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  // ==========================================================================
  // TAB 3: FUEL (Meals, BMR/TDEE Diet Planner & Water Tracker)
  // ==========================================================================
  Widget _buildFuelTab() {
    FoodItemRef selectedFood = foodCatalog.first;
    final qtyCtrl = TextEditingController(text: '150');

    return StatefulBuilder(
      builder: (context, setLocalState) {
        final s = _gender == 'male' ? 5 : -161;
        final bmr = (10 * _weightKg + 6.25 * _heightCm - 5 * _age + s).round();
        final tdee = (bmr * _activityFactor).round();
        final goalDelta = _goal == 'loss' ? -500 : (_goal == 'maintain' ? 0 : 300);
        final recCal = math.max(1200, tdee + goalDelta);
        final recProt = (_weightKg * 2.2).round();
        final recFat = ((recCal * 0.26) / 9).round();
        final recCarb = math.max(60, ((recCal - (recProt * 4 + recFat * 9)) / 4).round());

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            const Text('Nutrition', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
            const SizedBox(height: 12),
            CupertinoSlidingSegmentedControl<int>(
              groupValue: _fuelSubTab,
              backgroundColor: PolarisColors.surface,
              children: const {
                0: Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text('Meals', style: TextStyle(fontSize: 12))),
                1: Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text('Diet Plan', style: TextStyle(fontSize: 12))),
                2: Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text('Water', style: TextStyle(fontSize: 12))),
              },
              onValueChanged: (v) {
                if (v != null) setState(() => _fuelSubTab = v);
              },
            ),
            const SizedBox(height: 16),

            if (_fuelSubTab == 0) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: PolarisColors.surface, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$_totalCalConsumed / $_targetCal kcal', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    _macroBarRow('Protein', _totalProtConsumed, _targetProt, PolarisColors.green),
                    const SizedBox(height: 8),
                    _macroBarRow('Carbs', _totalCarbConsumed, _targetCarb, PolarisColors.blue),
                    const SizedBox(height: 8),
                    _macroBarRow('Fiber', _totalFiberConsumed, _targetFiber, PolarisColors.amber),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: PolarisColors.surface, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Auto-Calculate Food Macros', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<FoodItemRef>(
                      value: selectedFood,
                      dropdownColor: PolarisColors.surfaceElevated,
                      items: foodCatalog.map((f) => DropdownMenuItem(value: f, child: Text(f.name, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (v) {
                        if (v != null) setLocalState(() => selectedFood = v);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: qtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quantity (grams)',
                        filled: true,
                        fillColor: PolarisColors.surfaceElevated,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PolarisColors.green,
                          foregroundColor: Colors.black,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          final q = (int.tryParse(qtyCtrl.text) ?? 100).clamp(5, 3000);
                          final factor = q / 100.0;
                          final meal = LoggedMeal(
                            id: 'm_${DateTime.now().millisecondsSinceEpoch}',
                            name: selectedFood.name,
                            qty: q,
                            slot: 'Meal',
                            cal: (selectedFood.cal * factor).round(),
                            carb: (selectedFood.carb * factor).round(),
                            prot: (selectedFood.prot * factor).round(),
                            fiber: (selectedFood.fiber * factor).round(),
                            fat: (selectedFood.fat * factor).round(),
                            time: _nowTimeStr(),
                          );
                          setState(() => _meals.insert(0, meal));
                          _logEvent('meal', 'Logged ${meal.name} (${meal.qty}g)', '+${meal.cal} kcal');
                        },
                        child: const Text('+ Calculate & Log Meal', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_fuelSubTab == 1) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: PolarisColors.surface, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Biometric Diet Planner', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text('BMR: $bmr kcal • TDEE: $tdee kcal', style: const TextStyle(color: PolarisColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 8),
                    Text('Recommended: $recCal kcal ($recProt g P • $recCarb g C)', style: const TextStyle(color: PolarisColors.green, fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: const StadiumBorder()),
                        onPressed: () {
                          setState(() {
                            _targetCal = recCal;
                            _targetProt = recProt;
                            _targetCarb = recCarb;
                            _targetFat = recFat;
                            _fuelSubTab = 0;
                          });
                          _logEvent('meal', 'Applied Biometric Diet Plan', '$recCal kcal');
                        },
                        child: const Text('Apply Targets to Tracker', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: PolarisColors.surface, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$_waterCurrent / $_waterTarget ml', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 14),
                    Row(
                      children: [100, 250, 500].map((amt) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: PolarisColors.blue, foregroundColor: Colors.white, shape: const StadiumBorder()),
                              onPressed: () {
                                setState(() => _waterCurrent += amt);
                                _logEvent('water', 'Drank Water (+${amt}ml)', '$_waterCurrent/$_waterTarget ml');
                              },
                              child: Text('+${amt}ml', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _macroBarRow(String label, int current, int target, Color color) {
    final ratio = (current / math.max(1, target)).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: PolarisColors.textSecondary, fontSize: 12)),
            Text('$current/${target}g', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: PolarisColors.surfaceElevated,
            color: color,
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // TAB 4: EXPENSES (Preset & Custom Categories)
  // ==========================================================================
  Widget _buildExpensesTab() {
    final titleCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    final customCatCtrl = TextEditingController();
    String selectedCategory = _expenseCategories.first.name;

    return StatefulBuilder(
      builder: (context, setLocalState) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Expenses', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
                Text('\$${_totalExpenses.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: PolarisColors.surface, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Log Expense', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: titleCtrl,
                          decoration: InputDecoration(
                            hintText: 'Description',
                            filled: true,
                            fillColor: PolarisColors.surfaceElevated,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: amtCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '\$0.00',
                            filled: true,
                            fillColor: PolarisColors.surfaceElevated,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    dropdownColor: PolarisColors.surfaceElevated,
                    items: _expenseCategories.map((c) => DropdownMenuItem(value: c.name, child: Text('${c.icon} ${c.name}'))).toList(),
                    onChanged: (v) {
                      if (v != null) setLocalState(() => selectedCategory = v);
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: customCatCtrl,
                          decoration: InputDecoration(
                            hintText: '+ New custom category',
                            filled: true,
                            fillColor: PolarisColors.surfaceElevated,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          final cName = customCatCtrl.text.trim();
                          if (cName.isEmpty) return;
                          setState(() {
                            _expenseCategories.add(ExpenseCategory(id: 'c_${DateTime.now().millisecondsSinceEpoch}', name: cName, icon: '🎯', colorValue: 0xFFBF5AF2));
                            selectedCategory = cName;
                          });
                          customCatCtrl.clear();
                        },
                        child: const Text('Add Cat', style: TextStyle(color: PolarisColors.blue, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: () {
                        final t = titleCtrl.text.trim();
                        final a = double.tryParse(amtCtrl.text) ?? 0;
                        if (t.isEmpty || a <= 0) return;
                        setState(() {
                          _expenses.insert(0, ExpenseRecord(id: 'e_${DateTime.now().millisecondsSinceEpoch}', title: t, amount: a, category: selectedCategory, method: 'Card', time: _nowTimeStr()));
                        });
                        _logEvent('expense', 'Expense: $t', '\$${a.toStringAsFixed(2)}');
                      },
                      child: const Text('+ Record Expense', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(color: PolarisColors.surface, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: _expenses.map((e) {
                  return ListTile(
                    title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    subtitle: Text('${e.category} • ${e.time}', style: const TextStyle(color: PolarisColors.textSecondary, fontSize: 12)),
                    trailing: Text('-\$${e.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================================
  // TAB 5: VOICE & TEXT JOURNAL + TIMELINE
  // ==========================================================================
  Widget _buildJournalAndTimelineTab() {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        const Text('Journal', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
        const SizedBox(height: 14),

        // Voice Note Recorder Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: PolarisColors.surface, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Voice Memo Recorder', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  Text(
                    '${(_voiceSeconds ~/ 60).toString().padLeft(2, '0')}:${(_voiceSeconds % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(color: PolarisColors.fitnessRed, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.white, shape: const StadiumBorder()),
                      onPressed: () {
                        if (_isRecordingVoice) {
                          _voiceTimer?.cancel();
                          setState(() => _isRecordingVoice = false);
                        } else {
                          setState(() {
                            _isRecordingVoice = true;
                            _voiceSeconds = 0;
                          });
                          _voiceTimer = Timer.periodic(const Duration(seconds: 1), (_) {
                            setState(() => _voiceSeconds++);
                          });
                        }
                      },
                      child: Text(_isRecordingVoice ? 'Stop Recording' : 'Record Voice Note'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: const StadiumBorder()),
                    onPressed: () {
                      _voiceTimer?.cancel();
                      final dur = '00:${math.max(5, _voiceSeconds).toString().padLeft(2, '0')}';
                      setState(() {
                        _isRecordingVoice = false;
                        _journals.insert(
                          0,
                          JournalEntry(
                            id: 'j_${DateTime.now().millisecondsSinceEpoch}',
                            type: 'voice',
                            title: 'Voice Note (${_nowTimeStr()})',
                            mood: '🔥 Focused',
                            duration: dur,
                            transcript: 'Recorded audio reflection ($dur)',
                            time: _nowTimeStr(),
                          ),
                        );
                      });
                      _logEvent('journal', 'Saved Voice Note', '🎙️ $dur');
                    },
                    child: const Text('Save Voice', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Text Journal Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: PolarisColors.surface, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Written Entry', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  hintText: 'Entry title',
                  filled: true,
                  fillColor: PolarisColors.surfaceElevated,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: bodyCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write your thoughts...',
                  filled: true,
                  fillColor: PolarisColors.surfaceElevated,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () {
                    final t = titleCtrl.text.trim();
                    final b = bodyCtrl.text.trim();
                    if (t.isEmpty && b.isEmpty) return;
                    setState(() {
                      _journals.insert(
                        0,
                        JournalEntry(
                          id: 'j_${DateTime.now().millisecondsSinceEpoch}',
                          type: 'text',
                          title: t.isEmpty ? 'Daily Note' : t,
                          mood: '🧭 Reflective',
                          duration: '',
                          transcript: b.isEmpty ? t : b,
                          time: _nowTimeStr(),
                        ),
                      );
                    });
                    _logEvent('journal', 'Saved Journal: ${t.isEmpty ? 'Daily Note' : t}', '📝 Written');
                  },
                  child: const Text('+ Save Written Entry', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        ..._journals.map((j) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: PolarisColors.surface, borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(j.type == 'voice' ? '🎙️ VOICE • ${j.duration}' : '📝 WRITTEN', style: const TextStyle(color: PolarisColors.blue, fontSize: 11, fontWeight: FontWeight.w700)),
                    Text(j.time, style: const TextStyle(color: PolarisColors.textSecondary, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(j.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(j.transcript, style: const TextStyle(color: PolarisColors.textSecondary, fontSize: 13)),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _showTimelineModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: PolarisColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Activity Timeline', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: _timeline.length,
                    separatorBuilder: (_, __) => const Divider(color: PolarisColors.divider),
                    itemBuilder: (_, idx) {
                      final ev = _timeline[idx];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(ev.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: Text(ev.badge, style: const TextStyle(color: PolarisColors.green, fontSize: 12)),
                        trailing: Text(ev.time, style: const TextStyle(color: PolarisColors.textSecondary, fontSize: 12)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================================
  // BOTTOM NAVIGATION BAR
  // ==========================================================================
  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF121214),
        border: Border(top: BorderSide(color: PolarisColors.surfaceElevated, width: 0.5)),
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: _currentTab,
          onTap: (i) => setState(() => _currentTab = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: PolarisColors.textSecondary,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.bolt_rounded), label: 'Summary'),
            BottomNavigationBarItem(icon: Icon(Icons.fitness_center_rounded), label: 'Workouts'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_rounded), label: 'Schedule'),
            BottomNavigationBarItem(icon: Icon(Icons.restaurant_rounded), label: 'Nutrition'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Expenses'),
            BottomNavigationBarItem(icon: Icon(Icons.mic_rounded), label: 'Journal'),
          ],
        ),
      ),
    );
  }
}

extension on String {
  int compareCompareTo(String other) => compareTo(other);
}

// ============================================================================
// CUSTOM PAINTER FOR APPLE FITNESS STYLE ACTIVITY RING
// ============================================================================
class _ActivityRingPainter extends CustomPainter {
  final double progress;
  _ActivityRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 8;

    final trackPaint = Paint()
      ..color = PolarisColors.surfaceElevated
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11;

    canvas.drawCircle(center, radius, trackPaint);

    final arcPaint = Paint()
      ..shader = const LinearGradient(
        colors: [PolarisColors.fitnessRed, PolarisColors.coral],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 11;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ActivityRingPainter oldDelegate) => oldDelegate.progress != progress;
}
