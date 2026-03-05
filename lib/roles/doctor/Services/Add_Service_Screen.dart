import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/UserProvider.dart';

class DoctorAddServiceScreen extends StatefulWidget {
  const DoctorAddServiceScreen({super.key});

  @override
  State<DoctorAddServiceScreen> createState() =>
      _DoctorAddServiceScreenState();
}

class _DoctorAddServiceScreenState extends State<DoctorAddServiceScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _qualificationController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _patientCountController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  bool _isLoading = false;
  bool _isEdit = false;
  String? _selectedCategory;

  final List<String> categories = ["Dental", "Cardiology", "ENT"];

  @override
  void initState() {
    super.initState();
    _loadExistingService();
  }

  Future<void> _loadExistingService() async {
    final provider = Provider.of<UserProvider>(context, listen: false);
    final data = await provider.getMyDoctorService();

    if (data != null) {
      setState(() {
        _isEdit = true;
        _selectedCategory = data['category'];
        _titleController.text = data['title'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        _priceController.text = data['price'].toString();
        _durationController.text = data['duration'] ?? '';
        _qualificationController.text = data['qualification'] ?? '';
        _experienceController.text = data['experience'] ?? '';
        _patientCountController.text = data['patientCount'] ?? '';
        _imageUrlController.text = data['imageUrl'] ?? '';
      });
    }
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("সব তথ্য দিন")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Provider.of<UserProvider>(context, listen: false)
          .addDoctorService(
        category: _selectedCategory!,
        subCategory: "",
        service: "",
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: int.parse(_priceController.text),
        duration: _durationController.text.trim(),
        qualification: _qualificationController.text.trim(),
        experience: _experienceController.text.trim(),
        patientCount: _patientCountController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isEdit ? "Service updated successfully" : "Service added successfully"),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? "Edit Service" : "Add Service"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: "Doctor Image URL",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                v == null || v.isEmpty ? "Image URL required" : null,
              ),
              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
                items: categories
                    .map(
                      (e) =>
                      DropdownMenuItem(value: e, child: Text(e)),
                )
                    .toList(),
                onChanged: (val) =>
                    setState(() => _selectedCategory = val),
                validator: (v) =>
                v == null ? "Category required" : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _qualificationController,
                decoration: const InputDecoration(
                    labelText: "Qualification",
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _experienceController,
                      decoration: const InputDecoration(
                          labelText: "Experience (Years)",
                          border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _patientCountController,
                      decoration: const InputDecoration(
                          labelText: "Patients (e.g. 9k+)",
                          border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                    labelText: "Service Title",
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: "Price (BDT)",
                          border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                          labelText: "Duration (min)",
                          border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                      color: Colors.white)
                      : Text(
                    _isEdit ? "Update Service" : "Save Service",
                    style: const TextStyle(
                        color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
