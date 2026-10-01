import 'package:cloud_firestore/cloud_firestore.dart'; // O 'package:cloud_firestore/cloud_firestore.dart'
import 'estado_orden.dart';

class OrdenServicio {
  final String id;
  final String vehiculoId;
  final String placa;
  final String modelo;
  final String marca;
  final String clienteNombre;
  final String clienteTelefono;
  final int kilometraje;
  final String motivoIngreso;
  final EstadoOrden estado;
  final List<String> fotosRecepcion; // URLs en Firebase Storage
  final List<String> fotosEntrega;   // URLs en Firebase Storage
  final DateTime fechaIngreso;
  final DateTime? fechaEntrega;

  OrdenServicio({
    required this.id,
    required this.vehiculoId,
    required this.placa,
    required this.modelo,
    required this.marca,
    required this.clienteNombre,
    required this.clienteTelefono,
    required this.kilometraje,
    required this.motivoIngreso,
    this.estado = EstadoOrden.recibido,
    this.fotosRecepcion = const [],
    this.fotosEntrega = const [],
    required this.fechaIngreso,
    this.fechaEntrega,
  });

  // Convertir objeto Dart a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'vehiculoId': vehiculoId,
      'placa': placa.toUpperCase().trim(),
      'modelo': modelo,
      'marca': marca,
      'clienteNombre': clienteNombre,
      'clienteTelefono': clienteTelefono,
      'kilometraje': kilometraje,
      'motivoIngreso': motivoIngreso,
      'estado': estado.toShortString(),
      'fotosRecepcion': fotosRecepcion,
      'fotosEntrega': fotosEntrega,
      'fechaIngreso': Timestamp.fromDate(fechaIngreso),
      'fechaEntrega': fechaEntrega != null ? Timestamp.fromDate(fechaEntrega!) : null,
    };
  }

  // Crear objeto Dart desde Firestore
  factory OrdenServicio.fromMap(Map<String, dynamic> map, String documentId) {
    return OrdenServicio(
      id: documentId,
      vehiculoId: map['vehiculoId'] ?? '',
      placa: map['placa'] ?? '',
      modelo: map['modelo'] ?? '',
      marca:map['marca'] ?? '',
      clienteNombre: map['clienteNombre'] ?? '',
      clienteTelefono: map['clienteTelefono'] ?? '',
      kilometraje: map['kilometraje'] ?? 0,
      motivoIngreso: map['motivoIngreso'] ?? '',
      estado: EstadoOrden.fromString(map['estado'] ?? 'recibido'),
      fotosRecepcion: List<String>.from(map['fotosRecepcion'] ?? []),
      fotosEntrega: List<String>.from(map['fotosEntrega'] ?? []),
      fechaIngreso: (map['fechaIngreso'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fechaEntrega: (map['fechaEntrega'] as Timestamp?)?.toDate(),
    );
  }

  // Método helper para inmutabilidad al actualizar el estado o agregar fotos
  OrdenServicio copyWith({
    EstadoOrden? estado,
    List<String>? fotosRecepcion,
    List<String>? fotosEntrega,
    DateTime? fechaEntrega,
  }) {
    return OrdenServicio(
      id: id,
      vehiculoId: vehiculoId,
      placa: placa,
      modelo: modelo,
      marca: marca,
      clienteNombre: clienteNombre,
      clienteTelefono: clienteTelefono,
      kilometraje: kilometraje,
      motivoIngreso: motivoIngreso,
      estado: estado ?? this.estado,
      fotosRecepcion: fotosRecepcion ?? this.fotosRecepcion,
      fotosEntrega: fotosEntrega ?? this.fotosEntrega,
      fechaIngreso: fechaIngreso,
      fechaEntrega: fechaEntrega ?? this.fechaEntrega,
    );
  }
}