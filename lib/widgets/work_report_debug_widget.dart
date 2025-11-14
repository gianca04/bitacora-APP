import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/work_report_api_service.dart';

/// Widget de pruebas para depurar los endpoints de Work Reports
/// Solo para desarrollo - no incluir en producción
class WorkReportDebugWidget extends StatefulWidget {
  const WorkReportDebugWidget({super.key});

  @override
  State<WorkReportDebugWidget> createState() => _WorkReportDebugWidgetState();
}

class _WorkReportDebugWidgetState extends State<WorkReportDebugWidget> {
  final WorkReportApiService _apiService = WorkReportApiService();
  String _resultText = 'Presiona un botón para probar los endpoints';
  bool _isLoading = false;

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  void _setResult(String result) {
    setState(() {
      _resultText = result;
    });
  }

  Future<void> _testGetWorkReports() async {
    debugPrint('🧪 [DEBUG] Iniciando prueba de getWorkReports()');
    _setLoading(true);
    _setResult('🔄 Cargando work reports...');

    try {
      final response = await _apiService.getWorkReports(
        perPage: 5,
        page: 1,
      );

      if (response != null) {
        final result = '''✅ ÉXITO: getWorkReports()
        
Respuesta recibida:
- Success: ${response.success}
- Message: ${response.message}
- Número de reportes: ${response.data.length}
- Paginación: ${response.pagination?.currentPage ?? 'N/A'}/${response.pagination?.lastPage ?? 'N/A'}

${response.data.isNotEmpty ? '''
Primer reporte:
- ID: ${response.data.first.id}
- Nombre: ${response.data.first.name}
- Fecha: ${response.data.first.reportDate}
- Proyecto: ${response.data.first.project.name}
- Empleado: ${response.data.first.employee.fullName}
''' : 'No hay datos en la respuesta'}''';

        _setResult(result);
        debugPrint('🧪 [DEBUG] ✅ Test exitoso: ${response.data.length} reportes obtenidos');
      } else {
        _setResult('❌ FALLO: getWorkReports() devolvió null');
        debugPrint('🧪 [DEBUG] ❌ Test fallido: respuesta null');
      }
    } catch (e) {
      final error = '''❌ ERROR: getWorkReports()
      
Error: $e
Tipo: ${e.runtimeType}''';
      
      _setResult(error);
      debugPrint('🧪 [DEBUG] ❌ Test con error: $e');
    } finally {
      _setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Debug Work Reports API'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔧 Herramientas de Depuración',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Usa estos botones para probar individualmente cada endpoint y diagnosticar problemas.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testGetWorkReports,
              icon: const Icon(Icons.list),
              label: const Text('Test: getWorkReports()'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '📋 Resultados',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_isLoading) ...[
                            const SizedBox(width: 16),
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            _resultText,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}