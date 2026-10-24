import 'package:flutter_test/flutter_test.dart';
import 'package:learno/app/learno_app.dart';
import 'package:learno/features/home/data/datasources/home_local_datasource.dart';
import 'package:learno/features/home/data/repositories/home_repository_impl.dart';
import 'package:learno/features/home/domain/usecases/get_home_journeys.dart';
import 'package:learno/features/home/presentation/bloc/home_bloc.dart';
import 'package:learno/features/home/presentation/screens/home_screen.dart';

void main() {
  group('HomeScreen & LearnoApp', () {
    testWidgets('LearnoApp mounts and renders HomeScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const LearnoApp());
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });

  group('HomeBloc', () {
    test('initial state is HomeInitial', () {
      final bloc = HomeBloc(
        getHomeJourneys: const GetHomeJourneys(
          HomeRepositoryImpl(dataSource: HomeMockDataSource()),
        ),
      );
      expect(bloc.state, equals(const HomeInitial()));
      bloc.close();
    });

    test('emits [HomeLoading, HomeLoaded] upon HomeLoadRequested', () async {
      final bloc = HomeBloc(
        getHomeJourneys: const GetHomeJourneys(
          HomeRepositoryImpl(dataSource: HomeMockDataSource()),
        ),
      );

      final expectedStates = [const HomeLoading(), isA<HomeLoaded>()];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const HomeLoadRequested());

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await bloc.close();
    });
  });
}
