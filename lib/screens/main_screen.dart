import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mech_trace/screens/create_order_screen.dart';
import 'package:mech_trace/screens/order_detail_screen.dart';
import '../models/orden_servicio.dart';
import '../models/estado_orden.dart';
import '../services/firestore_service.dart';
import '../services/whatsapp_service.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final FirestoreService _firestoreService = FirestoreService();

  // Paleta de colores "Deportiva Moderna"
  final Color bgColor = const Color(0xFF121212);
  final Color cardColor = const Color(0xFF1E1E1E);
  final Color primaryOrange = const Color(0xFFFF5A00);
  final Color accentRed = const Color(0xFFE53935);
  final Color textWhite = const Color(0xFFF5F5F5);
  final Color textGrey = const Color(0xFFAAAAAA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.speed, color: primaryOrange, size: 28),
            const SizedBox(width: 10),
            Text(
              'MECH',
              style: TextStyle(
                color: textWhite,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'TRACE',
              style: TextStyle(
                color: primaryOrange,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: textWhite),
            onPressed: () {
              // TODO: Implementar filtros por estado
            },
          ),
        ],
      ),
      body: StreamBuilder<List<OrdenServicio>>(
        stream: _firestoreService.obtenerOrdenesActivas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: primaryOrange),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar los datos',
                style: TextStyle(color: accentRed),
              ),
            );
          }

          final ordenes = snapshot.data ?? [];

          if (ordenes.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: ordenes.length,
            itemBuilder: (context, index) {
              final orden = ordenes[index];
              return _buildOrdenCard(context, orden);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NuevoIngresoScreen()),
          );
        },
        backgroundColor: primaryOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'NUEVO INGRESO',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.build_circle_outlined,
            size: 80,
            color: textGrey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'TALLER DESPEJADO',
            style: TextStyle(
              color: textGrey,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No hay vehículos en servicio activo.',
            style: TextStyle(color: textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdenCard(BuildContext context, OrdenServicio orden) {
    final dateFormat = DateFormat('dd/MM/yyyy - HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: _getColorPorEstado(orden.estado), width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera de la Tarjeta: Placa y Estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPlacaBadge(orden.placa),
                _buildEstadoChip(orden.estado),
              ],
            ),
            const SizedBox(height: 16),

            // Detalles del vehículo
            Text(
              orden.modelo.toUpperCase(),
              style: TextStyle(
                color: textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: textGrey),
                const SizedBox(width: 4),
                Text(
                  orden.clienteNombre,
                  style: TextStyle(color: textGrey, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: textGrey),
                const SizedBox(width: 4),
                Text(
                  'Ingreso: ${dateFormat.format(orden.fechaIngreso)}',
                  style: TextStyle(color: textGrey, fontSize: 14),
                ),
              ],
            ),

            const Divider(color: Colors.white12, height: 24, thickness: 1),

            // Botones de Acción
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botón de WhatsApp integrado
                TextButton.icon(
                  onPressed: () => WhatsAppService.notificarCliente(orden),
                  icon: const Icon(
                    Icons.chat,
                    color: Color(0xFF25D366),
                  ), // Verde oficial WhatsApp
                  label: const Text(
                    'NOTIFICAR',
                    style: TextStyle(
                      color: Color(0xFF25D366),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366).withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalleOrdenScreen(ordenInicial: orden),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: primaryOrange,
                    side: BorderSide(color: primaryOrange),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('VER DETALLES'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget personalizado para simular una placa de vehículo
  Widget _buildPlacaBadge(String placa) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: textWhite,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade400, width: 1),
      ),
      child: Text(
        placa,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }

  // Etiqueta visual para el estado del vehículo
  Widget _buildEstadoChip(EstadoOrden estado) {
    Color colorEstado = _getColorPorEstado(estado);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorEstado.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorEstado.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 10, color: colorEstado),
          const SizedBox(width: 6),
          Text(
            estado.etiqueta.toUpperCase(),
            style: TextStyle(
              color: colorEstado,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Define colores dinámicos basados en la urgencia/etapa
  Color _getColorPorEstado(EstadoOrden estado) {
    switch (estado) {
      case EstadoOrden.recibido:
        return textGrey;
      case EstadoOrden.enDiagnostico:
        return accentRed; // Rojo sutil para revisión técnica
      case EstadoOrden.enReparacion:
        return primaryOrange; // Naranja activo para trabajo en proceso
      case EstadoOrden.listo:
        return const Color(0xFF00E676); // Verde neón para finalizado
      case EstadoOrden.entregado:
        return Colors.white38;
    }
  }
}
