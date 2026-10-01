import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/orden_servicio.dart';
import '../models/estado_orden.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = 'ordenes_servicio';

  /// Crea una nueva orden de servicio en Firestore
  Future<void> crearOrden(OrdenServicio orden) async {
    try {
      // Usamos .doc() sin argumentos para que Firestore autogenere el ID
      final docRef = _db.collection(_collectionPath).doc();
      
      // Asignamos el ID generado a la orden antes de guardarla
      final nuevaOrden = orden.copyWith(estado: EstadoOrden.recibido);
      
      await docRef.set(nuevaOrden.toMap());
    } catch (e) {
      throw Exception('Error al crear la orden: $e');
    }
  }

  /// Obtiene un Stream de las órdenes activas (Para actualizar la UI en tiempo real)
  Stream<List<OrdenServicio>> obtenerOrdenesActivas() {
    return _db
        .collection(_collectionPath)
        .where('estado', isNotEqualTo: EstadoOrden.entregado.toShortString())
        .orderBy('estado') // Requiere crear un índice en Firebase Console
        .orderBy('fechaIngreso', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrdenServicio.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Actualiza el estado de una orden existente
  Future<void> actualizarEstadoOrden(String ordenId, EstadoOrden nuevoEstado) async {
    try {
      final actualizacion = <String, dynamic>{
        'estado': nuevoEstado.toShortString(),
      };

      // Si el estado es 'entregado' o 'listo', podríamos querer guardar la fecha
      if (nuevoEstado == EstadoOrden.listo || nuevoEstado == EstadoOrden.entregado) {
        actualizacion['fechaEntrega'] = Timestamp.now();
      }

      await _db.collection(_collectionPath).doc(ordenId).update(actualizacion);
    } catch (e) {
      throw Exception('Error al actualizar el estado: $e');
    }
  }

  /// Agrega URLs de fotos a una orden específica (recepción o entrega)
  Future<void> agregarFotos(String ordenId, List<String> urls, bool esRecepcion) async {
    try {
      final campo = esRecepcion ? 'fotosRecepcion' : 'fotosEntrega';
      await _db.collection(_collectionPath).doc(ordenId).update({
        campo: FieldValue.arrayUnion(urls), // Agrega a la lista sin duplicar
      });
    } catch (e) {
      throw Exception('Error al guardar las fotos: $e');
    }
  }
}