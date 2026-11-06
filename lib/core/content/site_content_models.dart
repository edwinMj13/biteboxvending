import 'package:cloud_firestore/cloud_firestore.dart';

/// Contact details shown across the public site (header, footer,
/// Get In Touch page, franchise enquiry). Edited from the admin portal.
///
/// Firestore: `site_content/contact`
class ContactInfo {
  final String phone; // Display + dial number, e.g. "+91 81290 37133"
  final String whatsappNumber; // Digits with country code, e.g. "918129037133"
  final String email; // General support email
  final String franchiseEmail; // Where franchise enquiries are emailed
  final String address;
  final String instagramUrl;
  final String facebookUrl;

  const ContactInfo({
    required this.phone,
    required this.whatsappNumber,
    required this.email,
    required this.franchiseEmail,
    required this.address,
    required this.instagramUrl,
    required this.facebookUrl,
  });

  /// `tel:` friendly version of [phone] (spaces and dashes removed).
  String get phoneDial => phone.replaceAll(RegExp(r'[^\d+]'), '');

  /// WhatsApp chat link, optionally pre-filled with [text].
  String whatsappUrl([String? text]) {
    final digits = whatsappNumber.replaceAll(RegExp(r'\D'), '');
    if (text == null || text.isEmpty) return 'https://wa.me/$digits';
    return 'https://wa.me/$digits?text=${Uri.encodeComponent(text)}';
  }

  factory ContactInfo.fromMap(Map<String, dynamic>? map) {
    const d = SiteDefaults.contact;
    if (map == null) return d;
    String read(String key, String fallback) {
      final value = map[key];
      return value is String && value.trim().isNotEmpty ? value : fallback;
    }

    return ContactInfo(
      phone: read('phone', d.phone),
      whatsappNumber: read('whatsappNumber', d.whatsappNumber),
      email: read('email', d.email),
      franchiseEmail: read('franchiseEmail', d.franchiseEmail),
      address: read('address', d.address),
      // Social links may be intentionally cleared, so don't fall back.
      instagramUrl: (map['instagramUrl'] as String?) ?? d.instagramUrl,
      facebookUrl: (map['facebookUrl'] as String?) ?? d.facebookUrl,
    );
  }

  Map<String, dynamic> toMap() => {
        'phone': phone,
        'whatsappNumber': whatsappNumber,
        'email': email,
        'franchiseEmail': franchiseEmail,
        'address': address,
        'instagramUrl': instagramUrl,
        'facebookUrl': facebookUrl,
      };
}

/// A single figure in the "BiteBox in Numbers" section of the home page.
///
/// Firestore: `site_content/home_stats` → `{ items: [ {value, label}, ... ] }`
class StatItem {
  final String value; // e.g. "50+"
  final String label; // e.g. "Active Machines"

  const StatItem({required this.value, required this.label});

  factory StatItem.fromMap(Map<String, dynamic> map) => StatItem(
        value: (map['value'] as String?) ?? '',
        label: (map['label'] as String?) ?? '',
      );

  Map<String, dynamic> toMap() => {'value': value, 'label': label};
}

enum MachineStatus {
  stocked('Online & Stocked'),
  lowStock('Low Stock'),
  offline('Maintenance');

  final String label;
  const MachineStatus(this.label);

  static MachineStatus fromName(String? name) => MachineStatus.values
      .firstWhere((s) => s.name == name, orElse: () => MachineStatus.stocked);
}

/// A vending machine shown on the Find Us page.
///
/// Firestore: `machines/{id}`
class MachineLocation {
  final String id; // Firestore document id (empty for a new machine)
  final String name;
  final String district;
  final String address;
  final String landmark;
  final MachineStatus status;

  const MachineLocation({
    required this.id,
    required this.name,
    required this.district,
    required this.address,
    required this.landmark,
    required this.status,
  });

  factory MachineLocation.fromMap(String id, Map<String, dynamic> map) =>
      MachineLocation(
        id: id,
        name: (map['name'] as String?) ?? '',
        district: (map['district'] as String?) ?? '',
        address: (map['address'] as String?) ?? '',
        landmark: (map['landmark'] as String?) ?? '',
        status: MachineStatus.fromName(map['status'] as String?),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'district': district,
        'address': address,
        'landmark': landmark,
        'status': status.name,
      };
}

/// How the visitor chose to send their franchise enquiry.
enum EnquiryChannel {
  whatsapp('WhatsApp'),
  email('Email'),
  direct('Website form');

  final String label;
  const EnquiryChannel(this.label);

  static EnquiryChannel fromName(String? name) => EnquiryChannel.values
      .firstWhere((c) => c.name == name, orElse: () => EnquiryChannel.direct);
}

/// A franchise enquiry submitted from the public Franchise page.
///
/// Firestore: `enquiries/{autoId}`
class FranchiseEnquiry {
  final String? id;
  final String name;
  final String email;
  final String phone;
  final String location;
  final String message;
  final EnquiryChannel channel;
  final DateTime? createdAt;

  const FranchiseEnquiry({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.message,
    required this.channel,
    this.createdAt,
  });

  /// Plain-text summary used for the WhatsApp / email body.
  String toMessageText() => [
        'New BiteBox Franchise Enquiry',
        '',
        'Name: $name',
        'Email: $email',
        'Phone: $phone',
        'Preferred Location: $location',
        if (message.isNotEmpty) ...['', 'Additional Information:', message],
      ].join('\n');

  factory FranchiseEnquiry.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final map = doc.data() ?? const {};
    return FranchiseEnquiry(
      id: doc.id,
      name: (map['name'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      phone: (map['phone'] as String?) ?? '',
      location: (map['location'] as String?) ?? '',
      message: (map['message'] as String?) ?? '',
      channel: EnquiryChannel.fromName(map['channel'] as String?),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'phone': phone,
        'location': location,
        'message': message,
        'channel': channel.name,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

/// Built-in content. The public site falls back to these values while
/// Firestore is loading, unreachable, or before the admin has saved anything.
class SiteDefaults {
  static const contact = ContactInfo(
    phone: '+91 81290 37133',
    whatsappNumber: '918129037133',
    email: 'biteboxkochi@gmail.com',
    franchiseEmail: 'biteboxkochi@gmail.com',
    address: 'BiteBox 24/7 Vending, Kochi, Kerala, India',
    instagramUrl: 'https://www.instagram.com/biteboxkochi',
    facebookUrl: '',
  );

  static const homeStats = [
    StatItem(value: '50+', label: 'Active Machines'),
    StatItem(value: '10K+', label: 'Daily Happy Customers'),
    StatItem(value: '150+', label: 'Products Stocked'),
    StatItem(value: '4+', label: 'Districts Covered'),
  ];
}
