# Ground Guard 🌿

O **Ground Guard** é um ecossistema inteligente para monitoramento e automação de jardins e hortas. O aplicativo permite que usuários gerenciem dispositivos IoT, acompanhem a saúde do solo em tempo real e automatizem a irrigação com base em dados climáticos precisos, visando a saúde das plantas e a economia de recursos hídricos.

## ✨ Principais Funcionalidades

- 📱 **Monitoramento de Dispositivos**: Acompanhe o status e a saúde de múltiplos sensores e atuadores espalhados pelo seu jardim.
- 🌦️ **Previsão Local Inteligente**: Detecção automática da cidade do usuário via IP para exibir previsões meteorológicas em tempo real.
- 💧 **Alertas de Chuva**: Notificações e cards dinâmicos que avisam sobre previsões de chuva significativa (> 2mm), estimando a economia de água em litros.
- 🚜 **Irrigação sob Demanda**: Inicie ou pare ciclos de irrigação remotamente para zonas específicas.
- 📊 **Dashboard de Estatísticas**: Visualize gráficos de consumo de água e níveis de umidade do solo (mínimo, máximo e ideal).
- 🔐 **Segurança & Perfil**: Gerenciamento de perfil de usuário com suporte a biometria e armazenamento seguro de tokens.
- 🔍 **Vínculo via QR Code**: Adicione novos dispositivos ao seu ecossistema de forma rápida escaneando códigos QR.

## 🚀 Tecnologias Utilizadas

- **Flutter & Dart**: Framework principal para desenvolvimento cross-platform.
- **Riverpod**: Gerenciamento de estado reativo e injeção de dependências.
- **Dio**: Cliente HTTP para comunicação com a API REST.
- **OpenWeatherMap API**: Integração de dados climáticos e previsões.
- **Flutter Secure Storage**: Armazenamento criptografado de credenciais sensíveis.
- **Mobile Scanner**: Leitura de QR Codes para provisionamento de hardware.
- **Google Fonts (Quicksand)**: Tipografia moderna e legível.

## 🏗️ Estrutura do Projeto

O projeto segue uma arquitetura modular baseada em funcionalidades (**Feature-first**), facilitando a manutenção e escalabilidade:

```text
lib/
├── core/               # Componentes transversais (Rede, Temas, Rotas, Util)
├── components/         # Widgets globais e reutilizáveis
├── features/
│   ├── auth/          # Autenticação e Registro
│   ├── devices/       # Listagem e Gerenciamento de Hardware
│   ├── home/          # Tela principal com alertas climáticos
│   ├── irrigation/    # Lógica de comandos e preferências de rega
│   ├── profile/       # Edição de perfil e preferências
│   ├── dashboard/     # Gráficos e estatísticas de uso
│   ├── weather/       # Integração com APIs de clima
│   └── splash/        # Inicialização e fluxo de login
└── main.dart          # Ponto de entrada do aplicativo
```

## 🛠️ Como Executar

### Pré-requisitos
- Flutter SDK instalado (versão estável mais recente).
- Chave de API do OpenWeatherMap (configurada em `weather_remote_datasource.dart`).
- Um emulador ou dispositivo físico conectado.

### Instalação
1. Clone o repositório:
   ```bash
   git clone https://github.com/seu-usuario/ground_guard_app.git
   ```
2. Instale as dependências:
   ```bash
   flutter pub get
   ```
3. Execute o app:
   ```bash
   flutter run
   ```

## 🧪 Testes

O projeto conta com uma suíte de testes que cobre modelos, lógica de negócios (Providers) e componentes visuais.

Para rodar os testes:
```bash
flutter test
```

## ⚙️ Integração Contínua (CI)

Utilizamos o **GitHub Actions** para garantir a qualidade do código em cada contribuição. O workflow configurado em `.github/workflows/ci.yml` executa automaticamente:
- `flutter pub get`
- `dart format` (Formatação)
- `flutter analyze` (Análise estática)
- `flutter test` (Testes automatizados)

---
Desenvolvido com ❤️ para um mundo mais verde e tecnológico.
