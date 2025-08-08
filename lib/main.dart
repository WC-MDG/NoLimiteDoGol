// import 'package:flutter/foundation.dart' show kIsWeb; //BIBLIOTECA PARA VERIFICAR SE ESTA EXEC EM WEB OU OUTRO DIPS
// import 'dart:ui' as ui;
import 'dart:html' as html;
import 'dart:ui_web' as ui_web; // New import for all web-only stuff...

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';

//IMPORTANDO TELAS
import 'auth_wrapper.dart';


final html.BroadcastChannel channel = html.BroadcastChannel('mercado_gols_channel');

void main() async {
  
  //COMUNICACAO COM FIREBASE
  WidgetsFlutterBinding.ensureInitialized(); // Garante que o Flutter esteja inicializado
  await Firebase.initializeApp(
    options: const FirebaseOptions( 
      
      apiKey: "AIzaSyA7W0ISJG5OPmPkRh5ufwcLimrcqdGzITg",
      authDomain: "nolimitedogol-95c3d.firebaseapp.com",
      projectId: "nolimitedogol-95c3d",
      storageBucket: "nolimitedogol-95c3d.firebasestorage.app",
      messagingSenderId: "80764980308",
      appId: "1:80764980308:web:cf6c0908afe5eec9c0b1c1"
      ),
  );

  try{
    final snapshot = await FirebaseFirestore.instance.collection('teste').get();
    for (var doc in snapshot.docs) {
      print("Documento ID: ${doc.id}, Data: ${doc.data()}");
    }

  } catch(e) {
    print(e);
  }

  registerIframe();
  

  final uri = Uri.base;
  final isAdmin = uri.queryParameters['admin'] == 'true';
  runApp(MyApp(isAdmin: isAdmin));

}

void registerIframe() {    
  // ignore: undefined_prefixed_name
  ui_web.platformViewRegistry.registerViewFactory(
    'iframeElement',
    (int viewId) => html.IFrameElement()
      ..src = 'https://www.radarfutebol.com/radar/ca-vinotinto-guayaquil-city/13543602'
      ..style.border = 'none'
      ..width = '100%'
      ..height = '375',
  );  
}

class MyApp extends StatelessWidget {
  final bool isAdmin;
  const MyApp({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mercado dos gols',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      //home: isAdmin ? const AdminScreen() : const GameScreen(),
      home: const AuthWrapper(), // This is where we'll put our authentication flow
    );
  }
}

class Player {
  final String name;
  int points;
  String session;

  Player(this.name, this.points, this.session);
}

List<Player> players = List.generate(
    10, (index) => Player('Jogador ${index + 1}', 0, 'Fora do mercado'));

bool isMarketSuspended = false;
bool isHalftime = false;

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  String session = "Fora do mercado";
  int points = 0;
  bool isSwitching = false;
  int countdown = 5;
  Timer? gameTimer;
  Timer? switchTimer;
  String notificationMessage = "";

  late AnimationController _animationController;

  void startGameTimer() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (!isHalftime && !isMarketSuspended && !isSwitching && session != "Fora do mercado") {
          if (session == "No limite do gol") {
            points += 1;
          } else if (session == "A favor dos gols") {
            points -= 1;
          }
        }

        final thisPlayer = players.firstWhere((p) => p.name == 'Jogador 1');
        thisPlayer.points = points;
        thisPlayer.session = session;
      });
    });
  }

  void startSwitchCountdown(String newSession) {
    if (isMarketSuspended || isHalftime) return;

    setState(() {
      isSwitching = true;
      countdown = 5;
    });

    switchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isMarketSuspended) {
        timer.cancel();
        setState(() {
          isSwitching = false;
        });
        return;
      }
      setState(() {
        countdown--;
        if (countdown == 0) {
          timer.cancel();
          isSwitching = false;
          session = newSession;
          _animationController.forward(from: 0);
        }
      });
    });
  }

  void escutarMensagens() {
    channel.onMessage.listen((event) {
      String acao = event.data;
      if (acao == 'suspender') {
        setState(() {
          isMarketSuspended = !isMarketSuspended;
          if (!isMarketSuspended) {
            notificationMessage = "";
          }
          if (isMarketSuspended && isSwitching) {
            switchTimer?.cancel();
            isSwitching = false;
          }
        });
      } else if (acao == 'dobrar_zerar') {
        setState(() {
          if (session == "No limite do gol") {
            points = 0;
            notificationMessage = "Você tomou esse gol, seus pontos foram zerados! 😢";
          } else if (session == "A favor dos gols") {
            points *= 2;
            notificationMessage = "Você pegou esse gol, seus pontos foram dobrados! 😄";
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startGameTimer();
    escutarMensagens();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      lowerBound: 0.9,
      upperBound: 1.1,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse();
        }
      });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    switchTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void openAdminScreen() {
    html.window.open("?admin=true", "_blank");
  }

  Widget buildSessionButton(String label, Color color) {
    final bool isCurrent = session == label;

    return Column(
      children: [
        ScaleTransition(
          scale: isCurrent
              ? _animationController
              : const AlwaysStoppedAnimation(1.0),
          child: ElevatedButton(
            onPressed: isSwitching || isMarketSuspended || isHalftime || isCurrent
                ? null
                : () => startSwitchCountdown(label),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              backgroundColor: color,
              side: isCurrent ? const BorderSide(width: 3, color: Colors.black) : null,
              elevation: isCurrent ? 10 : 2,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isCurrent
                    ? Colors.black
                    : (label == "A favor dos gols" ? Colors.black : Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (isCurrent)
          const Icon(
            Icons.sports_soccer,
            size: 30,
            color: Colors.black87,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedPlayers = List<Player>.from(players);
    sortedPlayers.sort((a, b) => b.points.compareTo(a.points));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mercado dos gols"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: openAdminScreen,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: double.infinity,
                height: 375,
                child: HtmlElementView(viewType: 'iframeElement'),
              ),
              const SizedBox(height: 20),
              if (isMarketSuspended)
                const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 8),
                    Text("Mercado suspenso", style: TextStyle(fontSize: 18, color: Colors.red)),
                  ],
                ),
              if (notificationMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    notificationMessage,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                "Pontuação: $points",
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              if (isSwitching) const SizedBox(height: 20),
              if (isSwitching)
                Row(
                  children: [
                    const Icon(Icons.hourglass_empty, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text("Mudando sessão... ($countdown s)"),
                  ],
                ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                children: [
                  buildSessionButton("Fora do mercado", Colors.green),
                  buildSessionButton("No limite do gol", Colors.red),
                  buildSessionButton("A favor dos gols", Colors.yellow),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                "Ranking dos Top 10",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (context, index) {
                  final player = sortedPlayers[index];
                  return ListTile(
                    title: Text(player.name),
                    subtitle: Text("Sessão: ${player.session}"),
                    trailing: Text("${player.points} pts"),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  void toggleMarket() {
    setState(() {
      isMarketSuspended = !isMarketSuspended;
    });
    channel.postMessage('suspender');
  }

  void dobrarZerar() {
    channel.postMessage('dobrar_zerar');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Administração"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(
              width: double.infinity,
              height: 375,
              child: HtmlElementView(viewType: 'iframeElement'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: toggleMarket,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: Text(isMarketSuspended ? "Reabrir Mercado" : "Suspender Mercado"),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: isMarketSuspended ? dobrarZerar : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text("Dobrar/Zerar"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
