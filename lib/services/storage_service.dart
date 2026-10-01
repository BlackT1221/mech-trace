import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Sube un archivo a Firebase Storage y retorna la URL de descarga
  /// [imagen] es el archivo físico en el dispositivo.
  /// [ordenId] se usa para crear una carpeta específica para cada vehículo.
  /// [esRecepcion] define si la foto es de cuando llegó o de cuando se entrega.
  Future<String> subirFotoOrden(File imagen, String ordenId, bool esRecepcion) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tipo = esRecepcion ? 'recepcion' : 'entrega';
      final nombreArchivo = '${tipo}_$timestamp.jpg';

      final ref = _storage
          .ref()
          .child('ordenes_servicio')
          .child(ordenId)
          .child(nombreArchivo);

      final uploadTask = await ref.putFile(imagen);

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Error al subir la foto a Storage: $e');
    }
  }
}