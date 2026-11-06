import 'package:cloud_firestore/cloud_firestore.dart';
import 'site_content_models.dart';

/// Single place that talks to Firestore. Used by BOTH the public site
/// (read-only + submitting enquiries) and the admin portal (read/write).
///
/// Firestore layout:
///   site_content/contact      → ContactInfo fields
///   site_content/home_stats   → { items: [ {value, label} ] }
///   machines/{machineId}      → MachineLocation fields
///   enquiries/{autoId}        → FranchiseEnquiry fields
///   admins/{uid}              → marks a Firebase Auth user as admin
class ContentRepository {
  ContentRepository(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> get _contactDoc =>
      _db.collection('site_content').doc('contact');
  DocumentReference<Map<String, dynamic>> get _homeStatsDoc =>
      _db.collection('site_content').doc('home_stats');
  CollectionReference<Map<String, dynamic>> get _machines =>
      _db.collection('machines');
  CollectionReference<Map<String, dynamic>> get _enquiries =>
      _db.collection('enquiries');

  // ---- Contact details ----

  Stream<ContactInfo> watchContact() =>
      _contactDoc.snapshots().map((snap) => ContactInfo.fromMap(snap.data()));

  Future<void> saveContact(ContactInfo contact) =>
      _contactDoc.set(contact.toMap());

  // ---- Home page "BiteBox in Numbers" ----

  /// Emits `null` when the admin has never saved stats (use defaults).
  Stream<List<StatItem>?> watchHomeStats() =>
      _homeStatsDoc.snapshots().map((snap) {
        final items = snap.data()?['items'];
        if (items is! List) return null;
        return items
            .whereType<Map<String, dynamic>>()
            .map(StatItem.fromMap)
            .toList();
      });

  Future<void> saveHomeStats(List<StatItem> stats) => _homeStatsDoc
      .set({'items': stats.map((s) => s.toMap()).toList()});

  // ---- Machine locations (Find Us page) ----

  Stream<List<MachineLocation>> watchMachines() =>
      _machines.snapshots().map((snap) {
        final list = snap.docs
            .map((d) => MachineLocation.fromMap(d.id, d.data()))
            .toList();
        list.sort((a, b) {
          final byDistrict = a.district.compareTo(b.district);
          return byDistrict != 0 ? byDistrict : a.name.compareTo(b.name);
        });
        return list;
      });

  /// Saves an existing machine, or creates a new one with an
  /// auto-generated id when [MachineLocation.id] is empty.
  Future<void> saveMachine(MachineLocation machine) {
    final doc = machine.id.isEmpty ? _machines.doc() : _machines.doc(machine.id);
    return doc.set(machine.toMap());
  }

  Future<void> deleteMachine(String id) => _machines.doc(id).delete();

  // ---- Franchise enquiries ----

  Future<void> submitEnquiry(FranchiseEnquiry enquiry) =>
      _enquiries.add(enquiry.toMap());

  Stream<List<FranchiseEnquiry>> watchEnquiries() => _enquiries
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(FranchiseEnquiry.fromDoc).toList());

  Future<void> deleteEnquiry(String id) => _enquiries.doc(id).delete();

  // ---- Admin access ----

  /// True when `admins/{uid}` exists. Created manually in the Firebase
  /// console for each person allowed to edit the site.
  Future<bool> isAdmin(String uid) async =>
      (await _db.collection('admins').doc(uid).get()).exists;
}
