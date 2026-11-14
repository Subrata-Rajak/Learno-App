import 'package:learno/core/network/api_client.dart';
import 'package:learno/core/network/api_endpoints.dart';
import 'package:learno/core/network/errors/app_exception.dart';
import 'package:learno/core/network/models/api_response.dart';
import 'package:learno/features/roadmap/data/models/learning_goal_model.dart';
import 'package:learno/features/roadmap/data/models/roadmap_model.dart';
import 'package:learno/features/roadmap/data/models/roadmap_progress_model.dart';
import 'package:learno/features/roadmap/data/models/roadmap_topic_model.dart';
import 'package:learno/features/roadmap/data/models/topic_resource_model.dart';

/// Contract for remote operations with the Learno roadmap & learning goals backend.
abstract interface class RoadmapRemoteDataSource {
  /// Fetches a roadmap and its topics by roadmap ID.
  Future<RoadmapModel> getRoadmap(String roadmapId);

  /// Fetches a roadmap and its topics by learning goal ID.
  Future<RoadmapModel> getRoadmapByGoal(String learningGoalId);

  /// Retrieves aggregate progress metrics for a roadmap.
  Future<RoadmapProgressModel> getRoadmapProgress(String roadmapId);

  /// Marks a specific topic completed.
  Future<RoadmapTopicModel> completeTopic(String topicId);

  /// Fetches learning resources for a topic.
  Future<List<TopicResourceModel>> getTopicResources(String topicId);

  /// Retrieves active learning goals for the user.
  Future<List<LearningGoalModel>> getActiveLearningGoals();
}

/// Production implementation of [RoadmapRemoteDataSource] using [ApiClient].
class RoadmapRemoteDataSourceImpl implements RoadmapRemoteDataSource {
  const RoadmapRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<RoadmapModel> getRoadmap(String roadmapId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.roadmapDetails(roadmapId),
    );

    final envelope = ApiResponse<RoadmapModel>.fromJson(
      response.data ?? {},
      (json) => RoadmapModel.fromJson(json as Map<String, dynamic>),
    );

    if (!envelope.success || envelope.data == null) {
      throw ServerException(
        message: envelope.message.isNotEmpty
            ? envelope.message
            : 'Failed to retrieve roadmap.',
        errorCode: envelope.error?.code,
        details: envelope.error?.details,
      );
    }

    return envelope.data!;
  }

  @override
  Future<RoadmapModel> getRoadmapByGoal(String learningGoalId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.roadmapByGoal(learningGoalId),
    );

    final envelope = ApiResponse<RoadmapModel>.fromJson(
      response.data ?? {},
      (json) => RoadmapModel.fromJson(json as Map<String, dynamic>),
    );

    if (!envelope.success || envelope.data == null) {
      throw ServerException(
        message: envelope.message.isNotEmpty
            ? envelope.message
            : 'Failed to retrieve roadmap by learning goal.',
        errorCode: envelope.error?.code,
        details: envelope.error?.details,
      );
    }

    return envelope.data!;
  }

  @override
  Future<RoadmapProgressModel> getRoadmapProgress(String roadmapId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.roadmapProgress(roadmapId),
    );

    final envelope = ApiResponse<RoadmapProgressModel>.fromJson(
      response.data ?? {},
      (json) => RoadmapProgressModel.fromJson(json as Map<String, dynamic>),
    );

    if (!envelope.success || envelope.data == null) {
      throw ServerException(
        message: envelope.message.isNotEmpty
            ? envelope.message
            : 'Failed to retrieve roadmap progress.',
        errorCode: envelope.error?.code,
        details: envelope.error?.details,
      );
    }

    return envelope.data!;
  }

  @override
  Future<RoadmapTopicModel> completeTopic(String topicId) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.topicComplete(topicId),
      data: {},
    );

    final envelope = ApiResponse<RoadmapTopicModel>.fromJson(
      response.data ?? {},
      (json) => RoadmapTopicModel.fromJson(json as Map<String, dynamic>),
    );

    if (!envelope.success || envelope.data == null) {
      throw ServerException(
        message: envelope.message.isNotEmpty
            ? envelope.message
            : 'Failed to mark topic as completed.',
        errorCode: envelope.error?.code,
        details: envelope.error?.details,
      );
    }

    return envelope.data!;
  }

  @override
  Future<List<TopicResourceModel>> getTopicResources(String topicId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.topicResources(topicId),
    );

    final envelope = ApiResponse<List<TopicResourceModel>>.fromJson(
      response.data ?? {},
      (json) => (json as List<dynamic>)
          .map(
            (item) => TopicResourceModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );

    if (!envelope.success || envelope.data == null) {
      throw ServerException(
        message: envelope.message.isNotEmpty
            ? envelope.message
            : 'Failed to retrieve topic resources.',
        errorCode: envelope.error?.code,
        details: envelope.error?.details,
      );
    }

    return envelope.data!;
  }

  @override
  Future<List<LearningGoalModel>> getActiveLearningGoals() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.learningGoals,
    );

    final envelope = ApiResponse<List<LearningGoalModel>>.fromJson(
      response.data ?? {},
      (json) => (json as List<dynamic>)
          .map(
            (item) => LearningGoalModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );

    if (!envelope.success || envelope.data == null) {
      throw ServerException(
        message: envelope.message.isNotEmpty
            ? envelope.message
            : 'Failed to retrieve learning goals.',
        errorCode: envelope.error?.code,
        details: envelope.error?.details,
      );
    }

    return envelope.data!;
  }
}
