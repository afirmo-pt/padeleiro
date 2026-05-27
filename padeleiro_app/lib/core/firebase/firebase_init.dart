import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Inicializa o Firebase e configura a persistência offline do Firestore.
///
/// Deve ser chamado em [main] antes de [runApp], após
/// [WidgetsFlutterBinding.ensureInitialized].
Future<void> initializeFirebase() async {
  await Firebase.initializeApp();

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
}
