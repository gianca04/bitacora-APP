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
  final WorkReportResources resources;
  final String suggestions;
  final WorkReportSignatures signatures;
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
    required this.resources,
    required this.suggestions,
    required this.signatures,
    required this.timestamps,
    required this.employee,
    required this.project,
    required this.photos,
    required this.summary,
  });

  factory WorkReportData.fromJson(Map<String, dynamic> json) {
    return WorkReportData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      reportDate: json['reportDate'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      resources: WorkReportResources.fromJson(json['resources'] ?? {}),
      suggestions: json['suggestions'] ?? '',
      signatures: WorkReportSignatures.fromJson(json['signatures'] ?? {}),
      timestamps: WorkReportTimestamps.fromJson(json['timestamps'] ?? {}),
      employee: WorkReportEmployee.fromJson(json['employee'] ?? {}),
      project: WorkReportProject.fromJson(json['project'] ?? {}),
      photos: (json['photos'] as List<dynamic>? ?? [])
          .map((photo) => WorkReportPhoto.fromJson(photo))
          .toList(),
      summary: WorkReportSummary.fromJson(json['summary'] ?? {}),
    );
  }
}

class WorkReportResources {
  final String tools;
  final String personnel;
  final String materials;

  WorkReportResources({
    required this.tools,
    required this.personnel,
    required this.materials,
  });

  factory WorkReportResources.fromJson(Map<String, dynamic> json) {
    return WorkReportResources(
      tools: json['tools'] ?? '',
      personnel: json['personnel'] ?? '',
      materials: json['materials'] ?? '',
    );
  }
}

class WorkReportSignatures {
  final String? supervisor;
  final String? manager;

  WorkReportSignatures({
    this.supervisor,
    this.manager,
  });

  factory WorkReportSignatures.fromJson(Map<String, dynamic> json) {
    return WorkReportSignatures(
      supervisor: json['supervisor'],
      manager: json['manager'],
    );
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
    return WorkReportTimestamps(
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class WorkReportEmployee {
  final int id;
  final String documentType;
  final String documentNumber;
  final String firstName;
  final String lastName;
  final String fullName;
  final WorkReportPosition position;

  WorkReportEmployee({
    required this.id,
    required this.documentType,
    required this.documentNumber,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.position,
  });

  factory WorkReportEmployee.fromJson(Map<String, dynamic> json) {
    return WorkReportEmployee(
      id: json['id'] ?? 0,
      documentType: json['documentType'] ?? '',
      documentNumber: json['documentNumber'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      fullName: json['fullName'] ?? '',
      position: WorkReportPosition.fromJson(json['position'] ?? {}),
    );
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
    return WorkReportPosition(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class WorkReportProject {
  final int id;
  final String name;
  final WorkReportLocation location;
  final WorkReportDates dates;
  final String status;
  final WorkReportSubClient subClient;
  final WorkReportClient client;

  WorkReportProject({
    required this.id,
    required this.name,
    required this.location,
    required this.dates,
    required this.status,
    required this.subClient,
    required this.client,
  });

  factory WorkReportProject.fromJson(Map<String, dynamic> json) {
    return WorkReportProject(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      location: WorkReportLocation.fromJson(json['location'] ?? {}),
      dates: WorkReportDates.fromJson(json['dates'] ?? {}),
      status: json['status'] ?? '',
      subClient: WorkReportSubClient.fromJson(json['subClient'] ?? {}),
      client: WorkReportClient.fromJson(json['client'] ?? {}),
    );
  }
}

class WorkReportLocation {
  final String address;
  final double latitude;
  final double longitude;
  final String coordinates;

  WorkReportLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.coordinates,
  });

  factory WorkReportLocation.fromJson(Map<String, dynamic> json) {
    return WorkReportLocation(
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      coordinates: json['coordinates'] ?? '',
    );
  }
}

class WorkReportDates {
  final String startDate;
  final String endDate;

  WorkReportDates({
    required this.startDate,
    required this.endDate,
  });

  factory WorkReportDates.fromJson(Map<String, dynamic> json) {
    return WorkReportDates(
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
    );
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
    return WorkReportSubClient(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
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
    return WorkReportClient(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class WorkReportPhoto {
  final int id;
  final WorkReportPhotoData afterWork;
  final WorkReportPhotoData beforeWork;
  final String createdAt;

  WorkReportPhoto({
    required this.id,
    required this.afterWork,
    required this.beforeWork,
    required this.createdAt,
  });

  factory WorkReportPhoto.fromJson(Map<String, dynamic> json) {
    return WorkReportPhoto(
      id: json['id'] ?? 0,
      afterWork: WorkReportPhotoData.fromJson(json['afterWork'] ?? {}),
      beforeWork: WorkReportPhotoData.fromJson(json['beforeWork'] ?? {}),
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class WorkReportPhotoData {
  final String? photoUrl;
  final String description;

  WorkReportPhotoData({
    this.photoUrl,
    required this.description,
  });

  factory WorkReportPhotoData.fromJson(Map<String, dynamic> json) {
    return WorkReportPhotoData(
      photoUrl: json['photoUrl'],
      description: json['description'] ?? '',
    );
  }
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
    return WorkReportSummary(
      hasPhotos: json['hasPhotos'] ?? false,
      photosCount: json['photosCount'] ?? 0,
      hasSignatures: json['hasSignatures'] ?? false,
    );
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