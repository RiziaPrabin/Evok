import 'package:flutter/material.dart';
import 'worker_model.dart'; // Import the worker model

class AddWorkerPage extends StatefulWidget {
  final String nextWorkerId;

  const AddWorkerPage({Key? key, required this.nextWorkerId}) : super(key: key);

  @override
  State<AddWorkerPage> createState() => _AddWorkerPageState();
}

class _AddWorkerPageState extends State<AddWorkerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _vestIdController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedShift = 'Day Shift';
  String _selectedDepartment = 'Excavation';
  DateTime _selectedDate = DateTime.now();

  final List<String> _shifts = ['Day Shift', 'Night Shift'];
  final List<String> _departments = [
    'Excavation',
    'Safety Inspection',
    'Maintenance',
    'Transport',
    'Engineering',
    'Administration',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _vestIdController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00FF41),
              onPrimary: Colors.black,
              surface: Color(0xFF1A2F3F),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Create new worker
      final newWorker = Worker(
        name: _nameController.text.trim(),
        id: widget.nextWorkerId,
        vestId: _vestIdController.text.trim(),
        shift: _selectedShift,
        department: _selectedDepartment,
        location: _locationController.text.trim().isEmpty
            ? 'Unknown'
            : _locationController.text.trim(),
        assigned:
            '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
        status: 'OFFLINE',
        statusColor: Colors.grey,
      );

      // Return the worker to previous screen
      Navigator.pop(context, newWorker);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1929),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1929),
        elevation: 0,
        title: const Text(
          'Add New Worker',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Worker Name
            _buildLabel('Worker Name *'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hintText: 'Enter worker name',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter worker name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Vest ID
            _buildLabel('Vest ID *'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _vestIdController,
              hintText: 'e.g., VEST-005',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter vest ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Shift
            _buildLabel('Shift *'),
            const SizedBox(height: 8),
            _buildDropdown(
              value: _selectedShift,
              items: _shifts,
              onChanged: (value) {
                setState(() {
                  _selectedShift = value!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Department
            _buildLabel('Department *'),
            const SizedBox(height: 8),
            _buildDropdown(
              value: _selectedDepartment,
              items: _departments,
              onChanged: (value) {
                setState(() {
                  _selectedDepartment = value!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Location (Optional)
            _buildLabel('Location (Optional)'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _locationController,
              hintText: 'e.g., Tunnel C-3',
            ),
            const SizedBox(height: 20),

            // Assigned Date
            _buildLabel('Assigned Date *'),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A3344),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    Icon(
                      Icons.calendar_today,
                      color: Colors.white.withOpacity(0.5),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Add Button
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FF41),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Add Worker',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.9),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: 15,
        ),
        filled: true,
        fillColor: const Color(0xFF1A3344),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00FF41), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A3344),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF1A3344),
          style: const TextStyle(color: Colors.white, fontSize: 15),
          icon: Icon(
            Icons.arrow_drop_down,
            color: Colors.white.withOpacity(0.5),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
