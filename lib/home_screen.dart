// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Opcional, para um botão de sair

// Importe a nova tela que você deseja navegar
//import 'package:nolimitedogol/match_one_screen.dart'; // <--- ASSUMA QUE ESTE É O CAMINHO CORRETO PARA SUA NOVA TELA
import 'match_one_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 1. Título do AppBar alterado para "Match Selection Screen"
        title: const Text('Match Selection Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // O AuthWrapper vai detectar o logout e voltar para a tela de login
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 2. Removemos o texto "PARABÉNS! VOCÊ ESTÁ LOGADO!"
            // 3. Adicionamos um ElevatedButton no lugar do texto "Esta é a sua tela inicial."
            ElevatedButton(
              onPressed: () {
                // Navega para a nova tela quando o botão for pressionado
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MatchOneScreen()),
                );
              },
              child: const Text('Ir para a Seleção de Partida'), // Texto do botão
            ),
          ],
        ),
      ),
    );
  }
}
