import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/habit.dart';
import '../services/firestore_service.dart';
import 'habit_form_screen.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;
  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late Habit habit;
  final firestore = FirestoreService();
  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    habit = widget.habit;
  }

  // 🟩 Função: marcar um dia como concluído
  Future<void> _markDayCompleted() async {
    if (habit.completedDays < habit.targetDays) {
      setState(() {
        habit = habit.copyWith(completedDays: habit.completedDays + 1);
      });

      await firestore.updateHabit(user.uid, habit);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Progresso atualizado: ${habit.completedDays}/${habit.targetDays}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meta já foi concluída! 🎉')),
      );
    }
  }

  // 🟥 Função: excluir hábito
  Future<void> _deleteHabit() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir hábito'),
        content: const Text('Tem certeza que deseja excluir este hábito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await firestore.deleteHabit(user.uid, habit.id!);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hábito excluído com sucesso!')),
        );
      }
    }
  }

  // ✏️ Ir para tela de edição
  void _editHabit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HabitFormScreen(habit: habit)),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hábito atualizado com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = habit.completedDays / habit.targetDays;

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _editHabit),
          IconButton(icon: const Icon(Icons.delete), onPressed: _deleteHabit),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Descrição:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(habit.description ?? 'Sem descrição.'),
            const SizedBox(height: 24),

            Text('Progresso:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            Text('${habit.completedDays}/${habit.targetDays} dias'),

            const Spacer(),
            ElevatedButton.icon(
              onPressed: _markDayCompleted,
              icon: const Icon(Icons.check),
              label: const Text('Marcar dia como concluído'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}