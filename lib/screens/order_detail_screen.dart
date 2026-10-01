import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/orden_servicio.dart';
import '../models/estado_orden.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../services/whatsapp_service.dart';

class DetalleOrdenScreen extends StatefulWidget {
  final OrdenServicio ordenInicial;

  const DetalleOrdenScreen({super.key, required this.ordenInicial});

  @override
  State<DetalleOrdenScreen> createState() => _DetalleOrdenScreenState();
}

class _DetalleOrdenScreenState extends State<DetalleOrdenScreen> {
  late OrdenServicio _orden;
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

  // Paleta de colores "Deportiva"
  final Color bgColor = const Color(0xFF121212);
  final Color cardColor = const Color(0xFF1E1E1E);
  final Color primaryOrange = const Color(0xFFFF5A00);
  final Color textWhite = const Color(0xFFF5F5F5);
  final Color textGrey = const Color(0xFFAAAAAA);

  @override
  void initState() {
    super.initState();
    _orden = widget.ordenInicial;
  }

  // Actualiza el estado de la orden en Firestore y en la UI
  Future<void> _cambiarEstado(EstadoOrden nuevoEstado) async {
    if (_orden.estado == nuevoEstado) return;

    setState(() => _isLoading = true);
    try {
      await _firestoreService.actualizarEstadoOrden(_orden.id, nuevoEstado);
      setState(() {
        _orden = _orden.copyWith(estado: nuevoEstado);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estado actualizado'), backgroundColor: Color(0xFF00E676)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Toma la foto, la sube a Storage y actualiza Firestore
  Future<void> _tomarFoto(bool esRecepcion) async {
    final XFile? fotoCapturada = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 60, // Reduce tamaño para subida rápida
    );

    if (fotoCapturada == null) return;

    setState(() => _isLoading = true);

    try {
      File archivoFisico = File(fotoCapturada.path);
      
      // Subimos a Storage
      String urlDescarga = await _storageService.subirFotoOrden(
        archivoFisico, 
        _orden.id, 
        esRecepcion,
      );

      // Guardamos la URL en Firestore
      await _firestoreService.agregarFotos(_orden.id, [urlDescarga], esRecepcion);

      // Actualizamos la UI local
      setState(() {
        if (esRecepcion) {
          _orden.fotosRecepcion.add(urlDescarga);
        } else {
          _orden.fotosEntrega.add(urlDescarga);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto guardada exitosamente'), backgroundColor: Color(0xFF00E676)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir foto: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        iconTheme: IconThemeData(color: primaryOrange),
        title: Text(
          'PLACA: ${_orden.placa}',
          style: TextStyle(color: textWhite, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat, color: Color(0xFF25D366)),
            tooltip: 'Notificar cliente',
            onPressed: () => WhatsAppService.notificarCliente(_orden),
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(),
                const SizedBox(height: 24),
                
                _buildSectionTitle('ESTADO DEL SERVICIO'),
                _buildEstadoSelector(),
                const SizedBox(height: 30),

                _buildSectionTitle('FOTOS DE RECEPCIÓN (ESTADO INICIAL)'),
                _buildGaleriaFotos(_orden.fotosRecepcion, true),
                const SizedBox(height: 24),

                _buildSectionTitle('FOTOS DE ENTREGA (REPARACIÓN)'),
                _buildGaleriaFotos(_orden.fotosEntrega, false),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(color: primaryOrange),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          color: primaryOrange,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // Tarjeta de información básica
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('VEHÍCULO ${_orden.placa} ${_orden.modelo}'.toUpperCase(), 
            style: TextStyle(color: textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(color: Colors.white12, height: 24),
          _buildInfoRow(Icons.person, 'Cliente', _orden.clienteNombre),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.phone, 'Teléfono', _orden.clienteTelefono),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.speed, 'Kilometraje', '${_orden.kilometraje} km'),
          const Divider(color: Colors.white12, height: 24),
          Text('MOTIVO DE INGRESO:', style: TextStyle(color: textGrey, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(_orden.motivoIngreso, style: TextStyle(color: textWhite, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: textGrey, size: 16),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: textGrey, fontSize: 14)),
        Expanded(child: Text(value, style: TextStyle(color: textWhite, fontSize: 14, fontWeight: FontWeight.w500))),
      ],
    );
  }

  // Selector interactivo de estado
  Widget _buildEstadoSelector() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: EstadoOrden.values.map((estado) {
        bool isSelected = _orden.estado == estado;
        return ChoiceChip(
          label: Text(estado.etiqueta.toUpperCase()),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : textGrey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
          selected: isSelected,
          selectedColor: primaryOrange,
          backgroundColor: cardColor,
          side: BorderSide(color: isSelected ? primaryOrange : Colors.white12),
          onSelected: (selected) {
            if (selected) _cambiarEstado(estado);
          },
        );
      }).toList(),
    );
  }

  // Galería horizontal para mostrar y agregar fotos
  Widget _buildGaleriaFotos(List<String> urls, bool esRecepcion) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length + 1, // +1 para el botón de agregar
        itemBuilder: (context, index) {
          // Botón de agregar foto (primer elemento)
          if (index == 0) {
            return GestureDetector(
              onTap: () => _tomarFoto(esRecepcion),
              child: Container(
                width: 100,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryOrange.withOpacity(0.5), width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, color: primaryOrange, size: 32),
                    const SizedBox(height: 8),
                    Text('AGREGAR', style: TextStyle(color: primaryOrange, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );
          }

          // Imágenes subidas
          String imageUrl = urls[index - 1];
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: cardColor,
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}