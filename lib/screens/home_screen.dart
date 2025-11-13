import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/habit.dart';
import 'habit_form_screen.dart';
import 'habit_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final firestore = FirestoreService();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          'Meus Hábitos',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            tooltip: 'Sair',
            onPressed: () async{
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),

      body: StreamBuilder<List<Habit>>(
        stream: firestore.getHabits(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum hábito ainda.\nAdicione um para começar!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final habits = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              final progress = habit.completedDays / habit.targetDays;

              return Card(
                color: Colors.white,
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HabitDetailScreen(habit: habit),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Ícone de progresso
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: progress >= 1
                              ? Colors.green
                              : Colors.blueAccent,
                          child: Icon(
                            progress >= 1 ? Icons.check : Icons.track_changes,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Informações principais
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                habit.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                habit.description ?? 'Sem descrição.',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Barra de progresso
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 6,
                                  backgroundColor: Colors.grey.shade300,
                                  color: progress >= 1
                                      ? Colors.green
                                      : Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${habit.completedDays}/${habit.targetDays} dias',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent, // cor do botão
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HabitFormScreen()),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white), // cor do ícone
        label: const Text(
          'Novo hábito',
          style: TextStyle(
            color: Colors.white, // 👈 cor da fonte
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}