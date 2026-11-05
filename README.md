# Ground Guard 🌿

O **Ground Guard** é um ecossistema inteligente completo para monitoramento e automação de jardins e hortas. Através de hardware IoT dedicado e este aplicativo móvel, usuários podem acompanhar a saúde de suas plantas em tempo real, automatizar a irrigação com base em dados climáticos e gerenciar recursos hídricos de forma eficiente.

## ✨ Principais Funcionalidades

- 📱 **Monitoramento Real-time**: Acompanhe umidade do solo, temperatura e vitalidade das plantas via WebSocket.
- 🌦️ **Inteligência Climática**: Integração com APIs de clima para sugerir regas ou economizar água em dias de chuva.
- 💧 **Controle de Irrigação**: Botões de ação imediata (Start/Stop) e agendamentos inteligentes.
- 🔐 **Autenticação Segura**: Login via E-mail/Senha ou Google OAuth 2.0 (iOS e Android).
- 📊 **Dashboards**: Gráficos detalhados de consumo e histórico de umidade.
- 🔍 **Provisionamento Simples**: Vínculo de novos dispositivos via leitura de QR Code.
- 🌗 **Modo Noturno**: Interface adaptável que respeita as configurações do sistema do usuário.

## 🚀 Tecnologias Utilizadas

- **Flutter & Dart**: Framework e linguagem principal.
- **Riverpod (v2)**: Gerenciamento de estado reativo e injeção de dependências.
- **Dio**: Cliente HTTP robusto com interceptores de autenticação e refresh token.
- **WebSockets**: Comunicação bidirecional para atualizações de sensores em tempo real.
- **Google Sign-In**: Autenticação social nativa.
- **Flutter Secure Storage**: Armazenamento criptografado de tokens JWT.
- **Custom Painters**: Gráficos e indicadores de umidade personalizados e animados.

## 🏗️ Estrutura e Arquitetura

O projeto segue a arquitetura **Feature-First**, organizando o código por funcionalidades de negócio para facilitar a escalabilidade e testes.

```text
lib/
├── core/               # Infraestrutura: Redes, Temas, Rotas, Storage, WebSocket
├── components/         # Widgets globais e reutilizáveis (Botões, Avatares, Loaders)
├── features/
│   ├── auth/          # Login (E-mail, Google), Registro, Recuperação de Senha
│   ├── devices/       # Listagem, Vínculo (QR Code) e Gestão de Dispositivos IoT
│   ├── home/          # Dashboard principal com círculos de umidade animados
│   ├── irrigation/    # Lógica de comandos e preferências de rega inteligente
│   ├── dashboard/     # Gráficos e estatísticas de uso hídrico
│   ├── weather/       # Integração com serviços de meteorologia
│   └── profile/       # Gestão de dados do usuário e preferências
└── main.dart          # Inicialização do app e Injeção Global
```

## 🛠️ Configuração e Execução

### 📋 Pré-requisitos
- Flutter SDK (Versão estável atual)
- Xcode (para iOS) / Android Studio (para Android)
- CocoaPods (para iOS)

### 🌍 Ambientes (Environment Switching)
O app utiliza `--dart-define` para trocar entre servidores local, dev e prod sem alterar o código.

| Ambiente | Host | Descrição |
| :--- | :--- | :--- |
| **Local** | `192.168.15.15:8080` | Servidor rodando na sua máquina local. |
| **Dev** | `api-dev.ground-guard.com.br` | Servidor de testes na nuvem (HTTPS/WSS). |
| **Prod** | `api.ground-guard.com.br` | Servidor de produção (Estável). |

### 🚀 Como Rodar
Utilize os scripts na pasta `scripts/` para facilitar o lançamento:

**1. Rodar Localmente (Seu servidor local):**
```bash
./scripts/run_local.sh
```

**2. Rodar em Ambiente de Desenvolvimento (Nuvem):**
```bash
./scripts/run_dev.sh
```

**Manual via Flutter CLI:**
```bash
flutter run --dart-define=APP_ENV=dev
```

### 🔐 Configuração do Google Sign-In
Para que o login com Google funcione, as seguintes configurações são obrigatórias:

- **Android**: Gere o SHA-1 (`./gradlew signingReport`) e cadastre no Google Cloud Console.
- **iOS**: O `REVERSED_CLIENT_ID` deve estar configurado no `ios/Runner/Info.plist`.
- **Backend**: O Backend espera que o ID Token seja gerado para o Client ID de Web configurado no `auth_provider.dart`.

## 🧪 Testes e Qualidade

O projeto utiliza uma combinação de testes unitários e de integração:
```bash
flutter test         # Roda todos os testes unitários e de widget
flutter analyze      # Executa análise estática de código
```

---
Desenvolvido por **Ground Guard Team** 🌿
"Tecnologia a favor da natureza."
