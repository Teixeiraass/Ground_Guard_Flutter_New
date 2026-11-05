import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ground_guard_app/features/controllers/data/datasources/controllers_remote_datasource.dart';
import 'package:ground_guard_app/features/controllers/data/repositories/controllers_repository_impl.dart';

class MockControllersRemoteDataSource extends Mock
    implements ControllersRemoteDataSource {}

void main() {
  late MockControllersRemoteDataSource mockDataSource;
  late ControllersRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockControllersRemoteDataSource();
    repository = ControllersRepositoryImpl(mockDataSource);
  });

  group('ControllersRepositoryImpl - Register & Claim BLE', () {
    test(
      'registerBleController deve chamar o datasource e retornar o modelo',
      () async {
        final mockResponse = {
          'id': 'c4d3d55f-7a7a-400f-9b51-007933470487',
          'device_uid': 'AABBCCDDEEFF',
          'name': 'ground_guard_AABBCCDDEEFF',
          'firmware_version': '1.0.0',
          'status': 'ativo',
        };

        when(
          () => mockDataSource.registerBleController(
            deviceUid: 'AABBCCDDEEFF',
            name: 'ground_guard_AABBCCDDEEFF',
            firmwareVersion: '1.0.0',
            firmwareBuild: '1',
          ),
        ).thenAnswer((_) async => mockResponse);

        final result = await repository.registerBleController(
          deviceUid: 'AABBCCDDEEFF',
          name: 'ground_guard_AABBCCDDEEFF',
          firmwareVersion: '1.0.0',
          firmwareBuild: '1',
        );

        expect(result.uuid, 'c4d3d55f-7a7a-400f-9b51-007933470487');
        expect(result.hardwareUid, 'AABBCCDDEEFF');
        expect(result.name, 'ground_guard_AABBCCDDEEFF');
        verify(
          () => mockDataSource.registerBleController(
            deviceUid: 'AABBCCDDEEFF',
            name: 'ground_guard_AABBCCDDEEFF',
            firmwareVersion: '1.0.0',
            firmwareBuild: '1',
          ),
        ).called(1);
      },
    );

    test(
      'claimController deve chamar o endpoint claim e retornar a controladora vinculada',
      () async {
        final mockResponse = {
          'id': 'c4d3d55f-7a7a-400f-9b51-007933470487',
          'device_uid': 'AABBCCDDEEFF',
          'name': 'ground_guard_AABBCCDDEEFF',
          'status': 'ativo',
        };

        when(
          () => mockDataSource.claimController('AABBCCDDEEFF'),
        ).thenAnswer((_) async => mockResponse);

        final result = await repository.claimController('AABBCCDDEEFF');

        expect(result.uuid, 'c4d3d55f-7a7a-400f-9b51-007933470487');
        verify(() => mockDataSource.claimController('AABBCCDDEEFF')).called(1);
      },
    );

    test(
      'claimController deve tratar erro 409 quando a controladora já estiver vinculada a outro usuário',
      () async {
        final dioException = DioException(
          requestOptions: RequestOptions(
            path: '/controller-devices/claim/AABBCCDDEEFF',
          ),
          response: Response(
            requestOptions: RequestOptions(
              path: '/controller-devices/claim/AABBCCDDEEFF',
            ),
            statusCode: 409,
          ),
        );

        when(
          () => mockDataSource.claimController('AABBCCDDEEFF'),
        ).thenThrow(dioException);

        expect(
          () => repository.claimController('AABBCCDDEEFF'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Controladora já vinculada a outro usuário'),
            ),
          ),
        );
      },
    );
  });
}
