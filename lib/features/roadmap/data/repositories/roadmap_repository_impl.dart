import 'package:learno/core/network/errors/app_exception.dart';
import 'package:learno/core/network/errors/error_handler.dart';
import 'package:learno/features/roadmap/data/datasources/roadmap_remote_data_source.dart';
import 'package:learno/features/roadmap/domain/entities/learning_goal.dart';
import 'package:learno/features/roadmap/domain/entities/roadmap.dart';
import 'package:learno/features/roadmap/domain/entities/roadmap_progress.dart';
import 'package:learno/features/roadmap/domain/entities/roadmap_topic.dart';
import 'package:learno/features/roadmap/domain/entities/topic_resource.dart';
import 'package:learno/features/roadmap/domain/repositories/roadmap_repository.dart';

/// Implementation of [RoadmapRepository] using [RoadmapRemoteDataSource].
class RoadmapRepositoryImpl implements RoadmapRepository {
  const RoadmapRepositoryImpl({required this.remoteDataSource});

  final RoadmapRemoteDataSource remoteDataSource;

  @override
  Future<Roadmap> getRoadmap(String roadmapId) async {
    try {
      final model = await remoteDataSource.getRoadmap(roadmapId);
      return model;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<Roadmap> getRoadmapByGoal(String learningGoalId) async {
    try {
      final model = await remoteDataSource.getRoadmapByGoal(learningGoalId);
      return model;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<RoadmapProgress> getRoadmapProgress(String roadmapId) async {
    try {
      final model = await remoteDataSource.getRoadmapProgress(roadmapId);
      return model;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<RoadmapTopic> completeTopic(String topicId) async {
    try {
      final model = await remoteDataSource.completeTopic(topicId);
      return model;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<List<TopicResource>> getTopicResources(String topicId) async {
    try {
      final models = await remoteDataSource.getTopicResources(topicId);
      return models;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<List<LearningGoal>> getActiveLearningGoals() async {
    try {
      final models = await remoteDataSource.getActiveLearningGoals();
      return models;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ErrorHandler.handle(e);
    }
  }
}
