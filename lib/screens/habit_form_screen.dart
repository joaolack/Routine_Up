import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/habit.dart';

class HabitFormScreen extends StatefulWidget {
  final Habit? habit;

  const HabitFormScreen({super.key, this.habit});

  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _targetController = TextEditingController();
  final firestore = FirestoreService();

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      _nameController.text = widget.habit!.name;
      _descController.text = widget.habit!.description ?? '';
      _targetController.text = widget.habit!.targetDays.toString();
    }
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser!;

    if (widget.habit != null) {
      final updatedHabit = widget.habit!.copyWith(
        name: _nameController.text,
        description: _descController.text,
        targetDays: int.tryParse(_targetController.text) ?? 30,
      );
      await firestore.updateHabit(user.uid, updatedHabit);
    } else {
      final newHabit = Habit(
        name: _nameController.text,
        description: _descController.text,
        targetDays: int.tryParse(_targetController.text) ?? 30,
        createdAt: DateTime.now(),
      );
      await firestore.addHabit(user.uid, newHabit);
    }

    if (context.mounted) Navigator.pop(context);
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blueAccent),
      filled: true,
      fillColor: Colors.grey.shade100,
      labelStyle: TextStyle(color: Colors.grey.shade700),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.habit != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar Hábito' : 'Novo Hábito',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),

            Text(
              isEditing
                  ? "Atualize os detalhes do seu hábito"
                  : "Preencha as informações do novo hábito",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: _nameController,
              decoration: _inputDecoration("Nome do hábito", Icons.flag_outlined),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _descController,
              decoration: _inputDecoration("Descrição", Icons.notes_outlined),
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _targetController,
              decoration: _inputDecoration("Meta (dias)", Icons.calendar_today_outlined),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                backgroundColor: Colors.blueAccent,
              ),
              child: Text(
                isEditing ? 'Salvar Alterações' : 'Salvar',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}