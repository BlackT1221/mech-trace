import 'package:flutter/material.dart';
import '../models/orden_servicio.dart';
import '../services/firestore_service.dart';

class NuevoIngresoScreen extends StatefulWidget {
  const NuevoIngresoScreen({super.key});

  @override
  State<NuevoIngresoScreen> createState() => _NuevoIngresoScreenState();
}

class _NuevoIngresoScreenState extends State<NuevoIngresoScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  // Controladores de los campos
  final TextEditingController _placaController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _kilometrajeController = TextEditingController();
  final TextEditingController _motivoController = TextEditingController();

  bool _isLoading = false;

  // Paleta de colores
  final Color bgColor = const Color(0xFF121212);
  final Color inputColor = const Color(0xFF1E1E1E);
  final Color primaryOrange = const Color(0xFFFF5A00);
  final Color textWhite = const Color(0xFFF5F5F5);

  @override
  void dispose() {
    _placaController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _nombreController.dispose();
    _telefonoController.dispose();
    _kilometrajeController.dispose();
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _guardarOrden() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final nuevaOrden = OrdenServicio(
          id: '', // Firestore generará esto
          vehiculoId: _placaController.text.trim().toUpperCase(), 
          placa: _placaController.text.trim().toUpperCase(),
          modelo: _modeloController.text.trim(),
          marca: _marcaController.text.trim(),
          clienteNombre: _nombreController.text.trim(),
          clienteTelefono: _telefonoController.text.trim(),
          kilometraje: int.tryParse(_kilometrajeController.text.trim()) ?? 0,
          motivoIngreso: _motivoController.text.trim(),
          fechaIngreso: DateTime.now(),
        );

        await _firestoreService.crearOrden(nuevaOrden);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehículo registrado exitosamente'),
            backgroundColor: Color(0xFF00E676),
          ),
        );
        Navigator.pop(context); // Regresa a la pantalla principal
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
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
          'NUEVO INGRESO',
          style: TextStyle(color: textWhite, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryOrange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('DATOS DEL VEHÍCULO'),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: _placaController,
                            label: 'Placa',
                            hint: 'AAA-123',
                            isUpperCase: true,
                            icon: Icons.pin,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: _buildTextField(
                            controller: _kilometrajeController,
                            label: 'Kilometraje',
                            hint: 'Ej: 15000',
                            keyboardType: TextInputType.number,
                            icon: Icons.speed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _marcaController,
                            label: 'Marca',
                            hint: 'Ej: Suzuki, Bajaj',
                            icon: Icons.two_wheeler,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _modeloController,
                            label: 'Modelo',
                            hint: 'Ej: Gixxer 150, Dominar',
                            icon: Icons.info_outline,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 30),
                    _buildSectionTitle('DATOS DEL CLIENTE'),
                    _buildTextField(
                      controller: _nombreController,
                      label: 'Nombre Completo',
                      hint: 'Ej: Juan Pérez',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _telefonoController,
                      label: 'Teléfono (WhatsApp)',
                      hint: 'Ej: 573001234567',
                      keyboardType: TextInputType.phone,
                      icon: Icons.chat,
                      helperText: 'Incluye el código del país sin el + (Ej: 57 para Colombia)',
                    ),

                    const SizedBox(height: 30),
                    _buildSectionTitle('SERVICIO REQUERIDO'),
                    _buildTextField(
                      controller: _motivoController,
                      label: 'Motivo de Ingreso / Fallas',
                      hint: 'Ej: Mantenimiento general, cambio de llantas, revisión eléctrica...',
                      icon: Icons.build,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _guardarOrden,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'REGISTRAR INGRESO',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isUpperCase = false,
    int maxLines = 1,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: isUpperCase ? TextCapitalization.characters : TextCapitalization.words,
      maxLines: maxLines,
      style: TextStyle(color: textWhite),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Campo requerido';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        helperStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        labelStyle: const TextStyle(color: Colors.grey),
        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        filled: true,
        fillColor: inputColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryOrange, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}