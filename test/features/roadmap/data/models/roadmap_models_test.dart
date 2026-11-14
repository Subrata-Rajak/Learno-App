import 'package:flutter_test/flutter_test.dart';
import 'package:learno/features/roadmap/data/models/learning_goal_model.dart';
import 'package:learno/features/roadmap/data/models/roadmap_model.dart';
import 'package:learno/features/roadmap/data/models/roadmap_progress_model.dart';
import 'package:learno/features/roadmap/data/models/roadmap_topic_model.dart';
import 'package:learno/features/roadmap/data/models/topic_resource_model.dart';

void main() {
  group('LearningGoalModel', () {
    test('deserializes complete JSON correctly', () {
      final json = {
        'id': 'goal-1',
        'userId': 'user-1',
        'title': 'Learn Flutter',
        'subject': 'Mobile Development',
        'description': 'Master clean architecture',
        'currentLevel': 'BEGINNER',
        'targetOutcome': 'Build production apps',
        'status': 'ACTIVE',
        'createdAt': '2026-11-14T10:00:00.000Z',
        'updatedAt': '2026-11-14T10:00:00.000Z',
      };

      final model = LearningGoalModel.fromJson(json);

      expect(model.id, equals('goal-1'));
      expect(model.userId, equals('user-1'));
      expect(model.title, equals('Learn Flutter'));
      expect(model.subject, equals('Mobile Development'));
      expect(model.description, equals('Master clean architecture'));
      expect(model.currentLevel, equals('BEGINNER'));
      expect(model.targetOutcome, equals('Build production apps'));
      expect(model.status, equals('ACTIVE'));
      expect(model.createdAt, equals(DateTime.parse('2026-11-14T10:00:00.000Z')));
      expect(model.updatedAt, equals(DateTime.parse('2026-11-14T10:00:00.000Z')));

      final serialized = model.toJson();
      expect(serialized['id'], equals('goal-1'));
      expect(serialized['targetOutcome'], equals('Build production apps'));
    });

    test('handles nullable targetOutcome', () {
      final json = {
        'id': 'goal-2',
        'userId': 'user-1',
        'title': 'Learn Dart',
        'subject': 'Programming',
        'description': 'Language fundamentals',
        'currentLevel': 'INTERMEDIATE',
        'targetOutcome': null,
        'status': 'ACTIVE',
        'createdAt': '2026-11-14T10:00:00.000Z',
        'updatedAt': '2026-11-14T10:00:00.000Z',
      };

      final model = LearningGoalModel.fromJson(json);

      expect(model.id, equals('goal-2'));
      expect(model.targetOutcome, isNull);
      expect(model.toJson().containsKey('targetOutcome'), isFalse);
    });
  });

  group('RoadmapTopicModel', () {
    test('deserializes completed topic correctly', () {
      final json = {
        'id': 'topic-1',
        'roadmapId': 'roadmap-1',
        'title': 'Dart OOP',
        'description': 'Classes and mixins',
        'sequence': 1,
        'completedAt': '2026-11-14T10:30:00.000Z',
        'createdAt': '2026-11-14T10:00:00.000Z',
        'updatedAt': '2026-11-14T10:30:00.000Z',
      };

      final model = RoadmapTopicModel.fromJson(json);

      expect(model.id, equals('topic-1'));
      expect(model.sequence, equals(1));
      expect(model.isCompleted, isTrue);
      expect(model.completedAt, equals(DateTime.parse('2026-11-14T10:30:00.000Z')));

      final serialized = model.toJson();
      expect(serialized['completedAt'], equals('2026-11-14T10:30:00.000Z'));
    });

    test('deserializes uncompleted topic with null completedAt', () {
      final json = {
        'id': 'topic-2',
        'roadmapId': 'roadmap-1',
        'title': 'Async Dart',
        'description': 'Futures and Streams',
        'sequence': 2,
        'completedAt': null,
        'createdAt': '2026-11-14T10:00:00.000Z',
        'updatedAt': '2026-11-14T10:00:00.000Z',
      };

      final model = RoadmapTopicModel.fromJson(json);

      expect(model.id, equals('topic-2'));
      expect(model.sequence, equals(2));
      expect(model.isCompleted, isFalse);
      expect(model.completedAt, isNull);
      expect(model.toJson().containsKey('completedAt'), isFalse);
    });
  });

  group('RoadmapModel', () {
    test('deserializes roadmap and sorts nested topics by sequence', () {
      final json = {
        'id': 'roadmap-1',
        'learningGoalId': 'goal-1',
        'title': 'Flutter Mastery',
        'description': 'Roadmap from beginner to pro',
        'status': 'ACTIVE',
        'createdAt': '2026-11-14T10:00:00.000Z',
        'updatedAt': '2026-11-14T10:00:00.000Z',
        'topics': [
          {
            'id': 'topic-2',
            'roadmapId': 'roadmap-1',
            'title': 'State Management',
            'description': 'BLoC pattern',
            'sequence': 2,
            'completedAt': null,
            'createdAt': '2026-11-14T10:00:00.000Z',
            'updatedAt': '2026-11-14T10:00:00.000Z',
          },
          {
            'id': 'topic-1',
            'roadmapId': 'roadmap-1',
            'title': 'Dart Basics',
            'description': 'Variables and types',
            'sequence': 1,
            'completedAt': '2026-11-14T10:15:00.000Z',
            'createdAt': '2026-11-14T10:00:00.000Z',
            'updatedAt': '2026-11-14T10:15:00.000Z',
          },
        ],
      };

      final model = RoadmapModel.fromJson(json);

      expect(model.id, equals('roadmap-1'));
      expect(model.topics.length, equals(2));
      // Verify sequence sort
      expect(model.topics[0].sequence, equals(1));
      expect(model.topics[0].title, equals('Dart Basics'));
      expect(model.topics[1].sequence, equals(2));
      expect(model.topics[1].title, equals('State Management'));

      // Verify domain helpers
      expect(model.totalTopics, equals(2));
      expect(model.completedTopics, equals(1));
      expect(model.progressPercentage, equals(0.5));
    });

    test('handles empty topics list gracefully', () {
      final json = {
        'id': 'roadmap-2',
        'learningGoalId': 'goal-2',
        'title': 'Empty Roadmap',
        'description': 'No topics yet',
        'status': 'ACTIVE',
        'createdAt': '2026-11-14T10:00:00.000Z',
        'updatedAt': '2026-11-14T10:00:00.000Z',
        'topics': null,
      };

      final model = RoadmapModel.fromJson(json);

      expect(model.topics, isEmpty);
      expect(model.totalTopics, equals(0));
      expect(model.completedTopics, equals(0));
      expect(model.progressPercentage, equals(0.0));
    });
  });

  group('RoadmapProgressModel', () {
    test('deserializes progress with nextTopic and lastCompletedTopic', () {
      final json = {
        'roadmapId': 'roadmap-1',
        'totalTopics': 5,
        'completedTopics': 2,
        'percentage': 40,
        'isCompleted': false,
        'nextTopic': {
          'id': 'topic-3',
          'title': 'Clean Architecture',
          'sequence': 3,
        },
        'lastCompletedTopic': {
          'id': 'topic-2',
          'title': 'BLoC',
          'sequence': 2,
          'completedAt': '2026-11-14T10:20:00.000Z',
        },
      };

      final model = RoadmapProgressModel.fromJson(json);

      expect(model.roadmapId, equals('roadmap-1'));
      expect(model.totalTopics, equals(5));
      expect(model.completedTopics, equals(2));
      expect(model.percentage, equals(40));
      expect(model.isCompleted, isFalse);
      expect(model.nextTopic?.id, equals('topic-3'));
      expect(model.nextTopic?.sequence, equals(3));
      expect(model.lastCompletedTopic?.id, equals('topic-2'));
      expect(
        model.lastCompletedTopic?.completedAt,
        equals(DateTime.parse('2026-11-14T10:20:00.000Z')),
      );

      final serialized = model.toJson();
      expect(serialized['percentage'], equals(40));
      expect(serialized['nextTopic']['title'], equals('Clean Architecture'));
    });

    test('handles 100% completed progress with null nextTopic', () {
      final json = {
        'roadmapId': 'roadmap-1',
        'totalTopics': 3,
        'completedTopics': 3,
        'percentage': 100,
        'isCompleted': true,
        'nextTopic': null,
        'lastCompletedTopic': {
          'id': 'topic-3',
          'title': 'Deployment',
          'sequence': 3,
          'completedAt': '2026-11-14T11:00:00.000Z',
        },
      };

      final model = RoadmapProgressModel.fromJson(json);

      expect(model.isCompleted, isTrue);
      expect(model.percentage, equals(100));
      expect(model.nextTopic, isNull);
      expect(model.lastCompletedTopic?.id, equals('topic-3'));
    });
  });

  group('TopicResourceModel', () {
    test('deserializes resource correctly', () {
      final json = {
        'id': 'res-1',
        'topicId': 'topic-1',
        'title': 'Dart Language Tour',
        'url': 'https://dart.dev/language',
        'type': 'DOCUMENTATION',
        'sourceName': 'Dart.dev',
        'reason': 'Official language documentation',
        'sequence': 1,
        'createdAt': '2026-11-14T10:00:00.000Z',
        'updatedAt': '2026-11-14T10:00:00.000Z',
      };

      final model = TopicResourceModel.fromJson(json);

      expect(model.id, equals('res-1'));
      expect(model.topicId, equals('topic-1'));
      expect(model.title, equals('Dart Language Tour'));
      expect(model.url, equals('https://dart.dev/language'));
      expect(model.type, equals('DOCUMENTATION'));
      expect(model.sourceName, equals('Dart.dev'));
      expect(model.sequence, equals(1));
      expect(model.createdAt, equals(DateTime.parse('2026-11-14T10:00:00.000Z')));
    });
  });
}
