class Activity {
  final String id;
  final String popId;
  final String action;
  final String popName;
  final String popNumber;
  final String owner;
  final String actor;
  final String details;
  final DateTime timestamp;

  const Activity({
    required this.id,
    this.popId = '',
    required this.action,
    required this.popName,
    required this.popNumber,
    required this.owner,
    required this.actor,
    required this.details,
    required this.timestamp,
  });

  factory Activity.fromJson(
      Map<String, dynamic> json,
      ) {
    return Activity(
      id: json['id'] ?? '',
      popId: json['popId'] ?? '',
      action: json['action'] ?? '',
      popName: json['popName'] ?? '',
      popNumber: json['popNumber'] ?? '',
      owner: json['owner'] ?? '',
      actor: json['actor'] ?? '',
      details: json['details'] ?? '',
      timestamp: DateTime.tryParse(
        json['timestamp'] ?? '',
      ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'popId': popId,
      'action': action,
      'popName': popName,
      'popNumber': popNumber,
      'owner': owner,
      'actor': actor,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}