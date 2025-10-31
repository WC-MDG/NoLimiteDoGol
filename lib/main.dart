import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart'; // Importe para usar Cloud Functions
import 'package:flutter/foundation.dart'; // Para kDebugMode

// Certifique-se de ter suas DefaultFirebaseOptions.
import 'firebase_options.dart'; // Se você usa firebase_core configurado

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // Descomente se você estiver usando isso para produção
  );

  if (kDebugMode) { // Isso garante que os emuladores só serão usados em desenvolvimento
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    // Se usar Functions:
    // FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu App Firebase',
      home: AuthScreen(), // Sua tela de autenticação
    );
  }
}

// Exemplo de uma tela de autenticação simples para testar
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // ... (seu código de UI e lógica de autenticação aqui)

  // Exemplo de como chamar sua função 'addAdminRole'
  Future<void> callAddAdminRoleFunction(String targetUid) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('addAdminRole');
      final result = await callable.call({'uid': targetUid});
      print('Função addAdminRole chamada com sucesso: ${result.data}');
      // Opcional: force o refresh do token do usuário atual para ver as claims atualizadas
      await _auth.currentUser?.getIdTokenResult(true);
    } on FirebaseFunctionsException catch (e) {
      print('Erro ao chamar a função addAdminRole:');
      print('Código: ${e.code}');
      print('Mensagem: ${e.message}');
      print('Detalhes: ${e.details}');
    } catch (e) {
      print('Erro inesperado: $e');
    }
  }

  // ... (restante do seu código)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Auth Test')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                // Crie um usuário de teste no emulador Auth
                await _auth.createUserWithEmailAndPassword(email: 'test@example.com', password: 'password123');
                print('Usuário de teste criado!');
              },
              child: Text('Criar Usuário de Teste'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Logue com o usuário de teste
                await _auth.signInWithEmailAndPassword(email: 'test@example.com', password: 'password123');
                print('Usuário logado!');
              },
              child: Text('Login Usuário de Teste'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Chame a função para tornar o usuário de teste admin
                // Certifique-se de que o usuário logado tem permissão (neste caso, o próprio usuário logado)
                // Para testar a lógica da função, você teria que primeiro fazer um usuário "admin"
                // manualmente ou por um script temporário no emulador para poder chamar essa função.
                // Para o primeiro admin, você pode fazer uma função temporária que não checa permissão ou usar a Admin SDK em um script Node.js separado.
                if (_auth.currentUser != null) {
                  await callAddAdminRoleFunction(_auth.currentUser!.uid);
                } else {
                  print('Nenhum usuário logado para tornar admin.');
                }
              },
              child: Text('Tornar Usuário Logado Admin'),
            ),
            // Botão para verificar as claims (depois de chamar a função)
            ElevatedButton(
              onPressed: () async {
                if (_auth.currentUser != null) {
                  final idTokenResult = await _auth.currentUser!.getIdTokenResult(true); // true para forçar refresh
                  print('Claims do usuário: ${idTokenResult.claims}');
                  if (idTokenResult.claims != null && idTokenResult.claims!['admin'] == true) {
                    print('>> Este usuário é ADMIN! <<');
                  } else {
                    print('>> Este usuário NÃO é ADMIN. <<');
                  }
                } else {
                  print('Nenhum usuário logado.');
                }
              },
              child: Text('Verificar Claims'),
            ),
          ],
        ),
      ),
    );
  }
}
