# Implementation Plan: Padeleiro MVP

## Overview

Implementação incremental do Padeleiro MVP em Flutter/Dart com Riverpod e Firebase Blaze (Firestore, Auth, Cloud Functions Node.js/TypeScript). A arquitectura segue o padrão feature-first monolito modular. Cada tarefa constrói sobre a anterior, terminando com a integração completa de todas as funcionalidades.

Stack: Flutter (Dart) · Riverpod · Firebase Blaze · GoRouter · Freezed · Material Design 3 · Android-first

---

## Tasks

- [x] 1. Configurar projecto Flutter e infraestrutura base
  - [x] 1.1 Inicializar projecto Flutter e configurar dependências
    - Criar projecto Flutter com suporte Android
    - Adicionar dependências ao `pubspec.yaml`: `firebase_core`, `firebase_auth`, `cloud_firestore`, `cloud_functions`, `riverpod_annotation`, `flutter_riverpod`, `go_router`, `freezed`, `json_serializable`, `google_fonts`
    - Configurar `google-services.json` para Android (Firebase Blaze project)
    - Criar estrutura de directórios feature-first: `lib/core/`, `lib/features/`, `lib/models/`
    - _Requirements: 8.1_

  - [x] 1.2 Inicializar Firebase com persistência offline
    - Criar `lib/core/firebase/firebase_init.dart`
    - Chamar `Firebase.initializeApp()` em `main.dart` antes de `runApp()`
    - Configurar `FirebaseFirestore.instance.settings` com `persistenceEnabled: true` e `cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED`
    - Envolver a app com `ProviderScope` do Riverpod
    - _Requirements: 8.1, 8.2_

  - [x] 1.3 Configurar tema Material Design 3 e sistema de design
    - Criar `lib/core/theme/app_theme.dart` com `AppColors` (primary `#0055FF`, success `#00C853`, dark `#121212`, light `#F8F9FA`, error `#B00020`)
    - Configurar `GoogleFonts.interTextTheme()` como `TextTheme` da app
    - Definir `ThemeData` com `useMaterial3: true`, `ColorScheme.fromSeed`, touch targets mínimos 48×48dp
    - _Requirements: (design system)_

  - [x] 1.4 Configurar GoRouter com guards de autenticação e RBAC
    - Criar `lib/core/router/app_router.dart` com todas as rotas: `/login`, `/register`, `/pending`, `/suspended`, `/dashboard`, `/match/create`, `/match/:matchId`, `/admin`, `/admin/users`, `/admin/locations`
    - Implementar `redirect` guard: redirecionar para `/login` se não autenticado; verificar `status` do utilizador e redirecionar para `/pending` ou `/suspended` conforme aplicável
    - Implementar guard Admin: verificar `IdTokenResult.claims['role'] == 'admin'`; redirecionar para `/dashboard` se não for admin
    - _Requirements: 2.2, 2.4, 2.5, 6.1, 9.1_

- [x] 2. Implementar modelos de dados e repositórios base
  - [x] 2.1 Criar modelos Dart com Freezed
    - Criar `lib/models/app_user.dart`: classe `AppUser` com `@freezed`, campos `uid`, `email`, `fullName`, `phone`, `community`, `status` (`UserStatus` enum), `createdAt`; métodos `fromFirestore` / `toFirestore`
    - Criar `lib/models/match.dart`: classe `Match` com `@freezed`, campos `matchId`, `status` (`MatchStatus` enum), `createdBy`, `scheduledAt`, `locationId`, `locationName`, `teamA`, `teamB`, `scores?`, `winnerId?`; incluir `MatchTeam` e `SetScore`
    - Criar `lib/models/location.dart`: classe `Location` com `@freezed`, campos `locationId`, `name`, `address`, `isActive`
    - Criar `lib/models/user_stats.dart`: classe `UserStats` com `@freezed`, campos `uid`, `totalMatches`, `wins`, `losses`
    - Definir enums: `UserStatus`, `MatchStatus`, `SyncStatus`
    - Executar `flutter pub run build_runner build` para gerar código Freezed
    - _Requirements: 1.2, 4.4, 5.3, 3.2_

  - [x] 2.2 Implementar `AuthRepository`
    - Criar `lib/features/auth/data/auth_repository.dart` com classe abstracta e implementação `FirebaseAuthRepository`
    - Implementar `authStateChanges` como `Stream<User?>` via `FirebaseAuth.instance.authStateChanges()`
    - Implementar `signIn(email, password)` via `signInWithEmailAndPassword`
    - Implementar `register(RegisterPayload)`: criar conta Firebase Auth + escrever documento `users/{uid}` com `status: pending`
    - Implementar `signOut()` via `FirebaseAuth.instance.signOut()`
    - Implementar `getUserStatus(uid)`: ler documento `users/{uid}` e retornar `UserStatus`
    - _Requirements: 1.2, 2.2, 2.3, 2.6, 2.7_

  - [x] 2.3 Implementar `UserRepository`
    - Criar `lib/features/auth/data/user_repository.dart`
    - Implementar `watchActivePlayers()`: query `users` onde `status == 'active'`, excluindo o uid do utilizador autenticado
    - Implementar `watchPendingUsers()`: query `users` onde `status == 'pending'`, ordenado por `createdAt` crescente
    - Implementar `getUser(uid)`: leitura directa de `users/{uid}`
    - _Requirements: 4.3, 6.2_

  - [x] 2.4 Implementar `LocationRepository`
    - Criar `lib/features/match/data/location_repository.dart`
    - Implementar `watchActiveLocations()`: query `locations` onde `isActive == true`
    - Implementar `watchAllLocations()`: query `locations` sem filtro (Admin)
    - Implementar `createLocation(CreateLocationPayload)`: escrever documento com `isActive: true`
    - Implementar `archiveLocation(locationId)`: actualizar `isActive` para `false`
    - _Requirements: 4.2, 7.1, 7.2, 7.4, 7.5_

  - [x] 2.5 Implementar `MatchRepository`
    - Criar `lib/features/match/data/match_repository.dart`
    - Implementar `watchPlayerMatches(playerId, {cursor})`: query `matches` onde o `playerId` consta em qualquer campo de jogador, ordenado por `scheduledAt` decrescente, limite 20, com suporte a cursor para paginação
    - Implementar `createMatch(CreateMatchPayload)`: escrever documento com `status: scheduled`, dados denormalizados (nomes dos 4 jogadores e nome da localização)
    - Implementar `finalizeMatch(matchId, scores)`: actualizar documento com `scores` e `status: completed`
    - Implementar `getMatch(matchId)`: leitura directa de `matches/{matchId}`
    - _Requirements: 3.3, 3.4, 4.4, 5.3, 10.2_

  - [x] 2.6 Implementar `StatsRepository` e `AdminRepository`
    - Criar `lib/features/dashboard/data/stats_repository.dart`: `watchUserStats(uid)` via listener em `user_stats/{uid}`
    - Criar `lib/features/admin/data/admin_repository.dart`: `approveUser`, `rejectUser`, `suspendUser` invocando a CloudFunction `manageUserStatus` via `FirebaseFunctions.instance.httpsCallable('manageUserStatus')`
    - _Requirements: 3.2, 3.7, 6.3, 6.4, 6.5, 6.6_

- [~] 3. Checkpoint — Repositórios e modelos
  - Verificar que todos os repositórios compilam sem erros
  - Confirmar que `build_runner` gerou todos os ficheiros Freezed
  - Garantir que a inicialização Firebase e GoRouter estão funcionais
  - Perguntar ao utilizador se há dúvidas antes de avançar para a UI.

- [ ] 4. Implementar feature Auth (Login, Registo, ecrãs de estado)
  - [x] 4.1 Criar Riverpod providers de autenticação
    - Criar `lib/features/auth/data/auth_providers.dart`
    - Definir `authRepositoryProvider`, `authStateProvider` (StreamProvider), `userStatusProvider` (FutureProvider.family)
    - _Requirements: 2.2, 2.4, 2.5_

  - [x] 4.2 Implementar `LoginScreen`
    - Criar `lib/features/auth/presentation/login_screen.dart`
    - Formulário com campos email e password, botão "Entrar"
    - Validação inline: campos obrigatórios
    - Ao submeter: chamar `authRepository.signIn()`; em caso de erro apresentar mensagem genérica (sem revelar qual campo está errado)
    - Navegar para `/dashboard` em caso de sucesso (GoRouter guard trata redirecionamentos)
    - Link para `/register`
    - _Requirements: 2.1, 2.2, 2.3_

  - [x] 4.3 Implementar `RegisterScreen`
    - Criar `lib/features/auth/presentation/register_screen.dart`
    - Formulário com campos: nome completo, email, telefone, clube/comunidade
    - Validação inline: todos os campos obrigatórios, formato de email válido
    - Ao submeter: chamar `authRepository.register()`; tratar erro de email duplicado com mensagem específica
    - Navegar para `/pending` em caso de sucesso
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

  - [-] 4.4 Implementar `PendingScreen` e `SuspendedScreen`
    - Criar `lib/features/auth/presentation/pending_screen.dart`: ecrã informativo com mensagem de aprovação pendente e botão de logout
    - Criar `lib/features/auth/presentation/suspended_screen.dart`: ecrã informativo com mensagem de conta suspensa e botão de logout
    - _Requirements: 2.4, 2.5_

- [ ] 5. Implementar feature Dashboard e histórico de partidas
  - [x] 5.1 Criar Riverpod providers do Dashboard
    - Criar `lib/features/dashboard/data/dashboard_providers.dart`
    - Definir `userStatsProvider` (StreamProvider.family por uid)
    - Definir `MatchHistoryNotifier` e `matchHistoryProvider` (StateNotifierProvider.family por playerId) com suporte a paginação por cursor Firestore
    - _Requirements: 3.2, 3.3, 3.4, 3.7_

  - [x] 5.2 Implementar `DashboardScreen` com estatísticas
    - Criar `lib/features/dashboard/presentation/dashboard_screen.dart`
    - Apresentar `totalMatches`, `wins`, `losses` lidos de `userStatsProvider` (valores directos do Firestore, sem transformação)
    - Usar `AsyncValue.when()` para estados loading/error/data
    - Dados carregados do LocalCache enquanto sincroniza (comportamento nativo do SDK)
    - _Requirements: 3.1, 3.2, 3.5, 3.6, 3.7_

  - [-] 5.3 Implementar lista paginada de partidas no Dashboard
    - Criar `lib/features/dashboard/presentation/match_history_list.dart`
    - Lista de partidas ordenada por data decrescente, máximo 20 por página
    - Botão / scroll infinito para carregar próxima página via cursor Firestore
    - Cada item mostra: data, localização, teams, resultado (se `completed`)
    - _Requirements: 3.3, 3.4, 10.2_

  - [-] 5.4 Implementar `SyncBadge` e indicador de offline
    - Criar `lib/core/widgets/sync_badge.dart`: widget com `SyncStatus` enum (`pending` → spinner + "A guardar...", `synced` → checkmark + "Guardado", `error` → ícone erro + "Erro ao guardar")
    - Criar `lastSyncProvider` (StateProvider) para rastrear timestamp da última sincronização
    - Apresentar `SnackBar` não bloqueante se offline há mais de 48 horas
    - _Requirements: 8.3, 8.4_

- [ ] 6. Implementar feature Match (criação e detalhe)
  - [x] 6.1 Criar Riverpod providers de criação de partida
    - Criar `lib/features/match/data/match_providers.dart`
    - Definir `activePlayersProvider` (StreamProvider — lista de players activos excluindo o próprio)
    - Definir `activeLocationsProvider` (StreamProvider — localizações com `isActive: true`)
    - Definir `CreateMatchNotifier` e `createMatchProvider` (StateNotifierProvider) para gerir estado do formulário
    - _Requirements: 4.2, 4.3_

  - [x] 6.2 Implementar componentes UI partilhados: `PlayerChip` e `SwipeActionCard`
    - Criar `lib/core/widgets/player_chip.dart`: chip seleccionável com `AppUser`, `isSelected`, `onTap`; touch target mínimo 48×48dp
    - Criar `lib/core/widgets/swipe_action_card.dart`: card com gestos de swipe (direita = aprovar `#00C853`, esquerda = rejeitar/suspender vermelho)
    - _Requirements: 4.1, 6.3, 6.4, 6.5_

  - [-] 6.3 Implementar `ScoreStepper`
    - Criar `lib/features/match/presentation/score_stepper.dart`
    - Widget `StatefulWidget` com `minSets: 1`, `maxSets: 3`, callback `onChanged(List<SetScore>)`
    - Campos de pontuação para Team A e Team B por set
    - Validação inline: valores inteiros não negativos
    - _Requirements: 5.2, 5.4_

  - [~] 6.4 Implementar `CreateMatchScreen`
    - Criar `lib/features/match/presentation/create_match_screen.dart`
    - Formulário com: seletor de data/hora, dropdown de localização (de `activeLocationsProvider`), grid de `PlayerChip` (de `activePlayersProvider`) para seleccionar 3 jogadores e atribuir a Team A / Team B
    - Validação inline: todos os campos obrigatórios, exactamente 3 jogadores seleccionados
    - Ao submeter: chamar `matchRepository.createMatch()` com dados denormalizados; navegar para `/match/:matchId` em caso de sucesso
    - Funciona offline (escrita no LocalCache)
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7_

  - [~] 6.5 Implementar `MatchDetailScreen`
    - Criar `lib/features/match/presentation/match_detail_screen.dart`
    - Apresentar: data, localização, Team A vs Team B, resultado (se `completed`), `SyncBadge`
    - Se `status: scheduled` e o utilizador autenticado é o `createdBy`: apresentar botão "Registar Resultado"
    - Ao clicar "Registar Resultado": apresentar `ScoreStepper`; ao submeter chamar `matchRepository.finalizeMatch()`
    - Após finalizar: apresentar detalhe com resultado e `status: completed`
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.6, 5.7_

- [~] 7. Checkpoint — Features Player completas
  - Verificar fluxo completo: registo → pending → login → dashboard → criar partida → registar resultado
  - Confirmar comportamento offline: criar partida sem rede, verificar sincronização ao reconectar
  - Perguntar ao utilizador se há dúvidas antes de avançar para o Painel Admin.

- [ ] 8. Implementar feature Admin (gestão de utilizadores e localizações)
  - [x] 8.1 Criar Riverpod providers Admin
    - Criar `lib/features/admin/data/admin_providers.dart`
    - Definir `pendingUsersProvider` (StreamProvider — users com `status: pending`, ordenados por `createdAt` crescente)
    - Definir `allLocationsProvider` (StreamProvider — todas as localizações)
    - Definir `AdminActionsNotifier` e `adminActionsProvider` (StateNotifierProvider) para gerir estado das acções admin
    - _Requirements: 6.2, 7.1_

  - [ ] 8.2 Implementar `AdminScreen` com navegação por tabs
    - Criar `lib/features/admin/presentation/admin_screen.dart`
    - Tab "Utilizadores": lista de pending users com `SwipeActionCard` (swipe direita = aprovar, swipe esquerda = rejeitar)
    - Tab "Localizações": lista de todas as localizações com indicador ativo/arquivado e botão de arquivar
    - Separador "Admin" visível na navegação principal apenas para utilizadores com CustomClaim `role: admin`
    - _Requirements: 6.1, 6.2, 7.1_

  - [~] 8.3 Implementar gestão de utilizadores no Painel Admin
    - Criar `lib/features/admin/presentation/user_management.dart`
    - Lista de pending users ordenada por `createdAt` crescente
    - Acção de aprovação: invocar `adminRepository.approveUser(uid)` via CloudFunction; em caso de erro apresentar `SnackBar` com opção de retry
    - Acção de rejeição: invocar `adminRepository.rejectUser(uid)` via CloudFunction; tratamento de erro igual
    - Lista de active users com opção de suspensão: invocar `adminRepository.suspendUser(uid)`
    - _Requirements: 6.2, 6.3, 6.4, 6.5, 6.6_

  - [~] 8.4 Implementar gestão de localizações no Painel Admin
    - Criar `lib/features/admin/presentation/location_management.dart`
    - Lista de todas as localizações com estado ativo/arquivado
    - Formulário de nova localização: campos nome e morada, validação inline, ao submeter chamar `locationRepository.createLocation()`
    - Botão de arquivar: chamar `locationRepository.archiveLocation(locationId)` para actualizar `isActive: false`
    - _Requirements: 7.1, 7.2, 7.3, 7.4_

- [x] 9. Implementar Cloud Functions (Node.js/TypeScript)
  - [x] 9.1 Configurar projecto Firebase Functions
    - Inicializar `functions/` com `firebase init functions` (TypeScript)
    - Instalar dependências: `firebase-admin`, `firebase-functions`
    - Configurar `tsconfig.json` e `package.json` do projecto functions
    - _Requirements: 5.5, 6.3_

  - [x] 9.2 Implementar `onMatchFinalized` (Firestore Trigger)
    - Criar `functions/src/onMatchFinalized.ts`
    - Trigger `onDocumentUpdated('matches/{matchId}')`: verificar transição `scheduled → completed`
    - Extrair os 4 `playerIds` do documento
    - Chamar `determineWinner(scores)` para calcular o vencedor
    - Actualizar atomicamente `user_stats/{uid}` para cada jogador via `batch.update` com `FieldValue.increment`
    - _Requirements: 5.5_

  - [x] 9.3 Implementar `manageUserStatus` (HTTPS Callable)
    - Criar `functions/src/manageUserStatus.ts`
    - Verificar `request.auth?.token.role !== 'admin'`; lançar `HttpsError('permission-denied')` se não for admin
    - Aceitar `{ uid, action }` onde `action: 'approve' | 'reject' | 'suspend'`
    - Actualizar `users/{uid}` com o status correspondente
    - _Requirements: 6.3, 6.4, 6.5, 9.4_

- [x] 10. Implementar Firestore Security Rules
  - [x] 10.1 Escrever e publicar Firestore Security Rules
    - Criar/actualizar `firestore.rules` com todas as regras definidas no design
    - Regras para `users/{uid}`: create se autenticado e `uid == request.auth.uid`; read se próprio ou admin; update/delete apenas admin
    - Regras para `user_profiles/{uid}`: read se active ou admin; write se próprio
    - Regras para `user_stats/{uid}`: read se active ou admin; write `false` (apenas Cloud Functions)
    - Regras para `locations/{locationId}`: read se active ou admin; create/update apenas admin; delete `false`
    - Regras para `matches/{matchId}`: read se active ou admin; create se active; update se active e `createdBy == uid` e transição `scheduled → completed`; delete `false`
    - Publicar com `firebase deploy --only firestore:rules`
    - _Requirements: 1.6, 9.1, 9.2, 9.3, 9.5_

- [ ] 11. Integração final e navegação
  - [~] 11.1 Integrar navegação bottom bar com guards RBAC
    - Criar `lib/core/widgets/main_scaffold.dart` com `NavigationBar` (Material 3)
    - Tabs: "Dashboard", "Nova Partida", "Admin" (visível apenas para admins via `userStatusProvider`)
    - Integrar com GoRouter para navegação declarativa
    - _Requirements: 6.1_

  - [~] 11.2 Ligar todos os providers e repositórios na app
    - Registar todos os providers no `ProviderScope` em `main.dart`
    - Garantir que `authStateProvider` alimenta o guard do GoRouter
    - Verificar que `SyncBadge` está integrado nas screens de criação de partida e registo de resultado
    - _Requirements: 2.6, 8.3_

  - [~] 11.3 Tratar estados de erro e loading globais
    - Implementar `ErrorView` widget reutilizável para estados de erro Riverpod
    - Garantir que todos os `AsyncValue.when()` têm handlers de `loading` e `error`
    - Erros de autenticação: mensagem genérica
    - Erros de operações Admin: `SnackBar` com retry
    - _Requirements: 2.3, 6.6_

- [~] 12. Checkpoint final — Integração completa
  - Verificar fluxo end-to-end: registo → aprovação admin → login → dashboard → criar partida → registar resultado → stats actualizadas
  - Confirmar que guards de rota funcionam para todos os estados de utilizador
  - Confirmar que Cloud Functions estão deployadas e a funcionar
  - Confirmar que Firestore Security Rules estão publicadas
  - Perguntar ao utilizador se há ajustes finais antes de considerar o MVP completo.

---

## Notes

- Sem testes no MVP — nenhuma sub-task de testes foi incluída
- Cada tarefa referencia os requisitos específicos para rastreabilidade
- Os checkpoints garantem validação incremental antes de avançar para a próxima feature
- O comportamento offline é garantido pelo SDK Firestore nativo — não requer lógica customizada
- As Cloud Functions devem ser deployadas antes de testar aprovação de utilizadores e finalização de partidas
- O `build_runner` deve ser executado sempre que os modelos Freezed forem alterados

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1"] },
    { "id": 1, "tasks": ["1.2", "1.3"] },
    { "id": 2, "tasks": ["1.4", "2.1"] },
    { "id": 3, "tasks": ["2.2", "2.3", "2.4"] },
    { "id": 4, "tasks": ["2.5", "2.6"] },
    { "id": 5, "tasks": ["4.1", "5.1", "6.1", "8.1", "9.1"] },
    { "id": 6, "tasks": ["4.2", "4.3", "5.2", "6.2", "9.2", "9.3", "10.1"] },
    { "id": 7, "tasks": ["4.4", "5.3", "5.4", "6.3", "8.2"] },
    { "id": 8, "tasks": ["6.4", "8.3", "8.4"] },
    { "id": 9, "tasks": ["6.5"] },
    { "id": 10, "tasks": ["11.1", "11.2"] },
    { "id": 11, "tasks": ["11.3"] }
  ]
}
```
