import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'content_repository.dart';
import 'site_content_models.dart';

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => ContentRepository(FirebaseFirestore.instance),
);

/// Live streams from Firestore. Screens should read them with
/// `.valueOrNull ?? SiteDefaults.x` so the page always renders something.
final contactInfoProvider = StreamProvider<ContactInfo>(
  (ref) => ref.watch(contentRepositoryProvider).watchContact(),
);

final homeStatsProvider = StreamProvider<List<StatItem>?>(
  (ref) => ref.watch(contentRepositoryProvider).watchHomeStats(),
);

final machinesProvider = StreamProvider<List<MachineLocation>>(
  (ref) => ref.watch(contentRepositoryProvider).watchMachines(),
);

final enquiriesProvider = StreamProvider<List<FranchiseEnquiry>>(
  (ref) => ref.watch(contentRepositoryProvider).watchEnquiries(),
);

// Convenience providers for the public site: always return usable data.

final contactProvider = Provider<ContactInfo>(
  (ref) => ref.watch(contactInfoProvider).valueOrNull ?? SiteDefaults.contact,
);

final publicHomeStatsProvider = Provider<List<StatItem>>(
  (ref) => ref.watch(homeStatsProvider).valueOrNull ?? SiteDefaults.homeStats,
);

