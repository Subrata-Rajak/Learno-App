/// Centralized API endpoint route definitions.
abstract final class ApiEndpoints {
  // Base API path
  static const String apiVersion = '/api/v1';

  // System
  static const String health = '/health';

  // Authentication
  static const String authRegister = '$apiVersion/auth/register';
  static const String authLogin = '$apiVersion/auth/login';
  static const String authRefresh = '$apiVersion/auth/refresh';
  static const String authLogout = '$apiVersion/auth/logout';
  static const String authMe = '$apiVersion/auth/me';

  // Conversations & Chat
  static const String conversations = '$apiVersion/conversation';
  static String conversationMessages(String conversationId) =>
      '$apiVersion/conversation/$conversationId/messages';
  static String conversationChat(String conversationId) =>
      '$apiVersion/conversation/$conversationId/chat';

  // Capabilities
  static const String capabilities = '$apiVersion/capability';

  // Learning Goals
  static const String learningGoals = '$apiVersion/learning-goals';

  // Roadmaps & Topics
  static const String roadmaps = '$apiVersion/roadmap';
  static String roadmapDetails(String roadmapId) =>
      '$apiVersion/roadmap/$roadmapId';
  static String topicResources({
    required String roadmapId,
    required String topicId,
  }) => '$apiVersion/roadmap/$roadmapId/topics/$topicId/resources';
}
