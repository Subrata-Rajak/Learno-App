import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:learno/core/network/api_client.dart';
import 'package:learno/core/network/api_endpoints.dart';
import 'package:learno/core/network/errors/app_exception.dart';
import 'package:learno/core/network/errors/error_handler.dart';
import 'package:learno/core/network/models/api_response.dart';
import 'package:learno/features/chat/data/datasources/sse/sse_event.dart';
import 'package:learno/features/chat/data/datasources/sse/sse_transformer.dart';
import 'package:learno/features/chat/data/models/capability_model.dart';
import 'package:learno/features/chat/data/models/conversation_message_model.dart';
import 'package:learno/features/chat/data/models/conversation_model.dart';

/// Contract for remote operations with the Learno conversation & chat backend.
abstract interface class ChatRemoteDataSource {
  /// Fetches system conversational capabilities (e.g., LEARN_TOPIC).
  Future<List<CapabilityModel>> getCapabilities();

  /// Creates a new conversation session for a given capability.
  Future<ConversationModel> createConversation({required String capabilityId});

  /// Retrieves a specific conversation by ID.
  Future<ConversationModel> getConversation({required String conversationId});

  /// Lists all conversations belonging to the authenticated user.
  Future<List<ConversationModel>> getConversations();

  /// Retrieves ordered message history for a conversation.
  Future<List<ConversationMessageModel>> getConversationMessages({
    required String conversationId,
  });

  /// Initiates an SSE chat generation stream.
  Stream<SseEvent> streamChat({
    required String conversationId,
    required String content,
    CancelToken? cancelToken,
  });
}

/// Production implementation of [ChatRemoteDataSource] using [ApiClient] and [Dio].
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  const ChatRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<List<CapabilityModel>> getCapabilities() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.capabilities,
    );

    final envelope = ApiResponse<List<CapabilityModel>>.fromJson(
      response.data ?? {},
      (json) => (json as List<dynamic>)
          .map((item) => CapabilityModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );

    if (!envelope.success || envelope.data == null) {
      throw ServerException(
        message: envelope.message.isNotEmpty
            ? envelope.message
            : 'Failed to retrieve capabilities.',
        errorCode: envelope.error?.code,
        details: envelope.error?.details,
      );
    }

    return envelope.data!;
  }

  @override
  Future<ConversationModel> createConversation({
    required String capabilityId,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.conversations,
      data: {'capabilityId': capabilityId},
    );

    final envelope = ApiResponse<ConversationModel>.fromJson(
      response.data ?? {},
      (json) => ConversationModel.fromJson(json as Map<String, dynamic>),
    );

    if (!envelope.success || envelope.data == null) {
      throw ServerException(
        message: envelope.message.isNotEmpty
            ? envelope.message
            : 'Failed to create conversation.',
        errorCode: envelope.error?.code,
        details: envelope.error?.details,
      );
    }

    return envelope.data!;
  }

  @override
  Future<ConversationModel> getConversation({
    required String conversationId,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.conversationDetails(conversationId),
    );

    final envelope = ApiResponse<ConversationModel>.fromJson(
      response.data ?? {},
      (json) => ConversationModel.fromJson(json as Map<String, dynamic>),
    );

    if (!envelope.success || envelope.data == null) {
      throw ServerException(
        message: envelope.message.isNotEmpty
            ? envelope.message
            : 'Failed to retrieve conversation.',
        errorCode: envelope.error?.code,
        details: envelope.error?.details,
      );
    }

    return envelope.data!;
  }

  @override
  Future<List<ConversationModel>> getConversations() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.conversations,
    );

    final envelope = ApiResponse<List<ConversationModel>>.fromJson(
      response.data ?? {},
      (json) => (json as List<dynamic>)
          .map(
            (item) => ConversationModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );

    if (!envelope.success || envelope.data == null) {
      throw ServerException(
        message: envelope.message.isNotEmpty
            ? envelope.message
            : 'Failed to retrieve conversations.',
        errorCode: envelope.error?.code,
        details: envelope.error?.details,
      );
    }

    return envelope.data!;
  }

  @override
  Future<List<ConversationMessageModel>> getConversationMessages({
    required String conversationId,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.conversationMessages(conversationId),
    );

    final envelope = ApiResponse<List<ConversationMessageModel>>.fromJson(
      response.data ?? {},
      (json) => (json as List<dynamic>)
          .map(
            (item) =>
                ConversationMessageModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );

    if (!envelope.success || envelope.data == null) {
      throw ServerException(
        message: envelope.message.isNotEmpty
            ? envelope.message
            : 'Failed to retrieve conversation messages.',
        errorCode: envelope.error?.code,
        details: envelope.error?.details,
      );
    }

    return envelope.data!;
  }

  @override
  Stream<SseEvent> streamChat({
    required String conversationId,
    required String content,
    CancelToken? cancelToken,
  }) async* {
    final Response<ResponseBody> response;
    try {
      response = await apiClient.dio.post<ResponseBody>(
        ApiEndpoints.conversationChat(conversationId),
        data: {'content': content},
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream'},
          receiveTimeout: Duration.zero,
        ),
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      if (e.response?.data is ResponseBody) {
        try {
          final body = e.response!.data as ResponseBody;
          final bytes = await body.stream.fold<List<int>>(
            <int>[],
            (acc, chunk) => acc..addAll(chunk),
          );
          final text = utf8.decode(bytes);
          final decoded = jsonDecode(text);
          if (decoded is Map<String, dynamic>) {
            final enrichedException = DioException(
              requestOptions: e.requestOptions,
              response: Response(
                requestOptions: e.requestOptions,
                data: decoded,
                statusCode: e.response?.statusCode,
                statusMessage: e.response?.statusMessage,
                headers: e.response?.headers,
                isRedirect: e.response?.isRedirect ?? false,
                redirects: e.response?.redirects ?? [],
                extra: e.response?.extra ?? {},
              ),
              type: e.type,
              error: e.error,
              stackTrace: e.stackTrace,
              message: e.message,
            );
            throw ErrorHandler.handle(enrichedException);
          }
        } catch (inner) {
          if (inner is AppException) {
            rethrow;
          }
        }
      }
      throw ErrorHandler.handle(e);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }

    final responseBody = response.data;
    if (responseBody == null) {
      throw const ServerException(
        message: 'Empty response stream received from chat service.',
        errorCode: 'EMPTY_STREAM',
      );
    }

    bool receivedTerminalEvent = false;

    try {
      await for (final sseEvent in responseBody.stream.transform(
        const SseTransformer(),
      )) {
        if (sseEvent.event == 'complete' || sseEvent.event == 'error') {
          receivedTerminalEvent = true;
        }
        yield sseEvent;
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ErrorHandler.handle(e);
    }

    if (!receivedTerminalEvent) {
      throw const ServerException(
        message:
            'Chat stream closed prematurely without a terminal completion event.',
        errorCode: 'STREAM_PREMATURE_TERMINATION',
      );
    }
  }
}
