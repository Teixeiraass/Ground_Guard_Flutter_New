import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ground_guard_app/features/weather/data/datasources/weather_remote_datasource.dart';

class MockDio extends Mock implements Dio {}

Response<dynamic> ok(String path, Map<String, dynamic> data) => Response(
  requestOptions: RequestOptions(path: path),
  statusCode: 200,
  data: data,
);

void main() {
  late MockDio dio;
  late WeatherRemoteDataSourceImpl dataSource;

  setUp(() {
    dio = MockDio();
    dataSource = WeatherRemoteDataSourceImpl(dio);
  });

  test(
    'current weather comes from the backend proxy, never OpenWeather',
    () async {
      when(
        () =>
            dio.get('/weather/current', queryParameters: {'city': 'Campinas'}),
      ).thenAnswer(
        (_) async => ok('/weather/current', {
          'name': 'Campinas',
          'main': {'temp': 25.0},
        }),
      );

      final data = await dataSource.getWeatherData('Campinas');

      expect(data['name'], 'Campinas');
      final captured = verify(
        () => dio.get(
          captureAny(),
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      ).captured;
      expect(captured[0], '/weather/current');
      expect((captured[1] as Map).containsKey('appid'), isFalse);
    },
  );

  test('forecast comes from the backend proxy', () async {
    when(
      () => dio.get('/weather/forecast', queryParameters: {'city': 'Campinas'}),
    ).thenAnswer((_) async => ok('/weather/forecast', {'list': []}));

    final data = await dataSource.getForecastData('Campinas');

    expect(data['list'], isEmpty);
  });

  test('backend errors propagate to the repository', () async {
    when(
      () => dio.get(any(), queryParameters: any(named: 'queryParameters')),
    ).thenThrow(
      DioException(requestOptions: RequestOptions(path: '/weather/current')),
    );

    expect(dataSource.getWeatherData('X'), throwsA(isA<DioException>()));
  });
}
