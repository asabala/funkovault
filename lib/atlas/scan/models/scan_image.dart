// Describes the role an image plays within an Atlas scan session.
enum ScanImageType {
  original,
  processed,
  thumbnail,
  frontBox,
  backBox,
  bottomBox,
  barcode,
  sticker,
  autograph,
  certification,
  condition,
  unknown,
}

// Describes the current processing state of a scan image.
enum ScanImageStatus {
  captured,
  queued,
  uploading,
  uploaded,
  processing,
  processed,
  approved,
  rejected,
  failed,
}

// Immutable image reference associated with a scan session.
//
// Images may initially exist only on the local device. Remote storage
// information can be added later after upload or synchronization.
class ScanImage {
  const ScanImage({
    required this.imageId,
    required this.type,
    required this.status,
    required this.capturedAt,
    this.localPath,
    this.remoteUrl,
    this.mimeType,
    this.width,
    this.height,
    this.byteSize,
    this.imageFingerprint,
    this.processingNotes = const [],
  });

  final String imageId;

  final ScanImageType type;

  final ScanImageStatus status;

  final DateTime capturedAt;

  final String? localPath;

  final String? remoteUrl;

  final String? mimeType;

  final int? width;

  final int? height;

  final int? byteSize;

  final String? imageFingerprint;

  final List<String> processingNotes;

  bool get hasLocalPath {
    return localPath != null && localPath!.trim().isNotEmpty;
  }

  bool get hasRemoteUrl {
    return remoteUrl != null && remoteUrl!.trim().isNotEmpty;
  }

  bool get hasFingerprint {
    return imageFingerprint != null && imageFingerprint!.trim().isNotEmpty;
  }

  bool get isAvailable {
    return hasLocalPath || hasRemoteUrl;
  }

  bool get isOriginal {
    return type == ScanImageType.original;
  }

  bool get isProcessed {
    return status == ScanImageStatus.processed ||
        status == ScanImageStatus.approved;
  }

  bool get requiresSync {
    return hasLocalPath && !hasRemoteUrl;
  }

  ScanImage copyWith({
    String? imageId,
    ScanImageType? type,
    ScanImageStatus? status,
    DateTime? capturedAt,
    String? localPath,
    String? remoteUrl,
    String? mimeType,
    int? width,
    int? height,
    int? byteSize,
    String? imageFingerprint,
    List<String>? processingNotes,
  }) {
    return ScanImage(
      imageId: imageId ?? this.imageId,
      type: type ?? this.type,
      status: status ?? this.status,
      capturedAt: capturedAt ?? this.capturedAt,
      localPath: localPath ?? this.localPath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      mimeType: mimeType ?? this.mimeType,
      width: width ?? this.width,
      height: height ?? this.height,
      byteSize: byteSize ?? this.byteSize,
      imageFingerprint: imageFingerprint ?? this.imageFingerprint,
      processingNotes: processingNotes ?? this.processingNotes,
    );
  }
}
