# Requirements Document

## Introduction

O Padeleiro MVP é uma aplicação móvel Android-first (Flutter/Dart) para comunidades fechadas de padel. A plataforma permite que jogadores aprovados registem partidas 2v2, consultem o seu histórico e estatísticas, e que Admins gerenciem o acesso de utilizadores e a lista de localizações. O backend assenta em Firebase Blaze (Firestore, Auth, Cloud Functions). O modo offline é obrigatório — a aplicação deve funcionar sem conectividade e sincronizar automaticamente quando a ligação for restabelecida.

O MVP exclui explicitamente: disputas de resultados, integração com Google Maps/GPS, notificações push FCM, e gestão de localizações via mapa.

---

## Glossary

- **App**: A aplicação móvel Flutter Padeleiro.
- **Player**: Utilizador com status `active` e role `player`, aprovado por um Admin.
- **Admin**: Utilizador com Firebase Custom Claim `role: admin`, responsável por aprovar/rejeitar utilizadores e gerir localizações.
- **PendingUser**: Utilizador registado com status `pending`, aguardando aprovação de Admin.
- **SuspendedUser**: Utilizador com status `suspended`, sem acesso às funcionalidades da App.
- **Match**: Registo de uma partida 2v2 com 4 jogadores (Team A vs Team B), data/hora, localização e resultado.
- **MatchStatus**: Estado de uma partida — `scheduled` (agendada) ou `completed` (finalizada com resultado).
- **ScoreStepper**: Componente de UI para introdução de sets de uma partida (e.g., 6-4, 3-6, 6-2).
- **UserStats**: Documento Firestore com estatísticas pré-calculadas de um Player (total de partidas, vitórias, derrotas).
- **Location**: Registo de um clube/court de padel na coleção `locations` do Firestore (nome, morada).
- **Firestore**: Base de dados Cloud Firestore do Firebase, usada como fonte de verdade remota.
- **LocalCache**: Cache local gerida automaticamente pelo SDK do Firestore com persistência nativa ativada.
- **CloudFunction**: Função serverless Node.js/TypeScript executada no Firebase, nomeadamente `onMatchFinalized`.
- **CustomClaim**: Atributo `role: admin` atribuído ao token Firebase Auth de um utilizador Admin.
- **Riverpod**: Biblioteca de state management Flutter usada na App.
- **RBAC**: Role-Based Access Control — controlo de acesso baseado em papéis, aplicado via Firestore Security Rules e Custom Claims.

---

## Requirements

### Requirement 1: Registo de Utilizador (Onboarding)

**User Story:** Como visitante, quero submeter um pedido de registo com os meus dados, para que possa aguardar aprovação e aceder à comunidade Padeleiro.

#### Acceptance Criteria

1. THE App SHALL apresentar um formulário de registo com os campos: nome completo, endereço de email, número de telefone e clube/comunidade local.
2. WHEN o visitante submete o formulário de registo com todos os campos preenchidos e um email válido, THE App SHALL criar um documento na coleção `users` com `status: pending` e criar a conta Firebase Auth correspondente.
3. IF o email introduzido já existe na coleção `users`, THEN THE App SHALL apresentar uma mensagem de erro indicando que o email já está registado.
4. IF o formulário for submetido com campos obrigatórios em falta ou email com formato inválido, THEN THE App SHALL apresentar mensagens de validação inline por campo antes de submeter.
5. WHEN o registo é submetido com sucesso, THE App SHALL apresentar um ecrã de confirmação informando o PendingUser que o pedido está pendente de aprovação.
6. WHILE o utilizador tem `status: pending`, THE App SHALL impedir o acesso às coleções `matches` e `locations` do Firestore, conforme as Firestore Security Rules.

---

### Requirement 2: Autenticação

**User Story:** Como Player ou Admin, quero fazer login com email e password, para que possa aceder às funcionalidades da App de forma segura.

#### Acceptance Criteria

1. THE App SHALL disponibilizar um ecrã de login com campos de email e password.
2. WHEN um utilizador submete credenciais válidas de uma conta com `status: active`, THE App SHALL autenticar o utilizador via Firebase Auth e navegar para o Dashboard.
3. IF as credenciais submetidas forem inválidas ou a conta não existir, THEN THE App SHALL apresentar uma mensagem de erro genérica sem revelar qual campo está incorreto.
4. IF um utilizador com `status: pending` tentar fazer login, THEN THE App SHALL apresentar um ecrã informativo indicando que a conta está pendente de aprovação.
5. IF um utilizador com `status: suspended` tentar fazer login, THEN THE App SHALL apresentar um ecrã informativo indicando que a conta foi suspensa.
6. THE App SHALL manter a sessão do utilizador autenticado entre sessões da App, sem exigir novo login, enquanto o token Firebase Auth for válido.
7. WHEN o utilizador faz logout, THE App SHALL terminar a sessão Firebase Auth e navegar para o ecrã de login.

---

### Requirement 3: Dashboard e Histórico de Partidas

**User Story:** Como Player, quero ver o meu histórico de partidas e as minhas estatísticas básicas, para que possa acompanhar a minha evolução na comunidade.

#### Acceptance Criteria

1. WHEN um Player autenticado abre a App, THE App SHALL apresentar o Dashboard como ecrã inicial, carregando dados do LocalCache enquanto sincroniza com o Firestore.
2. THE App SHALL apresentar no Dashboard as estatísticas do Player lidas do documento `user_stats`: total de partidas jogadas, número de vitórias e número de derrotas.
3. THE App SHALL apresentar no Dashboard uma lista paginada das partidas do Player, ordenada por data decrescente, com no máximo 20 partidas por página.
4. WHEN o Player chega ao fim da lista de partidas, THE App SHALL carregar a próxima página de resultados do Firestore ou do LocalCache.
5. WHILE o dispositivo está sem conectividade, THE App SHALL apresentar os dados do Dashboard a partir do LocalCache sem apresentar erros de rede ao utilizador.
6. THE App SHALL apresentar o tempo de carregamento inicial do Dashboard (cold-start) em menos de 1,5 segundos quando os dados estão disponíveis no LocalCache.
7. WHEN os dados do `user_stats` são atualizados no Firestore (após `onMatchFinalized`), THE App SHALL refletir os novos valores no Dashboard sem necessidade de ação do utilizador.

---

### Requirement 4: Criação de Partida

**User Story:** Como Player, quero criar um registo de partida 2v2 com data, hora, localização e os 4 jogadores, para que a partida fique registada na plataforma.

#### Acceptance Criteria

1. THE App SHALL disponibilizar um formulário de criação de partida com os campos: data, hora, localização (selecionada de lista estática) e seleção de 3 outros Players para completar os dois teams (Team A e Team B).
2. THE App SHALL apresentar a lista de localizações disponíveis a partir da coleção `locations` do Firestore, usando o LocalCache quando offline.
3. THE App SHALL apresentar a lista de Players com `status: active` para seleção, excluindo o próprio criador da lista de seleção.
4. WHEN o Player submete o formulário com todos os campos válidos, THE App SHALL criar um documento na coleção `matches` com `status: scheduled`, os IDs e nomes denormalizados dos 4 jogadores, o ID e nome denormalizado da localização, e a data/hora da partida.
5. IF o formulário for submetido com campos obrigatórios em falta ou com menos de 3 jogadores selecionados, THEN THE App SHALL apresentar mensagens de validação inline antes de submeter.
6. WHILE o dispositivo está sem conectividade, THE App SHALL permitir a criação da partida escrevendo no LocalCache, e THE App SHALL sincronizar o documento com o Firestore quando a conectividade for restabelecida.
7. WHEN a partida é criada com sucesso, THE App SHALL navegar para o detalhe da partida criada.

---

### Requirement 5: Registo de Resultado (Score)

**User Story:** Como Player participante de uma partida, quero registar o resultado por sets usando o ScoreStepper, para que o resultado fique guardado e as estatísticas sejam atualizadas.

#### Acceptance Criteria

1. WHEN um Player autenticado que é o criador de uma partida com `status: scheduled` acede ao detalhe dessa partida, THE App SHALL apresentar a opção de registar o resultado.
2. THE App SHALL disponibilizar o ScoreStepper para introdução do resultado de cada set (mínimo 1 set, máximo 3 sets), com campos de pontuação para Team A e Team B por set.
3. WHEN o Player submete o resultado com pelo menos 1 set preenchido e pontuações válidas (valores inteiros não negativos), THE App SHALL atualizar o documento da partida no Firestore com os scores dos sets e alterar `status` para `completed`.
4. IF os campos de pontuação contiverem valores inválidos (não numéricos ou negativos), THEN THE App SHALL apresentar mensagens de validação inline antes de submeter.
5. WHEN o documento da partida é atualizado para `status: completed`, THE CloudFunction `onMatchFinalized` SHALL ser acionada para calcular vitórias/derrotas e atualizar atomicamente os documentos `user_stats` dos 4 jogadores participantes.
6. WHILE o dispositivo está sem conectividade, THE App SHALL permitir o registo do resultado escrevendo no LocalCache, e THE App SHALL sincronizar com o Firestore quando a conectividade for restabelecida.
7. WHEN o resultado é registado com sucesso, THE App SHALL apresentar o detalhe da partida com o resultado e `status: completed`.

---

### Requirement 6: Painel Admin: Gestão de Utilizadores

**User Story:** Como Admin, quero aprovar ou rejeitar pedidos de registo e suspender utilizadores, para que apenas membros vetados acedam à comunidade.

#### Acceptance Criteria

1. WHEN um utilizador com CustomClaim `role: admin` faz login, THE App SHALL apresentar um separador "Admin" na navegação principal, inacessível a utilizadores sem esse CustomClaim.
2. THE App SHALL apresentar no Painel Admin uma lista de utilizadores com `status: pending`, ordenada por data de registo crescente.
3. WHEN o Admin seleciona um PendingUser e confirma a aprovação, THE App SHALL invocar uma CloudFunction que atualiza o `status` do utilizador para `active` na coleção `users`.
4. WHEN o Admin seleciona um PendingUser e confirma a rejeição, THE App SHALL invocar uma CloudFunction que atualiza o `status` do utilizador para `rejected` na coleção `users`.
5. WHEN o Admin seleciona um Player com `status: active` e confirma a suspensão, THE App SHALL invocar uma CloudFunction que atualiza o `status` do utilizador para `suspended` na coleção `users`.
6. IF a operação de aprovação, rejeição ou suspensão falhar por erro de rede, THEN THE App SHALL apresentar uma mensagem de erro e manter o estado anterior do utilizador.
7. WHEN o `status` de um utilizador é alterado para `active`, THE CloudFunction SHALL atualizar as Firestore Security Rules de forma a conceder ao utilizador acesso de leitura às coleções `matches` e `locations`.

---

### Requirement 7: Painel Admin: Gestão de Localizações

**User Story:** Como Admin, quero adicionar e arquivar localizações de courts de padel, para que os Players possam selecionar locais válidos ao criar partidas.

#### Acceptance Criteria

1. THE App SHALL apresentar no Painel Admin uma lista de todas as localizações da coleção `locations`, indicando o estado ativo/arquivado de cada uma.
2. WHEN o Admin submete o formulário de nova localização com nome e morada preenchidos, THE App SHALL criar um documento na coleção `locations` com `isActive: true`.
3. IF o formulário de nova localização for submetido com campos obrigatórios em falta, THEN THE App SHALL apresentar mensagens de validação inline antes de submeter.
4. WHEN o Admin arquiva uma localização existente, THE App SHALL atualizar o campo `isActive` para `false` no documento correspondente da coleção `locations`.
5. WHILE uma localização tem `isActive: false`, THE App SHALL excluir essa localização da lista de seleção apresentada aos Players no formulário de criação de partida.

---

### Requirement 8: Offline-First e Sincronização

**User Story:** Como Player, quero usar a App em courts com má cobertura de rede, para que possa criar partidas e registar resultados sem depender de conectividade.

#### Acceptance Criteria

1. THE App SHALL ativar a persistência nativa do Firestore SDK (`persistenceEnabled: true`) no arranque, antes de qualquer operação de leitura ou escrita.
2. WHILE o dispositivo está sem conectividade, THE App SHALL processar todas as operações de leitura e escrita a partir do LocalCache sem apresentar erros de rede ao utilizador.
3. WHEN a conectividade é restabelecida, THE App SHALL sincronizar automaticamente todas as escritas pendentes no LocalCache com o Firestore, sem intervenção do utilizador.
4. WHEN a App deteta que o dispositivo está offline há mais de 48 horas, THE App SHALL apresentar um aviso não bloqueante recomendando ao utilizador que se ligue a uma rede para sincronizar os dados.
5. THE App SHALL usar o LocalCache como fonte primária para a lista de localizações, atualizando apenas as diferenças (delta) quando online.

---

### Requirement 9: Segurança e RBAC

**User Story:** Como sistema, quero garantir que apenas utilizadores autorizados acedam e modifiquem dados sensíveis, para que a integridade e privacidade da comunidade sejam preservadas.

#### Acceptance Criteria

1. THE Firestore SHALL aplicar Security Rules que impeçam utilizadores com `status: pending` ou `status: suspended` de ler ou escrever nas coleções `matches` e `locations`.
2. THE Firestore SHALL aplicar Security Rules que restrinjam operações de escrita nas coleções `users` e `locations` a utilizadores com CustomClaim `role: admin`, exceto a criação do próprio documento de registo.
3. THE Firestore SHALL aplicar Security Rules que permitam a um Player ler apenas os documentos de `matches` em que o seu `userId` consta como participante, ou todos os matches da comunidade se `status: active`.
4. THE CloudFunction SHALL ser a única entidade autorizada a atribuir ou revogar o CustomClaim `role: admin` nos tokens Firebase Auth.
5. THE App SHALL transmitir o token Firebase Auth em todas as chamadas a CloudFunctions e operações Firestore, e THE Firestore SHALL rejeitar pedidos sem token válido.

---

### Requirement 10: Performance

**User Story:** Como Player, quero que a App arranque rapidamente e responda de forma fluida, para que a experiência de uso seja agradável mesmo em dispositivos de gama média.

#### Acceptance Criteria

1. WHEN um Player autenticado abre a App com dados disponíveis no LocalCache, THE App SHALL apresentar o Dashboard em menos de 1,5 segundos após o arranque (cold-start).
2. THE App SHALL paginar as queries de histórico de partidas com um máximo de 20 documentos por página, usando cursores Firestore para navegação entre páginas.
3. THE App SHALL usar o LocalCache para servir a lista de localizações imediatamente, sem aguardar resposta do Firestore para renderizar o formulário de criação de partida.
