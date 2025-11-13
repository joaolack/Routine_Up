import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/habit.dart';

class HabitFormScreen extends StatefulWidget {
  final Habit? habit; // ✅ Novo parâmetro opcional (usado para edição)

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

    // ✅ Se veio um hábito para edição, preencher os campos
    if (widget.habit != null) {
      _nameController.text = widget.habit!.name;
      _descController.text = widget.habit!.description ?? '';
      _targetController.text = widget.habit!.targetDays.toString();
    }
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser!;

    // Se for edição, atualiza o hábito
    if (widget.habit != null) {
      final updatedHabit = widget.habit!.copyWith(
        name: _nameController.text,
        description: _descController.text,
        targetDays: int.tryParse(_targetController.text) ?? 30,
      );

      await firestore.updateHabit(user.uid, updatedHabit);
    } else {
      // Se for novo hábito
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.habit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Hábito' : 'Novo Hábito'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome do hábito'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _targetController,
              decoration: const InputDecoration(labelText: 'Meta (dias)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: Text(isEditing ? 'Salvar Alterações' : 'Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}