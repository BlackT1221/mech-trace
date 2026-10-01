enum EstadoOrden {
  recibido,
  enDiagnostico,
  enReparacion,
  listo,
  entregado;

  String toShortString() {
    return toString().split('.').last;
  }

  static EstadoOrden fromString(String estado) {
    return EstadoOrden.values.firstWhere(
      (e) => e.toShortString() == estado,
      orElse: () => EstadoOrden.recibido,
    );
  }

  String get etiqueta {
    switch (this) {
      case EstadoOrden.recibido:
        return 'Recibido';
      case EstadoOrden.enDiagnostico:
        return 'En Diagnóstico';
      case EstadoOrden.enReparacion:
        return 'En Reparación';
      case EstadoOrden.listo:
        return 'Listo para Entregar';
      case EstadoOrden.entregado:
        return 'Entregado';
    }
  }
}