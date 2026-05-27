import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:padeleiro_app/models/enums.dart';

/// Timestamp da última sincronização confirmada com o Firestore.
///
/// `null` significa que ainda não houve nenhuma sincronização nesta sessão.
final lastSyncProvider = StateProvider<DateTime?>((ref) => null);

/// Estado actual de sincronização da aplicação.
final syncStatusProvider = StateProvider<SyncStatus>((ref) => SyncStatus.synced);

/// Devolve `true` se a última sincronização foi há mais de 48 horas,
/// ou se nunca houve sincronização.
///
/// Utilizar nas screens para apresentar um SnackBar não bloqueante:
/// ```dart
/// if (ref.read(isOfflineTooLongProvider)) {
///   ScaffoldMessenger.of(context).showSnackBar(
///     const SnackBar(content: Text('Sem ligação há mais de 48h')),
///   );
/// }
/// ```
bool isOfflineTooLong(DateTime? lastSync) {
  if (lastSync == null) return false;
  return DateTime.now().difference(lastSync) > const Duration(hours: 48);
}

/// Provider derivado que expõe directamente o resultado da verificação de 48h.
final isOfflineTooLongProvider = Provider<bool>((ref) {
  final lastSync = ref.watch(lastSyncProvider);
  return isOfflineTooLong(lastSync);
});
