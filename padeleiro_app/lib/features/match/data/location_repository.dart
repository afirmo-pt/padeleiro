import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/location.dart';

// ---------------------------------------------------------------------------
// CreateLocationPayload
// ---------------------------------------------------------------------------

/// Dados necessários para criar uma nova localização.
class CreateLocationPayload {
  const CreateLocationPayload({
    required this.name,
    required this.address,
  });

  final String name;
  final String address;
}

// ---------------------------------------------------------------------------
// Abstract interface
// ---------------------------------------------------------------------------

abstract class LocationRepository {
  /// Stream de localizações activas (isActive == true).
  /// Usado na seleção de localização ao criar uma partida.
  Stream<List<Location>> watchActiveLocations();

  /// Stream de todas as localizações, sem filtro.
  /// Apenas para uso no Painel Admin.
  Stream<List<Location>> watchAllLocations();

  /// Cria um novo documento na coleção `locations` com isActive: true.
  Future<void> createLocation(CreateLocationPayload payload);

  /// Actualiza isActive para false no documento `locations/{locationId}`.
  Future<void> archiveLocation(String locationId);
}

// ---------------------------------------------------------------------------
// Firebase implementation
// ---------------------------------------------------------------------------

class FirebaseLocationRepository implements LocationRepository {
  FirebaseLocationRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _locations =>
      _firestore.collection('locations');

  @override
  Stream<List<Location>> watchActiveLocations() {
    return _locations
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Location.fromMap(doc.id, doc.data()))
            .toList());
  }

  @override
  Stream<List<Location>> watchAllLocations() {
    return _locations
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Location.fromMap(doc.id, doc.data()))
            .toList());
  }

  @override
  Future<void> createLocation(CreateLocationPayload payload) async {
    await _locations.add({
      'name': payload.name,
      'address': payload.address,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> archiveLocation(String locationId) async {
    await _locations.doc(locationId).update({'isActive': false});
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

/// Provider que expõe a implementação Firebase de [LocationRepository].
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return FirebaseLocationRepository();
});
