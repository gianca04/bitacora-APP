// Modelos para la respuesta de la API de Work Reports

class WorkReportApiResponse {
  final bool success;
  final String message;
  final List<WorkReportData> data;
  final Pagination? pagination;
  final Map<String, dynamic>? filters;
  final Map<String, dynamic> meta;

  WorkReportApiResponse({
    required this.success,
    required this.message,
    required this.data,
    this.pagination,
    this.filters,
    required this.meta,
  });

  factory WorkReportApiResponse.fromJson(Map<String, dynamic> json) {
    return WorkReportApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => WorkReportData.fromJson(item))
          .toList(),
      pagination: json['pagination'] != null 
          ? Pagination.fromJson(json['pagination']) 
          : null,
      filters: json['filters'],
      meta: json['meta'] ?? {},
    );
  }
}

class WorkReportSingleApiResponse {
  final bool success;
  final String message;
  final WorkReportData? data;
  final Map<String, dynamic> meta;
  final Map<String, dynamic>? summary;

  WorkReportSingleApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.meta,
    this.summary,
  });

  factory WorkReportSingleApiResponse.fromJson(Map<String, dynamic> json) {
    return WorkReportSingleApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? WorkReportData.fromJson(json['data']) : null,
      meta: json['meta'] ?? {},
      summary: json['summary'],
    );
  }
}

class WorkReportData {
  final int id;
  final String name;
  final String description;
  final String reportDate;
  final String startTime;
  final String endTime;
  final WorkReportTimestamps timestamps;
  final WorkReportEmployee employee;
  final WorkReportProject project;
  final List<WorkReportPhoto> photos;
  final WorkReportSummary summary;

  WorkReportData({
    required this.id,
    required this.name,
    required this.description,
    required this.reportDate,
    required this.startTime,
    required this.endTime,
    required this.timestamps,
    required this.employee,
    required this.project,
    required this.photos,
    required this.summary,
  });

  factory WorkReportData.fromJson(Map<String, dynamic> json) {
    try {
      return WorkReportData(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        reportDate: json['reportDate']?.toString() ?? '',
        startTime: json['startTime']?.toString() ?? '',
        endTime: json['endTime']?.toString() ?? '',
        timestamps: json['timestamps'] != null 
            ? WorkReportTimestamps.fromJson(json['timestamps'] as Map<String, dynamic>)
            : WorkReportTimestamps(createdAt: '', updatedAt: ''),
        employee: json['employee'] != null
            ? WorkReportEmployee.fromJson(json['employee'] as Map<String, dynamic>)
            : WorkReportEmployee(id: 0, documentNumber: '', fullName: '', position: WorkReportPosition(id: 0, name: '')),
        project: json['project'] != null
            ? WorkReportProject.fromJson(json['project'] as Map<String, dynamic>)
            : WorkReportProject(id: 0, name: '', status: '', subClient: WorkReportSubClient(id: 0, name: ''), client: null),
        photos: _parsePhotos(json['photos']),
        summary: json['summary'] != null
            ? WorkReportSummary.fromJson(json['summary'] as Map<String, dynamic>)
            : WorkReportSummary(hasPhotos: false, photosCount: 0, hasSignatures: false),
      );
    } catch (e) {
      // En caso de error, retornar un objeto con valores por defecto
      return WorkReportData(
        id: 0,
        name: 'Error al cargar',
        description: 'Error al parsear los datos del reporte',
        reportDate: '',
        startTime: '',
        endTime: '',
        timestamps: WorkReportTimestamps(createdAt: '', updatedAt: ''),
        employee: WorkReportEmployee(id: 0, documentNumber: '', fullName: '', position: WorkReportPosition(id: 0, name: '')),
        project: WorkReportProject(id: 0, name: '', status: '', subClient: WorkReportSubClient(id: 0, name: ''), client: null),
        photos: [],
        summary: WorkReportSummary(hasPhotos: false, photosCount: 0, hasSignatures: false),
      );
    }
  }

  static List<WorkReportPhoto> _parsePhotos(dynamic photosJson) {
    try {
      if (photosJson == null) return [];
      if (photosJson is! List) return [];
      
      return photosJson
          .where((photo) => photo != null)
          .map((photo) {
            try {
              return WorkReportPhoto.fromJson(photo as Map<String, dynamic>);
            } catch (e) {
              return null;
            }
          })
          .where((photo) => photo != null)
          .cast<WorkReportPhoto>()
          .toList();
    } catch (e) {
      return [];
    }
  }
}



class WorkReportTimestamps {
  final String createdAt;
  final String updatedAt;

  WorkReportTimestamps({
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkReportTimestamps.fromJson(Map<String, dynamic> json) {
    try {
      return WorkReportTimestamps(
        createdAt: json['createdAt']?.toString() ?? '',
        updatedAt: json['updatedAt']?.toString() ?? '',
      );
    } catch (e) {
      return WorkReportTimestamps(createdAt: '', updatedAt: '');
    }
  }
}

class WorkReportEmployee {
  final int id;
  final String documentNumber;
  final String fullName;
  final WorkReportPosition position;

  WorkReportEmployee({
    required this.id,
    required this.documentNumber,
    required this.fullName,
    required this.position,
  });

  factory WorkReportEmployee.fromJson(Map<String, dynamic> json) {
    try {
      final id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0;
      final documentNumber = json['documentNumber']?.toString() ?? '';
      final fullName = json['fullName']?.toString() ?? 'Sin nombre';
      
      WorkReportPosition position;
      try {
        position = json['position'] != null
            ? WorkReportPosition.fromJson(json['position'] as Map<String, dynamic>)
            : WorkReportPosition(id: 0, name: '');
      } catch (e) {
        position = WorkReportPosition(id: 0, name: '');
      }
      
      return WorkReportEmployee(
        id: id,
        documentNumber: documentNumber,
        fullName: fullName,
        position: position,
      );
    } catch (e) {
      return WorkReportEmployee(
        id: 0,
        documentNumber: '',
        fullName: 'Sin nombre',
        position: WorkReportPosition(id: 0, name: ''),
      );
    }
  }
}

class WorkReportPosition {
  final int id;
  final String name;

  WorkReportPosition({
    required this.id,
    required this.name,
  });

  factory WorkReportPosition.fromJson(Map<String, dynamic> json) {
    try {
      return WorkReportPosition(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        name: json['name']?.toString() ?? '',
      );
    } catch (e) {
      return WorkReportPosition(id: 0, name: '');
    }
  }
}

class WorkReportProject {
  final int id;
  final String name;
  final String status;
  final WorkReportSubClient subClient;
  final WorkReportClient? client;

  WorkReportProject({
    required this.id,
    required this.name,
    required this.status,
    required this.subClient,
    this.client,
  });

  factory WorkReportProject.fromJson(Map<String, dynamic> json) {
    try {
      final id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0;
      final name = json['name']?.toString() ?? '';
      final status = json['status']?.toString() ?? '';
      
      WorkReportSubClient subClient;
      try {
        subClient = json['subClient'] != null
            ? WorkReportSubClient.fromJson(json['subClient'] as Map<String, dynamic>)
            : WorkReportSubClient(id: 0, name: '');
      } catch (e) {
        subClient = WorkReportSubClient(id: 0, name: '');
      }
      
      WorkReportClient? client;
      try {
        client = json['client'] != null
            ? WorkReportClient.fromJson(json['client'] as Map<String, dynamic>)
            : null;
      } catch (e) {
        client = null;
      }
      
      return WorkReportProject(
        id: id,
        name: name,
        status: status,
        subClient: subClient,
        client: client,
      );
    } catch (e) {
      return WorkReportProject(
        id: 0,
        name: '',
        status: '',
        subClient: WorkReportSubClient(id: 0, name: ''),
        client: null,
      );
    }
  }
}



class WorkReportSubClient {
  final int id;
  final String name;

  WorkReportSubClient({
    required this.id,
    required this.name,
  });

  factory WorkReportSubClient.fromJson(Map<String, dynamic> json) {
    try {
      return WorkReportSubClient(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        name: json['name']?.toString() ?? '',
      );
    } catch (e) {
      return WorkReportSubClient(id: 0, name: '');
    }
  }
}

class WorkReportClient {
  final int id;
  final String name;

  WorkReportClient({
    required this.id,
    required this.name,
  });

  factory WorkReportClient.fromJson(Map<String, dynamic> json) {
    try {
      return WorkReportClient(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        name: json['name']?.toString() ?? '',
      );
    } catch (e) {
      return WorkReportClient(id: 0, name: '');
    }
  }
}

class WorkReportPhoto {
  final int id;
  final WorkReportPhotoData afterWork;
  final WorkReportPhotoData beforeWork;
  final String? createdAt;

  WorkReportPhoto({
    required this.id,
    required this.afterWork,
    required this.beforeWork,
    this.createdAt,
  });

  factory WorkReportPhoto.fromJson(Map<String, dynamic> json) {
    try {
      return WorkReportPhoto(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        afterWork: json['afterWork'] != null
            ? WorkReportPhotoData.fromJson(json['afterWork'] as Map<String, dynamic>)
            : WorkReportPhotoData(photoUrl: null),
        beforeWork: json['beforeWork'] != null
            ? WorkReportPhotoData.fromJson(json['beforeWork'] as Map<String, dynamic>)
            : WorkReportPhotoData(photoUrl: null),
        createdAt: json['createdAt']?.toString(),
      );
    } catch (e) {
      return WorkReportPhoto(
        id: 0,
        afterWork: WorkReportPhotoData(photoUrl: null),
        beforeWork: WorkReportPhotoData(photoUrl: null),
        createdAt: null,
      );
    }
  }
}

class WorkReportPhotoData {
  final String? photoUrl;

  WorkReportPhotoData({
    this.photoUrl,
  });

  factory WorkReportPhotoData.fromJson(Map<String, dynamic> json) {
    try {
      return WorkReportPhotoData(
        photoUrl: json['photoUrl']?.toString(),
      );
    } catch (e) {
      return WorkReportPhotoData(photoUrl: null);
    }
  }
  
  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;
}

class WorkReportSummary {
  final bool hasPhotos;
  final int photosCount;
  final bool hasSignatures;

  WorkReportSummary({
    required this.hasPhotos,
    required this.photosCount,
    required this.hasSignatures,
  });

  factory WorkReportSummary.fromJson(Map<String, dynamic> json) {
    try {
      return WorkReportSummary(
        hasPhotos: json['hasPhotos'] == true || json['hasPhotos'] == 1,
        photosCount: json['photosCount'] is int 
            ? json['photosCount'] 
            : int.tryParse(json['photosCount']?.toString() ?? '0') ?? 0,
        hasSignatures: json['hasSignatures'] == true || json['hasSignatures'] == 1,
      );
    } catch (e) {
      return WorkReportSummary(
        hasPhotos: false,
        photosCount: 0,
        hasSignatures: false,
      );
    }
  }
}

class Pagination {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final int from;
  final int to;
  final bool hasMorePages;

  Pagination({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    required this.from,
    required this.to,
    required this.hasMorePages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'] ?? 0,
      perPage: json['perPage'] ?? 0,
      currentPage: json['currentPage'] ?? 0,
      lastPage: json['lastPage'] ?? 0,
      from: json['from'] ?? 0,
      to: json['to'] ?? 0,
      hasMorePages: json['hasMorePages'] ?? false,
    );
  }
}

// Clase para parámetros de búsqueda
class WorkReportSearchParams {
  final String? search;
  final int? projectId;
  final int? employeeId;
  final String? dateFrom;
  final String? dateTo;
  final int perPage;
  final String sortBy;
  final String sortOrder;

  WorkReportSearchParams({
    this.search,
    this.projectId,
    this.employeeId,
    this.dateFrom,
    this.dateTo,
    this.perPage = 10,
    this.sortBy = 'created_at',
    this.sortOrder = 'desc',
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (search != null && search!.isNotEmpty) {
      params['search'] = search;
    }
    if (projectId != null) {
      params['project_id'] = projectId;
    }
    if (employeeId != null) {
      params['employee_id'] = employeeId;
    }
    if (dateFrom != null && dateFrom!.isNotEmpty) {
      params['date_from'] = dateFrom;
    }
    if (dateTo != null && dateTo!.isNotEmpty) {
      params['date_to'] = dateTo;
    }
    params['per_page'] = perPage;
    params['sort_by'] = sortBy;
    params['sort_order'] = sortOrder;
    
    return params;
  }
}