import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ground_guard_app/features/devices/data/datasources/devices_remote_datasource.dart';
import 'package:ground_guard_app/features/devices/data/repositories/devices_repository_impl.dart';
import 'package:ground_guard_app/features/devices/data/models/device_model.dart';

class MockDevicesRemoteDataSource extends Mock
    implements DevicesRemoteDataSource {}

class MockDio extends Mock implements Dio {}

void main() {
  late MockDevicesRemoteDataSource mockDataSource;
  late DevicesRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockDevicesRemoteDataSource();
    repository = DevicesRepositoryImpl(mockDataSource);
  });

  group('DevicesRepositoryImpl - Link Device Tests', () {
    const tQrToken = '6144999d2f954c36d5adf8d0';
    const tControllerUuid = 'dd096b01-cd70-4dde-acb9-fedb9e15f492';

    test(
      'linkDevice deve chamar o datasource passando qrToken e controllerUuid em queryParameters',
      () async {
        when(
          () => mockDataSource.linkDevice(
            qrToken: tQrToken,
            controllerUuid: tControllerUuid,
          ),
        ).thenAnswer(
          (_) async => {
            'uuid': '30a8360a-abdc-4b42-81df-1eb904f16415',
            'device_uid': 'DEVICE001',
            'name': 'Sensor',
          },
        );

        await repository.linkDevice(
          qrToken: tQrToken,
          controllerUuid: tControllerUuid,
        );

        verify(
          () => mockDataSource.linkDevice(
            qrToken: tQrToken,
            controllerUuid: tControllerUuid,
          ),
        ).called(1);
      },
    );

    test(
      'linkDevice deve tratar erro HTTP 400 com mensagem invalid UUID length: 0',
      () async {
        final dioException = DioException(
          requestOptions: RequestOptions(
            path: '/devices/link/$tQrToken',
            queryParameters: {'controller_uuid': tControllerUuid},
          ),
          response: Response(
            requestOptions: RequestOptions(
              path: '/devices/link/$tQrToken',
              queryParameters: {'controller_uuid': tControllerUuid},
            ),
            statusCode: 400,
            data: {'error': 'invalid UUID length: 0'},
          ),
        );

        when(
          () => mockDataSource.linkDevice(
            qrToken: tQrToken,
            controllerUuid: tControllerUuid,
          ),
        ).thenThrow(dioException);

        expect(
          () => repository.linkDevice(
            qrToken: tQrToken,
            controllerUuid: tControllerUuid,
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('invalid UUID length: 0'),
            ),
          ),
        );
      },
    );
  });

  group('DevicesRemoteDataSourceImpl - Listar Devices (GET /devices)', () {
    late MockDio mockDio;
    late DevicesRemoteDataSourceImpl dataSource;

    const tControllerUuid = 'dd096b01-cd70-4dde-acb9-fedb9e15f492';
    const tControllerDeviceUid = '246F28F074DC';

    setUp(() {
      mockDio = MockDio();
      dataSource = DevicesRemoteDataSourceImpl(mockDio);
    });

    test(
      'getDevices deve usar controller.uuid no query parameter controller_uuid, e NAO enviar controller_id nem deviceUid',
      () async {
        final mockResponseData = [
          {
            'uuid': '30a8360a-abdc-4b42-81df-1eb904f16415',
            'device_uid': 'DEVICE001',
            'name': 'Sensor de umidade 1',
            'last_seen': '2026-10-07T15:59:00-03:00',
            'is_online': true,
            'is_irrigating': false,
            'status': 'ATIVO',
            'controllerDeviceId': 12,
          },
        ];

        when(
          () => mockDio.get(
            '/devices',
            queryParameters: {
              'page_id': 1,
              'page_size': 10,
              'controller_uuid': tControllerUuid,
            },
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/devices'),
            statusCode: 200,
            data: mockResponseData,
          ),
        );

        final result = await dataSource.getDevices(
          controllerUuid: tControllerUuid,
        );

        expect(result, isA<List>());
        expect(result.length, 1);
        expect(result.first['name'], 'Sensor de umidade 1');

        verify(
          () => mockDio.get(
            '/devices',
            queryParameters: {
              'page_id': 1,
              'page_size': 10,
              'controller_uuid': tControllerUuid,
            },
          ),
        ).called(1);

        // Garante que controller_id e deviceUid NAO sao enviados
        verifyNever(
          () => mockDio.get(
            '/devices',
            queryParameters: {
              'page_id': 1,
              'page_size': 10,
              'controller_uuid': tControllerDeviceUid,
            },
          ),
        );
      },
    );

    test(
      'Deve enviar a request mesmo se controllerUuid for vazio (para obter todos os devices da conta)',
      () async {
        when(
          () => mockDio.get(
            '/devices',
            queryParameters: {'page_id': 1, 'page_size': 10},
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/devices'),
            statusCode: 200,
            data: [],
          ),
        );

        final result = await dataSource.getDevices(controllerUuid: '');

        expect(result, isEmpty);
        verify(
          () => mockDio.get(
            '/devices',
            queryParameters: {'page_id': 1, 'page_size': 10},
          ),
        ).called(1);
      },
    );

    test(
      'Lança erro de validação antes de chamar a API se controllerUuid tiver formato inválido (ex: deviceUid)',
      () async {
        expect(
          () => dataSource.getDevices(controllerUuid: tControllerDeviceUid),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('formato inválido'),
            ),
          ),
        );

        verifyZeroInteractions(mockDio);
      },
    );

    test(
      'Retorno de array vazio [] deve resultar em lista vazia sem crash',
      () async {
        when(
          () => mockDio.get(
            '/devices',
            queryParameters: {
              'page_id': 1,
              'page_size': 10,
              'controller_uuid': tControllerUuid,
            },
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/devices'),
            statusCode: 200,
            data: [],
          ),
        );

        final result = await dataSource.getDevices(
          controllerUuid: tControllerUuid,
        );

        expect(result, isEmpty);
      },
    );

    test('Trata erro HTTP 400 exibindo mensagem retornada pela API', () async {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/devices'),
        response: Response(
          requestOptions: RequestOptions(path: '/devices'),
          statusCode: 400,
          data: {'error': 'controller_uuid inválido'},
        ),
      );

      when(
        () => mockDio.get(
          '/devices',
          queryParameters: {
            'page_id': 1,
            'page_size': 10,
            'controller_uuid': tControllerUuid,
          },
        ),
      ).thenThrow(dioException);

      expect(
        () => dataSource.getDevices(controllerUuid: tControllerUuid),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('controller_uuid inválido'),
          ),
        ),
      );
    });
  });

  group(
    'DevicesRemoteDataSourceImpl - Alteração de Nome (PUT /devices/name/{uuid})',
    () {
      late MockDio mockDio;
      late DevicesRemoteDataSourceImpl dataSource;

      const tDeviceUuid = '30a8360a-abdc-4b42-81df-1eb904f16415';
      const tQrToken = '6144999d2f954c36d5adf8d0';
      const tNewName = 'tomates';

      setUp(() {
        mockDio = MockDio();
        dataSource = DevicesRemoteDataSourceImpl(mockDio);
      });

      test(
        'Deve realizar a chamada PUT para /devices/name/{uuid} com body {"name": "tomates"} e NÃO usar qrToken',
        () async {
          when(
            () => mockDio.put(
              '/devices/name/$tDeviceUuid',
              data: {'name': tNewName},
            ),
          ).thenAnswer(
            (_) async => Response(
              requestOptions: RequestOptions(
                path: '/devices/name/$tDeviceUuid',
              ),
              statusCode: 200,
            ),
          );

          await dataSource.updateDeviceName(tDeviceUuid, tNewName);

          verify(
            () => mockDio.put(
              '/devices/name/$tDeviceUuid',
              data: {'name': tNewName},
            ),
          ).called(1);

          verifyNever(
            () => mockDio.put(
              '/devices/name/$tQrToken',
              data: any(named: 'data'),
            ),
          );
        },
      );

      test(
        'Deve lançar erro de validação antes da requisição se UUID for vazio',
        () async {
          expect(
            () => dataSource.updateDeviceName('', tNewName),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('UUID do device não informado'),
              ),
            ),
          );

          verifyZeroInteractions(mockDio);
        },
      );

      test(
        'Deve lançar erro de validação antes da requisição se UUID for inválido (como qrToken)',
        () async {
          expect(
            () => dataSource.updateDeviceName(tQrToken, tNewName),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('UUID do device possui formato inválido'),
              ),
            ),
          );

          verifyZeroInteractions(mockDio);
        },
      );

      test('Deve atualizar o modelo localmente com o novo nome', () {
        final model = DeviceModel(
          uuid: tDeviceUuid,
          qrToken: tQrToken,
          deviceUid: 'sensor-1',
          name: 'Antigo Nome',
          firmwareVersion: '1.0.0',
          status: 'ativo',
        );

        final updated = model.copyWith(name: tNewName);

        expect(updated.name, 'tomates');
        expect(updated.uuid, tDeviceUuid);
        expect(updated.qrToken, tQrToken);
      });
    },
  );
}
