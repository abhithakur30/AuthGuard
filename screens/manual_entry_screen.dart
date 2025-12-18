import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../services/secure_storage_service.dart';
import 'package:provider/provider.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _issuerController = TextEditingController();
  final _labelController = TextEditingController();
  final _secretController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<SecureStorageService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Manual Entry")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _issuerController,
                decoration: const InputDecoration(labelText: "Issuer"),
                validator: (value) => value!.isEmpty ? 'Issuer required' : null,
              ),
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(labelText: "Label"),
                validator: (value) => value!.isEmpty ? 'Label required' : null,
              ),
              TextFormField(
                controller: _secretController,
                decoration: const InputDecoration(labelText: "Base32 Secret"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty)
                    return "Secret required";
                  final base32Pattern = RegExp(r'^[A-Z2-7]+=*$');
                  if (!base32Pattern.hasMatch(value.trim().toUpperCase())) {
                    return "Invalid Base32 format";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await storage.addAccount(AccountModel(
                      issuer: _issuerController.text.trim(),
                      label: _labelController.text.trim(),
                      secret: _secretController.text.trim().replaceAll(' ', ''),
                    ));
                    Navigator.pop(context); // Go back to home
                  }
                },
                child: const Text("Add Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
