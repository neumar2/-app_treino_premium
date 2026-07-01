# Contexto do Projeto - App Treino Premium

## O que já foi feito (Até 01/07/2026):

### 1. Base, Nuvem e Dados
- **App em Flutter**: Rodando no Android (APK: `build/app/outputs/flutter-apk/app-release.apk`) e Web.
- **Banco de Dados de Exercícios**: Injetamos centenas de exercícios. Um script traduziu nomes e equipamentos para PT-BR.
- **Integração com Firebase**: Autenticação Anônima segura, e dados salvos no Firestore Cloud (`app-treino-b3643`). Treinos são salvos automaticamente.
- **GitHub Integrado**: O repositório está versionado e hospedado em `https://github.com/neumar2/-app_treino_premium`.

### 2. A Nova Arquitetura "Premium" (Atualização de Hoje)
- **Engine de GIFs Definitiva**: Para evitar travamentos de memória RAM ("Out of Memory") por carregar muitos GIFs na tela, instalamos o pacote nativo `gif_view`. O app agora lê frames unitários, garantindo animações lisas com uso mínimo de memória e sem crashes.
- **Tela de Execução de Treino**: A Home Screen ganhou um botão gigante **INICIAR TREINO**. Ele abre uma nova tela focada (`workout_execution_screen.dart`) com uma checklist interativa dos exercícios.
- **Cronômetro Automático**: Na tela de execução, toda vez que você marca um exercício como concluído ("check"), um Timer elegante de 60s desce flutuando na tela para contar o seu tempo de descanso!
- **Avatar Muscular (Muscle Map)**: O avatar (boneco 3D em vetor) foi expandido para ocupar o fundo quase em tela cheia na criação do treino, servindo como base interativa de tudo. 
  - *Feedback Visual*: O boneco agora acende a musculatura de acordo com os exercícios que você já tem na sua ficha.
- **Filtros Ágeis**: Ao clicar em um músculo, aparecem **Chips Horizontais** (Ex: Halteres, Barra, Peso Corporal) para filtrar a lista na mesma hora.
- **Arrastar e Soltar (Drag & Drop)**: Os exercícios selecionados para a ficha ficam em um painel inferior (Bottom Sheet). Lá, adicionamos a funcionalidade de segurar e arrastar para reordenar a sua ficha na ordem que desejar.

## Próximos Passos (O que testar e fazer):
1. **Corrigir o Boneco 3D nas Costas**: Ainda falta testar e mapear pequenos botões e hits nas costas do avatar 3D (como panturrilha traseira, etc).
2. **Ampliar Dados de Treino**: O modelo `Treino` foi refeito para aguentar modificações de "Séries e Repetições" no futuro (atualmente é estático em 3x10-15).
3. **Continuar Melhorias no PC de Casa**: O usuário continuará a partir do push deste Contexto no PC de Casa (via `git pull`).
