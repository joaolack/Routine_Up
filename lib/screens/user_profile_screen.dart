import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/habit.dart';
import 'package:intl/intl.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final firestore = FirestoreService();

  List<Habit> habits = [];

  @override
  void initState() {
    super.initState();

    firestore.getHabits(user.uid).listen((list) {
      setState(() {
        habits = list;
      });
    });
  }

  String getInitials() {
    final name = user.displayName;

    if (name != null && name.trim().isNotEmpty) {
      final parts = name.split(" ");
      if (parts.length >= 2) {
        return parts[0][0].toUpperCase() + parts[1][0].toUpperCase();
      }
      return parts[0][0].toUpperCase();
    }

    return user.email![0].toUpperCase();
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: user.displayName);

    final newName = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar nome"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Nome"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text("Salvar")),
        ],
      ),
    );

    if (newName != null && newName.trim().isNotEmpty) {
      await user.updateDisplayName(newName.trim());
      setState(() {});
    }
  }

  Future<void> _logout() async {
  await FirebaseAuth.instance.signOut();
  
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = habits.where((h) => h.completedDays >= h.targetDays).length;

    final createdAt = user.metadata.creationTime?.toLocal();
    final formattedDate = createdAt != null
      ? DateFormat('dd/MM/yyyy HH:mm:ss').format(createdAt)
      : '---';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Meu Perfil",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.grey,
              child: Text(
                getInitials(),
                style: const TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              user.displayName ?? "Sem nome",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            Text(
              user.email ?? "",
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text("Hábitos", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            habits.length.toString(),
                            style: const TextStyle(fontSize: 24, color: Colors.deepPurple),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text("Concluídos", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            completedCount.toString(),
                            style: const TextStyle(fontSize: 24, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text("Informações da Conta", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("Criada em: $formattedDate"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _editName,
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text(
                "Editar nome",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.black),
              label: const Text(
                "Sair da conta",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}