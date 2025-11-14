import 'package:flutter_test/flutter_test.dart';
import 'package:bitacora/models/work_report_api_models.dart';

void main() {
  group('WorkReportData Robust Parsing Tests', () {
    test('Should parse valid JSON correctly', () {
      final json = {
        'id': 52,
        'name': 'Test Report',
        'description': 'Test Description',
        'reportDate': '2025-10-30',
        'startTime': '22:00:00',
        'endTime': '06:00:00',
        'timestamps': {
          'createdAt': '2025-10-07T14:56:23-05:00',
          'updatedAt': '2025-10-07T15:37:31-05:00',
        },
        'employee': {
          'id': 58,
          'documentNumber': '46699530',
          'fullName': 'William Ipanaque Flores',
          'position': {
            'id': 8,
            'name': 'INGENIERO DE PROYECTOS',
          },
        },
        'project': {
          'id': 29,
          'name': 'Test Project',
          'status': 'Culminado',
          'subClient': {
            'id': 272,
            'name': 'TRUJILLO MK',
          },
          'client': null,
        },
        'photos': [],
        'summary': {
          'hasPhotos': true,
          'photosCount': 5,
          'hasSignatures': false,
        },
      };

      final report = WorkReportData.fromJson(json);

      expect(report.id, 52);
      expect(report.name, 'Test Report');
      expect(report.employee.fullName, 'William Ipanaque Flores');
      expect(report.project.name, 'Test Project');
      expect(report.summary.photosCount, 5);
    });

    test('Should handle ID as string', () {
      final json = {
        'id': '52',
        'name': 'Test Report',
        'description': 'Test',
        'reportDate': '2025-10-30',
        'startTime': '22:00:00',
        'endTime': '06:00:00',
        'timestamps': <String, dynamic>{},
        'employee': <String, dynamic>{},
        'project': <String, dynamic>{},
        'photos': <dynamic>[],
        'summary': <String, dynamic>{},
      };

      final report = WorkReportData.fromJson(json);

      expect(report.id, 52);
      expect(report.name, 'Test Report');
    });

    test('Should handle null values gracefully', () {
      final json = {
        'id': null,
        'name': null,
        'description': null,
        'reportDate': null,
        'startTime': null,
        'endTime': null,
        'timestamps': null,
        'employee': null,
        'project': null,
        'photos': null,
        'summary': null,
      };

      final report = WorkReportData.fromJson(json);

      expect(report.id, 0);
      expect(report.name, '');
      expect(report.description, '');
      expect(report.reportDate, '');
      expect(report.photos, isEmpty);
    });

    test('Should handle missing fields', () {
      final json = <String, dynamic>{};

      final report = WorkReportData.fromJson(json);

      expect(report.id, 0);
      expect(report.name, '');
      expect(report.photos, isEmpty);
      expect(report.summary.hasPhotos, false);
      expect(report.summary.photosCount, 0);
    });

    test('Should handle boolean as integer', () {
      final json = {
        'id': 1,
        'name': 'Test',
        'description': 'Test',
        'reportDate': '2025-10-30',
        'startTime': '22:00:00',
        'endTime': '06:00:00',
        'timestamps': <String, dynamic>{},
        'employee': <String, dynamic>{},
        'project': <String, dynamic>{},
        'photos': <dynamic>[],
        'summary': {
          'hasPhotos': 1,  // Integer instead of boolean
          'photosCount': '5',  // String instead of integer
          'hasSignatures': 0,  // Integer instead of boolean
        },
      };

      final report = WorkReportData.fromJson(json);

      expect(report.summary.hasPhotos, true);
      expect(report.summary.photosCount, 5);
      expect(report.summary.hasSignatures, false);
    });

    test('Should handle invalid photos array', () {
      final json = {
        'id': 1,
        'name': 'Test',
        'description': 'Test',
        'reportDate': '2025-10-30',
        'startTime': '22:00:00',
        'endTime': '06:00:00',
        'timestamps': {},
        'employee': {},
        'project': {},
        'photos': 'invalid',  // String instead of array
        'summary': {},
      };

      final report = WorkReportData.fromJson(json);

      expect(report.photos, isEmpty);
    });

    test('Should handle invalid photos array gracefully', () {
      final json = {
        'id': 1,
        'name': 'Test',
        'description': 'Test',
        'reportDate': '2025-10-30',
        'startTime': '22:00:00',
        'endTime': '06:00:00',
        'timestamps': <String, dynamic>{},
        'employee': <String, dynamic>{},
        'project': <String, dynamic>{},
        'photos': [
          <String, dynamic>{'invalid': 'data'},  // Invalid photo object - debería ser filtrado
          <String, dynamic>{
            'id': 2,
            'afterWork': <String, dynamic>{'photoUrl': 'http://example.com/photo2.jpg'},
            'beforeWork': <String, dynamic>{'photoUrl': null},
          },
        ],
        'summary': <String, dynamic>{},
      };

      final report = WorkReportData.fromJson(json);

      // Ambos se parsean ya que el catch en WorkReportPhoto devuelve objeto por defecto
      expect(report.photos.length, 2);
      expect(report.photos[1].id, 2);
    });

    test('Should handle nullable client in project', () {
      final json = {
        'id': 1,
        'name': 'Test',
        'description': 'Test',
        'reportDate': '2025-10-30',
        'startTime': '22:00:00',
        'endTime': '06:00:00',
        'timestamps': <String, dynamic>{},
        'employee': <String, dynamic>{},
        'project': <String, dynamic>{
          'id': 1,
          'name': 'Test Project',
          'status': 'Active',
          'subClient': <String, dynamic>{'id': 1, 'name': 'SubClient A'},
          'client': null,  // Explicitly null
        },
        'photos': <dynamic>[],
        'summary': <String, dynamic>{},
      };

      final report = WorkReportData.fromJson(json);

      expect(report.project.client, isNull);
      expect(report.project.subClient.name, 'SubClient A');
    });

    test('Should handle client when present', () {
      final json = {
        'id': 1,
        'name': 'Test',
        'description': 'Test',
        'reportDate': '2025-10-30',
        'startTime': '22:00:00',
        'endTime': '06:00:00',
        'timestamps': <String, dynamic>{},
        'employee': <String, dynamic>{},
        'project': <String, dynamic>{
          'id': 1,
          'name': 'Test Project',
          'status': 'Active',
          'subClient': <String, dynamic>{'id': 1, 'name': 'SubClient A'},
          'client': <String, dynamic>{'id': 100, 'name': 'Main Client'},  // Client present
        },
        'photos': <dynamic>[],
        'summary': <String, dynamic>{},
      };

      final report = WorkReportData.fromJson(json);

      expect(report.project.client, isNotNull);
      expect(report.project.client!.name, 'Main Client');
    });

    test('Should handle photoUrl null in WorkReportPhotoData correctly', () {
      final json = {
        'id': 1,
        'name': 'Test',
        'description': 'Test',
        'reportDate': '2025-10-30',
        'startTime': '22:00:00',
        'endTime': '06:00:00',
        'timestamps': <String, dynamic>{},
        'employee': <String, dynamic>{},
        'project': <String, dynamic>{},
        'photos': <dynamic>[
          <String, dynamic>{
            'id': 1,
            'afterWork': <String, dynamic>{'photoUrl': null},
            'beforeWork': <String, dynamic>{'photoUrl': null},
            'createdAt': '2025-10-07T16:12:06-05:00',
          },
        ],
        'summary': <String, dynamic>{},
      };

      final report = WorkReportData.fromJson(json);

      expect(report.photos.length, 1);
      expect(report.photos[0].afterWork.hasPhoto, false);
      expect(report.photos[0].beforeWork.hasPhoto, false);
      expect(report.photos[0].afterWork.photoUrl, isNull);
    });

    test('Should handle hasPhoto helper correctly', () {
      final photoWithUrl = WorkReportPhotoData(
        photoUrl: 'http://example.com/photo.jpg',
      );
      final photoWithoutUrl = WorkReportPhotoData(photoUrl: null);
      final photoWithEmptyUrl = WorkReportPhotoData(photoUrl: '');

      expect(photoWithUrl.hasPhoto, true);
      expect(photoWithoutUrl.hasPhoto, false);
      expect(photoWithEmptyUrl.hasPhoto, false);
    });

    test('Should return default object on complete parsing failure', () {
      // Even with completely invalid data, should return valid object
      final report = WorkReportData.fromJson(<String, dynamic>{});

      expect(report.id, 0);
      expect(report.name, '');
      expect(report.photos, isEmpty);
    });
  });

  group('WorkReportEmployee Parsing Tests', () {
    test('Should parse valid employee', () {
      final json = {
        'id': 58,
        'documentNumber': '46699530',
        'fullName': 'William Ipanaque Flores',
        'position': {
          'id': 8,
          'name': 'INGENIERO DE PROYECTOS',
        },
      };

      final employee = WorkReportEmployee.fromJson(json);

      expect(employee.id, 58);
      expect(employee.documentNumber, '46699530');
      expect(employee.fullName, 'William Ipanaque Flores');
      expect(employee.position.name, 'INGENIERO DE PROYECTOS');
    });

    test('Should handle missing fullName with default', () {
      final json = {
        'id': 58,
        'documentNumber': '46699530',
        'fullName': null,
        'position': {},
      };

      final employee = WorkReportEmployee.fromJson(json);

      expect(employee.fullName, 'Sin nombre');
    });
  });

  group('Pagination Parsing Tests', () {
    test('Should parse valid pagination', () {
      final json = {
        'total': 100,
        'perPage': 10,
        'currentPage': 1,
        'lastPage': 10,
        'from': 1,
        'to': 10,
        'hasMorePages': true,
      };

      final pagination = Pagination.fromJson(json);

      expect(pagination.total, 100);
      expect(pagination.currentPage, 1);
      expect(pagination.hasMorePages, true);
    });

    test('Should handle missing pagination fields', () {
      final json = <String, dynamic>{};

      final pagination = Pagination.fromJson(json);

      expect(pagination.total, 0);
      expect(pagination.currentPage, 0);
      expect(pagination.hasMorePages, false);
    });
  });
}
