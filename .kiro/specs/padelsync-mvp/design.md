# Design Document — Padeleiro MVP

## Overview

O Padeleiro MVP é uma aplicação móvel Android-first construída em Flutter/Dart com Firebase Blaze como backend. A arquitectura segue o padrão **feature-first monolito modular**, com separação clara entre camadas de UI, lógica de negócio (Riverpod providers) e acesso a dados (repositórios Firestore). O modo offline-first é garantido pela persistência nativa do Firestore SDK, sem necessidade de um motor de sincronização customizado.

---

## Architecture

### Camadas da Aplicação

```
┌─────────────────────────────────────────────────────────┐
│                    UI Layer (Widgets)                    │
│   Screens · Custom Components · Material Design 3        │
├─────────────────────────────────────────────────────────┤
│              State Management (Riverpod)                 │
│   Providers · Notifiers · AsyncValue streams             │
├─────────────────────────────────────────────────────────┤
│               Domain / Use Cases                         │
│   Validation · Business Rules · RBAC Guards              │
├─────────────────────────────────────────────────────────┤
│              Data Layer (Repositories)                   │
│   AuthRepository · MatchRepository · UserRepository     │
│   LocationRepository · StatsRepository                   │
├─────────────────────────────────────────────────────────┤
│           Firebase SDK (Firestore + Auth + CF)           │
│   Local Cache (SQLite) ←→ Cloud Firestore                │
└─────────────────────────────────────────────────────────┘
```

### Estrutura de Directórios (Feature-First)

```
lib/
├── core/
│   ├── firebase/          # Inicialização Firebase, settings offline
│   ├── router/            # GoRouter — rotas e guards de autenticação
│   ├── theme/             # AppTheme, cores, tipografia
│   └── widgets/           # Componentes partilhados (SyncBadge, etc.)
├── features/
│   ├── auth/
│   │   ├── data/          # AuthRepository
│   │   ├── domain/        # AuthState, UserStatus enum
│   │   └── presentation/  # LoginScreen, RegisterScreen, PendingScreen
│   ├── dashboard/
│   │   ├── data/          # StatsRepository, MatchRepository (read)
│   │   └── presentation/  # DashboardScreen, MatchHistoryList
│   ├── match/
│   │   ├── data/          # MatchRepository (write)
│   │   ├── domain/        # Match model, MatchStatus enum, validation
│   │   └── presentation/  # CreateMatchScreen, MatchDetailScreen, ScoreStepper
│   └── admin/
│       ├── data/          # AdminRepository (CloudFunction calls)
│       ├── domain/        # AdminAction enum
│       └── presentation/  # AdminScreen, UserManagement, LocationManagement
├── models/                # Modelos Firestore partilhados (User, Match, Location, UserStats)
└── main.dart
```

---

## Components and Interfaces

### Repositórios

#### `AuthRepository`

```dart
abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  Future<void> signIn(String email, String password);
  Future<void> register(RegisterPayload payload);
  Future<void> signOut();
  Future<UserStatus> getUserStatus(String uid);
}
```

#### `MatchRepository`

```dart
abstract class MatchRepository {
  Stream<List<Match>> watchPlayerMatches(String playerId, {DocumentSnapshot? cursor});
  Future<DocumentReference> createMatch(CreateMatchPayload payload);
  Future<void> finalizeMatch(String matchId, List<SetScore> scores);
  Future<Match> getMatch(String matchId);
}
```

#### `UserRepository`

```dart
abstract class UserRepository {
  Stream<List<AppUser>> watchActivePlayers();
  Stream<List<AppUser>> watchPendingUsers();
  Future<AppUser> getUser(String uid);
}
```

#### `LocationRepository`

```dart
abstract class LocationRepository {
  Stream<List<Location>> watchActiveLocations();
  Stream<List<Location>> watchAllLocations(); // Admin only
  Future<void> createLocation(CreateLocationPayload payload);
  Future<void> archiveLocation(String locationId);
}
```

#### `StatsRepository`

```dart
abstract class StatsRepository {
  Stream<UserStats> watchUserStats(String uid);
}
```

#### `AdminRepository`

```dart
abstract class AdminRepository {
  Future<void> approveUser(String uid);
  Future<void> rejectUser(String uid);
  Future<void> suspendUser(String uid);
}
```

### Riverpod Providers

```dart
// Auth
final authRepositoryProvider = Provider<AuthRepository>(...);
final authStateProvider = StreamProvider<User?>(...);
final userStatusProvider = FutureProvider.family<UserStatus, String>(...);

// Dashboard
final userStatsProvider = StreamProvider.family<UserStats, String>(...);
final matchHistoryProvider = StateNotifierProvider.family<MatchHistoryNotifier, MatchHistoryState, String>(...);

// Match Creation
final activePlayersProvider = StreamProvider<List<AppUser>>(...);
final activeLocationsProvider = StreamProvider<List<Location>>(...);
final createMatchProvider = StateNotifierProvider<CreateMatchNotifier, CreateMatchState>(...);

// Admin
final pendingUsersProvider = StreamProvider<List<AppUser>>(...);
final allLocationsProvider = StreamProvider<List<Location>>(...);
final adminActionsProvider = StateNotifierProvider<AdminActionsNotifier, AdminActionsState>(...);
```

### Custom UI Components

#### `ScoreStepper`

Widget para introdução de sets de uma partida. Suporta 1 a 3 sets, com campos de pontuação para Team A e Team B por set. Valida valores inteiros não negativos inline.

```dart
class ScoreStepper extends StatefulWidget {
  final int minSets;       // default: 1
  final int maxSets;       // default: 3
  final void Function(List<SetScore> scores) onChanged;
  final List<SetScore>? initialScores;
}
```

#### `PlayerChip`

Chip seleccionável para representar um jogador na lista de seleção de partida.

```dart
class PlayerChip extends StatelessWidget {
  final AppUser player;
  final bool isSelected;
  final VoidCallback onTap;
}
```

#### `SwipeActionCard`

Card com gestos de swipe para acções de aprovação/rejeição no painel Admin. Swipe direita = aprovar, swipe esquerda = rejeitar/suspender.

```dart
class SwipeActionCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeLeft;
  final Color rightColor;   // #00C853
  final Color leftColor;    // Colors.red
}
```

#### `SyncBadge`

Indicador visual de estado de sincronização. Apresenta "A guardar..." enquanto a escrita está pendente no LocalCache, e um checkmark quando confirmada pelo Firestore.

```dart
class SyncBadge extends StatelessWidget {
  final SyncStatus status; // pending | synced | error
}
```

---

## Data Models

### Firestore Collections

#### `users/{uid}`

```typescript
interface UserDocument {
  uid: string;
  email: string;
  fullName: string;
  phone: string;
  community: string;
  status: 'pending' | 'active' | 'suspended' | 'rejected';
  createdAt: Timestamp;
}
```

#### `user_profiles/{uid}`

```typescript
interface UserProfileDocument {
  uid: string;
  displayName: string;
  avatarUrl?: string;
  club: string;
}
```

#### `user_stats/{uid}`

```typescript
interface UserStatsDocument {
  uid: string;
  totalMatches: number;
  wins: number;
  losses: number;
  updatedAt: Timestamp;
}
```

#### `locations/{locationId}`

```typescript
interface LocationDocument {
  locationId: string;
  name: string;
  address: string;
  isActive: boolean;
  createdAt: Timestamp;
}
```

#### `matches/{matchId}`

```typescript
interface MatchDocument {
  matchId: string;
  status: 'scheduled' | 'completed';
  createdBy: string;           // uid do criador
  createdAt: Timestamp;
  scheduledAt: Timestamp;
  locationId: string;
  locationName: string;        // denormalizado
  teamA: {
    player1Id: string;
    player1Name: string;       // denormalizado
    player2Id: string;
    player2Name: string;       // denormalizado
  };
  teamB: {
    player1Id: string;
    player1Name: string;       // denormalizado
    player2Id: string;
    player2Name: string;       // denormalizado
  };
  scores?: SetScore[];         // preenchido ao finalizar
  winnerId?: 'teamA' | 'teamB';
}

interface SetScore {
  setNumber: number;
  teamAScore: number;
  teamBScore: number;
}
```

### Modelos Dart

```dart
enum UserStatus { pending, active, suspended, rejected }
enum MatchStatus { scheduled, completed }
enum SyncStatus { pending, synced, error }

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String uid,
    required String email,
    required String fullName,
    required String phone,
    required String community,
    required UserStatus status,
    required DateTime createdAt,
  }) = _AppUser;
}

@freezed
class Match with _$Match {
  const factory Match({
    required String matchId,
    required MatchStatus status,
    required String createdBy,
    required DateTime scheduledAt,
    required String locationId,
    required String locationName,
    required MatchTeam teamA,
    required MatchTeam teamB,
    List<SetScore>? scores,
    String? winnerId,
  }) = _Match;
}

@freezed
class UserStats with _$UserStats {
  const factory UserStats({
    required String uid,
    required int totalMatches,
    required int wins,
    required int losses,
  }) = _UserStats;
}

@freezed
class Location with _$Location {
  const factory Location({
    required String locationId,
    required String name,
    required String address,
    required bool isActive,
  }) = _Location;
}
```

---

## Navigation & Routing

Utiliza **GoRouter** com guards de autenticação e RBAC.

```dart
// Rotas principais
/login
/register
/pending          // PendingUser após login
/suspended        // SuspendedUser após login
/dashboard        // Player autenticado e activo
/match/create
/match/:matchId
/admin            // Apenas utilizadores com role: admin
/admin/users
/admin/locations
```

**Guard de autenticação:** Redireciona para `/login` se não autenticado. Verifica `status` do utilizador após autenticação e redireciona para `/pending` ou `/suspended` conforme aplicável.

**Guard Admin:** Verifica `request.auth.token.role == 'admin'` via `IdTokenResult.claims`. Redireciona para `/dashboard` se não for admin.

---

## Offline-First Strategy

### Inicialização

```dart
// core/firebase/firebase_init.dart
await Firebase.initializeApp();
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

### Fluxo de Escrita Offline

1. O utilizador cria uma partida ou regista um resultado.
2. O Firestore SDK escreve imediatamente no LocalCache (SQLite).
3. A UI actualiza via `SyncBadge` com estado `pending`.
4. Quando a conectividade é restabelecida, o SDK sincroniza automaticamente.
5. O listener Firestore confirma a escrita → `SyncBadge` transita para `synced`.

### Detecção de Offline Prolongado

```dart
// Verificar timestamp da última sincronização
// Se > 48h, apresentar SnackBar não bloqueante
final lastSyncProvider = StateProvider<DateTime?>(...);
```

---

## Cloud Functions

### `onMatchFinalized` (Firestore Trigger)

**Trigger:** `onDocumentUpdated('matches/{matchId}')` quando `status` transita de `scheduled` para `completed`.

```typescript
// functions/src/onMatchFinalized.ts
export const onMatchFinalized = onDocumentUpdated(
  'matches/{matchId}',
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();

    if (before?.status !== 'scheduled' || after?.status !== 'completed') return;

    const playerIds = [
      after.teamA.player1Id, after.teamA.player2Id,
      after.teamB.player1Id, after.teamB.player2Id,
    ];

    const winnerId = determineWinner(after.scores);
    const winnerTeamIds = winnerId === 'teamA'
      ? [after.teamA.player1Id, after.teamA.player2Id]
      : [after.teamB.player1Id, after.teamB.player2Id];

    const batch = admin.firestore().batch();
    for (const uid of playerIds) {
      const statsRef = admin.firestore().doc(`user_stats/${uid}`);
      const isWinner = winnerTeamIds.includes(uid);
      batch.update(statsRef, {
        totalMatches: FieldValue.increment(1),
        wins: isWinner ? FieldValue.increment(1) : FieldValue.increment(0),
        losses: isWinner ? FieldValue.increment(0) : FieldValue.increment(1),
        updatedAt: FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
);
```

### `manageUserStatus` (HTTPS Callable)

Invocada pelo Admin para aprovar, rejeitar ou suspender utilizadores. Verifica o CustomClaim `role: admin` antes de executar.

```typescript
export const manageUserStatus = onCall(async (request) => {
  if (request.auth?.token.role !== 'admin') {
    throw new HttpsError('permission-denied', 'Requires admin role');
  }
  const { uid, action } = request.data; // action: 'approve' | 'reject' | 'suspend'
  const statusMap = { approve: 'active', reject: 'rejected', suspend: 'suspended' };
  await admin.firestore().doc(`users/${uid}`).update({ status: statusMap[action] });
});
```

---

## Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isAuthenticated() {
      return request.auth != null;
    }

    function isAdmin() {
      return isAuthenticated() && request.auth.token.role == 'admin';
    }

    function isActiveUser() {
      return isAuthenticated() &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.status == 'active';
    }

    function isParticipant(matchData) {
      return request.auth.uid in [
        matchData.teamA.player1Id, matchData.teamA.player2Id,
        matchData.teamB.player1Id, matchData.teamB.player2Id
      ];
    }

    // users collection
    match /users/{uid} {
      allow create: if isAuthenticated() && request.auth.uid == uid;
      allow read: if isAuthenticated() && (request.auth.uid == uid || isAdmin());
      allow update, delete: if isAdmin();
    }

    // user_profiles collection
    match /user_profiles/{uid} {
      allow read: if isActiveUser() || isAdmin();
      allow write: if isAuthenticated() && request.auth.uid == uid;
    }

    // user_stats collection
    match /user_stats/{uid} {
      allow read: if isActiveUser() || isAdmin();
      allow write: if false; // apenas Cloud Functions
    }

    // locations collection
    match /locations/{locationId} {
      allow read: if isActiveUser() || isAdmin();
      allow create, update: if isAdmin();
      allow delete: if false;
    }

    // matches collection
    match /matches/{matchId} {
      allow read: if isActiveUser() || isAdmin();
      allow create: if isActiveUser();
      allow update: if isActiveUser() &&
        request.auth.uid == resource.data.createdBy &&
        resource.data.status == 'scheduled' &&
        request.resource.data.status == 'completed';
      allow delete: if false;
    }
  }
}
```

---

## UI/UX Design System

### Paleta de Cores

```dart
class AppColors {
  static const primary   = Color(0xFF0055FF); // Azul principal
  static const success   = Color(0xFF00C853); // Verde (vitória/sync)
  static const dark      = Color(0xFF121212); // Fundo dark mode
  static const light     = Color(0xFFF8F9FA); // Fundo light mode
  static const error     = Color(0xFFB00020); // Erros
  static const onPrimary = Color(0xFFFFFFFF);
}
```

### Tipografia

```dart
// Inter ou Montserrat via Google Fonts
TextTheme appTextTheme = GoogleFonts.interTextTheme().copyWith(
  displayLarge: ...,
  headlineMedium: ...,
  bodyLarge: ...,
  labelLarge: ..., // Botões
);
```

### Touch Targets

Todos os elementos interactivos têm dimensão mínima de **48×48dp**, conforme WCAG AAA e Material Design 3.

### Estados de Sincronização

| Estado | SyncBadge | Cor |
|--------|-----------|-----|
| `pending` | Spinner + "A guardar..." | Cinzento |
| `synced` | Checkmark + "Guardado" | `#00C853` |
| `error` | Ícone erro + "Erro ao guardar" | `#B00020` |

---

## Error Handling

### Estratégia Geral

- Erros de rede em operações Admin (approve/reject/suspend): apresentar `SnackBar` com mensagem de erro e opção de retry. Estado do utilizador não é alterado na UI.
- Erros de validação de formulários: mensagens inline por campo, antes de submeter.
- Erros de autenticação: mensagem genérica sem revelar qual campo está incorreto.
- Erros de Firestore offline: silenciados — o SDK gere a fila de escritas pendentes.

### Tratamento em Riverpod

```dart
// Usar AsyncValue para encapsular estados de loading/error/data
final matchProvider = FutureProvider.family<Match, String>((ref, matchId) async {
  return ref.read(matchRepositoryProvider).getMatch(matchId);
});

// Na UI
ref.watch(matchProvider(matchId)).when(
  data: (match) => MatchDetailView(match: match),
  loading: () => const CircularProgressIndicator(),
  error: (e, _) => ErrorView(message: e.toString()),
);
```

---

## Correctness Properties

*Uma propriedade é uma característica ou comportamento que deve ser verdadeiro em todas as execuções válidas do sistema — essencialmente, uma declaração formal sobre o que o sistema deve fazer. As propriedades servem de ponte entre especificações legíveis por humanos e garantias de correção verificáveis automaticamente.*

### Property 1: Registo cria utilizador com status pending

*Para qualquer* payload de registo válido (nome completo, email válido, telefone, comunidade), submeter o formulário de registo deve resultar na criação de um documento na coleção `users` com `status: pending`.

**Validates: Requirements 1.2**

---

### Property 2: Validação rejeita inputs inválidos no registo

*Para qualquer* submissão do formulário de registo com campos obrigatórios em falta ou email com formato inválido, a App deve apresentar mensagens de validação inline e não submeter o formulário ao Firestore.

**Validates: Requirements 1.4**

---

### Property 3: Utilizadores pending não acedem a matches nem locations

*Para qualquer* utilizador com `status: pending` ou `status: suspended`, todas as tentativas de leitura ou escrita nas coleções `matches` e `locations` devem ser rejeitadas pelas Firestore Security Rules.

**Validates: Requirements 1.6, 9.1**

---

### Property 4: Dashboard reflecte user_stats do Firestore

*Para qualquer* documento `user_stats` com valores de `totalMatches`, `wins` e `losses`, o Dashboard deve apresentar exactamente esses valores sem transformação.

**Validates: Requirements 3.2, 3.7**

---

### Property 5: Lista de partidas paginada e ordenada

*Para qualquer* conjunto de partidas de um jogador, a lista apresentada no Dashboard deve estar ordenada por data decrescente e cada página deve conter no máximo 20 documentos, usando cursores Firestore para navegação.

**Validates: Requirements 3.3, 10.2**

---

### Property 6: Operações offline não produzem erros de rede

*Para qualquer* operação de leitura ou escrita (criação de partida, registo de resultado) executada enquanto o dispositivo está sem conectividade, a operação deve ser processada a partir do LocalCache sem apresentar erros de rede ao utilizador.

**Validates: Requirements 3.5, 4.6, 5.6, 8.2**

---

### Property 7: Criação de partida produz documento com dados denormalizados

*Para qualquer* payload válido de criação de partida (4 jogadores activos, localização activa, data/hora), o documento criado na coleção `matches` deve ter `status: scheduled`, os nomes dos 4 jogadores denormalizados, e o nome da localização denormalizado.

**Validates: Requirements 4.4**

---

### Property 8: Validação rejeita formulário de partida incompleto

*Para qualquer* submissão do formulário de criação de partida com campos obrigatórios em falta ou menos de 3 jogadores seleccionados, a App deve apresentar mensagens de validação inline e não criar o documento no Firestore.

**Validates: Requirements 4.5**

---

### Property 9: Lista de jogadores exclui o criador e utilizadores não activos

*Para qualquer* lista de utilizadores no sistema, a lista de seleção de jogadores no formulário de criação de partida deve conter apenas utilizadores com `status: active` e excluir o utilizador autenticado.

**Validates: Requirements 4.3**

---

### Property 10: Registo de resultado actualiza status para completed

*Para qualquer* partida com `status: scheduled` e payload de scores válido (pelo menos 1 set com pontuações inteiras não negativas), submeter o resultado deve actualizar o documento com os scores e `status: completed`.

**Validates: Requirements 5.3**

---

### Property 11: Validação rejeita scores inválidos

*Para qualquer* submissão de resultado com valores de pontuação não numéricos ou negativos, a App deve apresentar mensagens de validação inline e não actualizar o documento no Firestore.

**Validates: Requirements 5.4**

---

### Property 12: Tab Admin visível apenas para admins

*Para qualquer* utilizador autenticado com CustomClaim `role: admin`, o separador "Admin" deve ser visível na navegação. *Para qualquer* utilizador sem esse CustomClaim, o separador não deve ser visível nem acessível.

**Validates: Requirements 6.1**

---

### Property 13: Lista de pending users ordenada por data crescente

*Para qualquer* conjunto de utilizadores com `status: pending`, a lista apresentada no Painel Admin deve estar ordenada por `createdAt` crescente.

**Validates: Requirements 6.2**

---

### Property 14: Criação de localização produz documento com isActive true

*Para qualquer* payload válido de criação de localização (nome e morada preenchidos), o documento criado na coleção `locations` deve ter `isActive: true`.

**Validates: Requirements 7.2**

---

### Property 15: Localizações inactivas excluídas da seleção de partida

*Para qualquer* conjunto de localizações, apenas as localizações com `isActive: true` devem aparecer na lista de seleção do formulário de criação de partida.

**Validates: Requirements 7.5**

---

### Property 16: Não-admins não podem escrever em users (outros) nem em locations

*Para qualquer* utilizador sem CustomClaim `role: admin`, tentativas de escrita na coleção `locations` ou em documentos `users` que não sejam o seu próprio devem ser rejeitadas pelas Firestore Security Rules.

**Validates: Requirements 9.2**

---

### Property 17: Pedidos sem token Firebase Auth são rejeitados pelo Firestore

*Para qualquer* operação Firestore executada sem um token de autenticação válido, o Firestore deve rejeitar o pedido.

**Validates: Requirements 9.5**
