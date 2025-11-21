import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // AppBar transparente y sticky simulado
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título Principal
              const Text(
                "Dashboard",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: Color(0xFFE0E0E0),
                ),
              ),
              const SizedBox(height: 24),

              // Grid de Estadísticas (2 columnas)
              const Row(
                children: [
                  Expanded(
                    child: StatCard(
                      count: "5",
                      label: "Pendientes de sincronizar",
                      icon: Icons.cloud_off,
                      iconColor: Color(0xFFFFC107), // status-draft (Amarillo)
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      count: "128",
                      label: "Sincronizados en la nube",
                      icon: Icons.cloud_done,
                      iconColor: Color(0xFF28A745), // status-sent (Verde)
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Botones de Acción
              const ActionButton(
                text: "Crear Reporte",
                icon: Icons.add_circle_outline,
                isPrimary: true,
              ),
              const SizedBox(height: 12),
              const ActionButton(
                text: "Sincronizar ahora",
                icon: Icons.sync,
                isPrimary: false,
              ),

              const SizedBox(height: 32),

              // Sección de Últimos Reportes
              const Text(
                "Últimos reportes creados",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE0E0E0),
                ),
              ),
              const SizedBox(height: 20),

              // Timeline (Lista de reportes)
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: const [
                  TimelineItem(
                    title: "Instalación Fibra Óptica - Bloque A",
                    date: "25 de Octubre, 2023",
                    statusText: "Pendiente de sincronizar",
                    statusIcon: Icons.cloud_off,
                    statusColor: Color(0xFFFFC107),
                    isLast: false,
                  ),
                  TimelineItem(
                    title: "Revisión de Cableado Estructural",
                    date: "24 de Octubre, 2023",
                    statusText: "Sincronizado",
                    statusIcon: Icons.cloud_done,
                    statusColor: Color(0xFF28A745),
                    isLast: false,
                  ),
                  TimelineItem(
                    title: "Mantenimiento de Servidores",
                    date: "22 de Octubre, 2023",
                    statusText: "Sincronizado",
                    statusIcon: Icons.cloud_done,
                    statusColor: Color(0xFF28A745),
                    isLast: true, // El último no dibuja línea hacia abajo
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------
// Componentes Reutilizables
// --------------------------------------------

class StatCard extends StatelessWidget {
  final String count;
  final String label;
  final IconData icon;
  final Color iconColor;

  const StatCard({
    super.key,
    required this.count,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF192633), // card-dark
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 12),
          Text(
            count,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE0E0E0),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF92ADC9), // text-secondary-dark
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isPrimary;

  const ActionButton({
    super.key,
    required this.text,
    required this.icon,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: isPrimary
          ? ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF005A9C), // primary
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                shadowColor: const Color(0xFF005A9C).withOpacity(0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFF192633), // card-dark
                foregroundColor: const Color(0xFF005A9C), // Primary color text
                side: const BorderSide(color: Color(0xFF374151), width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 24, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class TimelineItem extends StatelessWidget {
  final String title;
  final String date;
  final String statusText;
  final IconData statusIcon;
  final Color statusColor;
  final bool isLast;

  const TimelineItem({
    super.key,
    required this.title,
    required this.date,
    required this.statusText,
    required this.statusIcon,
    required this.statusColor,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna del Timeline (Icono + Línea)
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF005A9C).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: Color(0xFF005A9C),
                  size: 20,
                ),
              ),
              // La línea vertical que conecta los items
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast ? Colors.transparent : const Color(0xFF374151),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Contenido del Item
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE0E0E0),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Creado: $date",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF92ADC9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
