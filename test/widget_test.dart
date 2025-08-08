import 'package:flutter_test/flutter_test.dart';

import 'package:mercadodegols/main.dart';

void main() {
  testWidgets('GameScreen loads and updates correctly', (WidgetTester tester) async {
    // Passa isAdmin: false para abrir o GameScreen
    await tester.pumpWidget(const MyApp(isAdmin: false));

    // Verifica se o texto inicial da pontuação está na tela
    expect(find.text('Pontuação: 0'), findsOneWidget);

    // Verifica se os botões de sessão aparecem
    expect(find.text('Fora do mercado'), findsOneWidget);
    expect(find.text('No limite do gol'), findsOneWidget);
    expect(find.text('A favor dos gols'), findsOneWidget);

    // Tenta clicar no botão 'No limite do gol'
    await tester.tap(find.text('No limite do gol'));
    await tester.pump();

    // Como tem um timer de 10s para trocar sessão, o botão fica desabilitado (isSwitching = true),
    // então espera encontrar o texto "Mudando sessão... (10 s)"
    expect(find.textContaining('Mudando sessão'), findsOneWidget);
  });

  testWidgets('AdminScreen loads when isAdmin true', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(isAdmin: true));

    // Verifica se o título "Administração" aparece
    expect(find.text('Administração'), findsOneWidget);

    // Verifica se os botões da tela admin aparecem
    expect(find.text('Zerar Pontos'), findsOneWidget);
    expect(find.text('Suspender Mercado'), findsOneWidget);
    expect(find.text('Intervalo'), findsOneWidget);
    expect(find.text('Segundo Tempo'), findsOneWidget);
  });
}
