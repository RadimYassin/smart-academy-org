import '../../data/datasources/certificate_remote_datasource.dart';
import '../../data/models/certificate/certificate.dart';
import '../../domain/repositories/certificate_repository.dart';

class CertificateRepositoryImpl implements CertificateRepository {
  final CertificateRemoteDataSource remoteDataSource;

  CertificateRepositoryImpl(this.remoteDataSource);

  @override
  Future<CertificateEligibility> checkEligibility(String courseId) async {
    try {
      return await remoteDataSource.checkEligibility(courseId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Certificate> generateCertificate(String courseId) async {
    try {
      return await remoteDataSource.generateCertificate(courseId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Certificate>> getMyCertificates() async {
    try {
      return await remoteDataSource.getMyCertificates();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Certificate> getCertificate(String certificateId) async {
    try {
      return await remoteDataSource.getCertificate(certificateId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<int>> downloadCertificate(String certificateId) async {
    try {
      return await remoteDataSource.downloadCertificate(certificateId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CertificateVerification> verifyCertificate(String verificationCode) async {
    try {
      return await remoteDataSource.verifyCertificate(verificationCode);
    } catch (e) {
      rethrow;
    }
  }
}
