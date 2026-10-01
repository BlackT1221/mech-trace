class Vehiculo {
  final String id;
  final String placa;
  final String marca;
  final String modelo;
  final String clienteNombre;
  final String clienteTelefono; // Formato con código de país para WhatsApp, p.ej. "573001234567"

  Vehiculo({
    required this.id,
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.clienteNombre,
    required this.clienteTelefono,
  });

  // Convertir a Map para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'placa': placa.toUpperCase().trim(),
      'marca': marca,
      'modelo': modelo,
      'clienteNombre': clienteNombre,
      'clienteTelefono': clienteTelefono,
    };
  }

  // Crear objeto desde un Map/DocumentSnapshot de Firestore
  factory Vehiculo.fromMap(Map<String, dynamic> map, String documentId) {
    return Vehiculo(
      id: documentId,
      placa: map['placa'] ?? '',
      marca: map['marca'] ?? '',
      modelo: map['modelo'] ?? '',
      clienteNombre: map['clienteNombre'] ?? '',
      clienteTelefono: map['clienteTelefono'] ?? '',
    );
  }
}