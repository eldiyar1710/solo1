import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/scheduler.dart';
import 'package:solo1/features/preauth/pre_learning/data/datasource/learning_local_datasource.dart';
import 'package:solo1/features/preauth/pre_learning/data/repository/learning_repository_impl.dart';
import 'package:solo1/features/preauth/pre_learning/domain/repository/learning_repository.dart';
import 'package:solo1/features/preauth/pre_learning/domain/usecases/save_test_result.dart';

class LearningTestState {
  final bool isTesting;
  final int currentQuestion;
  final double score;
  final bool testPassed;
  const LearningTestState({this.isTesting = false, this.currentQuestion = 1, this.score = 0.0, this.testPassed = false});

  LearningTestState copyWith({bool? isTesting, int? currentQuestion, double? score, bool? testPassed}) => LearningTestState(
        isTesting: isTesting ?? this.isTesting,
        currentQuestion: currentQuestion ?? this.currentQuestion,
        score: score ?? this.score,
        testPassed: testPassed ?? this.testPassed,
      );
}

class LearningTestController extends StateNotifier<LearningTestState> {
  final SaveTestResult saveTestResult;
  final LearningRepository repo;
  List<Map<String, dynamic>> questions = const [
    {'q': 'Какой минимальный порог успешного прохождения теста?', 'a': '80 %', 'options': ['70 %', '80 %', '90 %', '100 %']},
    {'q': 'Что не является этапом работы агента?', 'a': 'Покупка автомобиля', 'options': ['Поиск клиента', 'Установка терминала', 'Покупка автомобиля', 'Получение комиссии']},
    {'q': 'Сколько месяцев длится период выплат?', 'a': '36', 'options': ['12', '24', '36', '48']},
    {'q': 'Какой размер комиссии в демо-калькуляторе?', 'a': '10%', 'options': ['5%', '8%', '10%', '12%']},
    {'q': 'Что нужно сделать перед продажей?', 'a': 'Пройти обучение', 'options': ['Ничего', 'Пройти обучение', 'Купить терминал', 'Поменять никнейм']},
    {'q': 'Куда отправляются данные клиента?', 'a': 'Администратору', 'options': ['Клиенту', 'Администратору', 'Модератору', 'В чат']},
    {'q': 'Что подтверждает модератор?', 'a': 'Личность и возраст', 'options': ['Личность и возраст', 'Никнейм', 'Почту', 'Баланс']},
    {'q': 'Какой минимум баллов нужен?', 'a': '80', 'options': ['50', '60', '70', '80']},
    {'q': 'Что такое уникальный код?', 'a': 'Идентификатор агента', 'options': ['Номер карты', 'Идентификатор агента', 'Лицензия', 'Пароль']},
    {'q': 'Где отобразится ваш уникальный номер?', 'a': 'В профиле', 'options': ['На главной', 'В профиле', 'В калькуляторе', 'В видео']},
  ];

  LearningTestController(this.saveTestResult, this.repo) : super(const LearningTestState()) {
    Future(() async {
      await repo.load();
      final last = repo.last;
      if (last != null) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          state = LearningTestState(isTesting: false, currentQuestion: 10, score: last.score, testPassed: last.passed);
        });
      }
    });
  }

  void startTesting() => state = const LearningTestState(isTesting: true, currentQuestion: 1, score: 0.0, testPassed: false);

  void startTestingWith(List<Map<String, dynamic>> qs) {
    questions = qs;
    startTesting();
  }

  void cancelTesting() => state = const LearningTestState(isTesting: false, currentQuestion: 1, score: 0.0, testPassed: false);

  void finishTesting() {
    final passed = state.score >= 80;
    saveTestResult(state.score, passed);
    state = LearningTestState(isTesting: false, currentQuestion: state.currentQuestion, score: state.score, testPassed: passed);
  }

  void answerQuestion(String selected) {
    final idx = state.currentQuestion - 1;
    var score = state.score;
    if (idx >= 0 && idx < questions.length) {
      if (questions[idx]['a'] == selected) {
        score += (100 / questions.length);
      }
    }
    if (state.currentQuestion < questions.length) {
      state = state.copyWith(currentQuestion: state.currentQuestion + 1, score: score);
    } else {
      final passed = score >= 80;
      saveTestResult(score, passed);
      state = LearningTestState(isTesting: false, currentQuestion: state.currentQuestion, score: score, testPassed: passed);
    }
  }
}

final learningTestProvider = StateNotifierProvider<LearningTestController, LearningTestState>((ref) {
  final repo = LearningRepositoryImpl(LearningLocalDataSource());
  final usecase = SaveTestResult(repo);
  return LearningTestController(usecase, repo);
});

class LearningCalcState {
  final int terminalCount;
  const LearningCalcState({this.terminalCount = 1});
  LearningCalcState copyWith({int? terminalCount}) => LearningCalcState(terminalCount: terminalCount ?? this.terminalCount);
}

class LearningCalcController extends StateNotifier<LearningCalcState> {
  LearningCalcController() : super(const LearningCalcState());
  void setTerminalCount(int count) => state = state.copyWith(terminalCount: count);
}

final learningCalcProvider = StateNotifierProvider<LearningCalcController, LearningCalcState>((ref) => LearningCalcController());