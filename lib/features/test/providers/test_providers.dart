import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/models.dart';

// Test Question Types
enum TestQuestionType { all, descriptive, practical, mcq }

extension TestQuestionTypeLabel on TestQuestionType {
  String get label => switch (this) {
        TestQuestionType.all => 'All Types',
        TestQuestionType.descriptive => 'Descriptive',
        TestQuestionType.practical => 'Practical',
        TestQuestionType.mcq => 'MCQ',
      };
}

// Timer Mode
enum TimerMode { perQuestion, totalTime }

class TestConfig {
  const TestConfig({
    required this.subjectId,
    required this.subjectName,
    required this.selectedChapterIds,
    required this.questionCount,
    required this.timerEnabled,
    required this.timerMode,
    required this.timeValue,
    required this.questionType,
  });

  final String subjectId;
  final String subjectName;
  final List<String> selectedChapterIds;
  final int? questionCount; // null means 'All'
  final bool timerEnabled;
  final TimerMode timerMode;
  final double timeValue;
  final TestQuestionType questionType;

  int calculateTotalTimeInSeconds(int actualQuestionCount) {
    if (!timerEnabled) return 0;
    if (timerMode == TimerMode.totalTime) {
      return (timeValue * 60).round();
    } else {
      return (timeValue * 60 * actualQuestionCount).round();
    }
  }
}

final activeTestConfigProvider = StateProvider<TestConfig?>((ref) => null);

// Session State
class TestSessionState {
  const TestSessionState({
    this.questions = const [],
    this.currentIndex = 0,
    this.answers = const {},
    this.flaggedQuestions = const {},
    this.isSubmitted = false,
  });

  final List<QuestionModel> questions;
  final int currentIndex;
  final Map<String, dynamic> answers; 
  final Set<String> flaggedQuestions;
  final bool isSubmitted;

  TestSessionState copyWith({
    List<QuestionModel>? questions,
    int? currentIndex,
    Map<String, dynamic>? answers,
    Set<String>? flaggedQuestions,
    bool? isSubmitted,
  }) =>
      TestSessionState(
        questions: questions ?? this.questions,
        currentIndex: currentIndex ?? this.currentIndex,
        answers: answers ?? this.answers,
        flaggedQuestions: flaggedQuestions ?? this.flaggedQuestions,
        isSubmitted: isSubmitted ?? this.isSubmitted,
      );

  QuestionModel? get currentQuestion =>
      questions.isEmpty ? null : questions[currentIndex];
      
  bool get isLastQuestion => currentIndex == questions.length - 1;
}

class TestSessionNotifier extends StateNotifier<TestSessionState> {
  TestSessionNotifier() : super(const TestSessionState());

  void loadQuestions(List<QuestionModel> questions) {
    state = TestSessionState(questions: questions);
  }

  void updateAnswer(String questionId, dynamic answer) {
    final newAnswers = Map<String, dynamic>.from(state.answers);
    newAnswers[questionId] = answer;
    state = state.copyWith(answers: newAnswers);
  }

  void toggleFlag(String questionId) {
    final newFlags = Set<String>.from(state.flaggedQuestions);
    if (newFlags.contains(questionId)) {
      newFlags.remove(questionId);
    } else {
      newFlags.add(questionId);
    }
    state = state.copyWith(flaggedQuestions: newFlags);
  }

  void goToNext() {
    if (state.currentIndex < state.questions.length - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void goToPrev() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  void goToIndex(int index) {
    if (index >= 0 && index < state.questions.length) {
      state = state.copyWith(currentIndex: index);
    }
  }

  void submitTest() {
    state = state.copyWith(isSubmitted: true);
  }
}

final testSessionProvider =
    StateNotifierProvider.autoDispose<TestSessionNotifier, TestSessionState>((ref) {
  return TestSessionNotifier();
});

class TestTimerNotifier extends StateNotifier<int> {
  TestTimerNotifier() : super(0);
  Timer? _timer;

  void start(int seconds, VoidCallback onTimeUp) {
    state = seconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state > 0) {
        state = state - 1;
      } else {
        timer.cancel();
        onTimeUp();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final testTimerProvider = StateNotifierProvider.autoDispose<TestTimerNotifier, int>((ref) {
  return TestTimerNotifier();
});
