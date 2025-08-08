// lib/match_one_screen.dart
import 'package:flutter/material.dart';

class MatchOneScreen extends StatelessWidget {
  const MatchOneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Primeira Partida'),
      ),
      body: const Center(
        child: Text('Bem-vindo à tela da primeira partida!'),
      ),
    );
  }
}
