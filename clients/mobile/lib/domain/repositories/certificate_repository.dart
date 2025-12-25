import '../models/certificate/certificate.dart';

abstract class CertificateRepository {
  /// Check if student is eligible for certificate
  Future<CertificateEligibility> checkEligibility(String courseId);

  /// Generate certificate for completed course
  Future<Certificate> generateCertificate(String courseId);

  /// Get all certificates for current user
  Future<List<Certificate>> getMyCertificates();

  /// Get specific certificate details
  Future<Certificate> getCertificate(String certificateId);

  /// Download certificate as PDF (returns bytes)
  Future<List<int>> downloadCertificate(String certificateId);

  /// Verify certificate authenticity (public - no auth required)
  Future<CertificateVerification> verifyCertificate(String verificationCode);
}
