// lib/match_one_screen.dart
import 'package:flutter/material.dart';

class MatchOneScreen extends StatelessWidget {
  final bool isAdmin;
  const MatchOneScreen({super.key,required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Primeira Partida (ADMIN)' : 'Primeira Partida'), // Título dinâmico
      ),
      body: Center(
       child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                const Text('Bem-vindo à tela da primeira partida!'),
                if (isAdmin)
                    Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: ElevatedButton.icon(
                            onPressed: () { /* Lógica de gerenciamento de jogo */ }, 
                            icon: const Icon(Icons.edit),
                            label: const Text('Gerenciar Partida'),
                        ),
                    ),
            ],
        ),
      ),
    );
  }
}