import 'package:url_launcher/url_launcher.dart';
import '../models/orden_servicio.dart';
import '../models/estado_orden.dart';

class WhatsAppService {
  /// Abre WhatsApp con un mensaje predefinido según el estado de la orden.
  static Future<void> notificarCliente(OrdenServicio orden) async {
    String numeroLimpio = orden.clienteTelefono.replaceAll(RegExp(r'\D'), '');
    String mensaje = _generarMensaje(orden);

    String mensajeCodificado = Uri.encodeComponent(mensaje);
    final Uri url = Uri.parse('https://wa.me/$numeroLimpio?text=$mensajeCodificado');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication, // Fuerza a que se abra fuera de la app (en WhatsApp)
        );
      } else {
        throw Exception('No se pudo abrir WhatsApp.');
      }
    } catch (e) {
      print('Error abriendo WhatsApp: $e');
      // To do: Mostrar un snackbar o diálogo al usuario indicando que no se pudo abrir WhatsApp.
    }
  }

  /// Helper privado que construye el texto exacto dependiendo del estado
  static String _generarMensaje(OrdenServicio orden) {
    String vehiculo = "vehículo con placa ${orden.placa}";
    
    switch (orden.estado) {
      case EstadoOrden.recibido:
        return "Hola ${orden.clienteNombre}. Hemos recibido tu $vehiculo en nuestro taller. Te notificaremos cuando iniciemos el diagnóstico. 🔧";
      
      case EstadoOrden.enDiagnostico:
        return "Hola ${orden.clienteNombre}. En este momento estamos realizando el diagnóstico de tu $vehiculo. Pronto te daremos un reporte. 👨‍🔧";
      
      case EstadoOrden.enReparacion:
        return "Hola ${orden.clienteNombre}. Ya nos encontramos trabajando en la reparación y mantenimiento de tu $vehiculo. ⚙️";
      
      case EstadoOrden.listo:
        return "¡Hola ${orden.clienteNombre}! Excelente noticia: tu $vehiculo ya está listo para ser entregado. Puedes pasar a recogerlo cuando gustes. 🏍️🚗";
      
      case EstadoOrden.entregado:
        return "Hola ${orden.clienteNombre}. Gracias por confiar en nosotros para el cuidado de tu $vehiculo. ¡Buen viaje y te esperamos para tu próximo mantenimiento! 🏁";
    }
  }
}