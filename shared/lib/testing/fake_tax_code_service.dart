import 'package:shared/models/tax_code_response.dart';
import 'package:shared/services/birthplace_service.dart';
import 'package:shared/services/tax_code_service.dart';
import 'package:shared/testing/test_contact_fixtures.dart';
import 'package:shared/utils/tax_code_generator.dart';

/// Fake implementation of [TaxCodeService] for testing and previews.
class FakeTaxCodeService implements TaxCodeService {
  final BirthplaceService? _birthplaceService;

  FakeTaxCodeService({BirthplaceService? birthplaceService})
    : _birthplaceService = birthplaceService;

  @override
  Future<TaxCodeResponse> fetchTaxCode({
    required String firstName,
    required String lastName,
    required String gender,
    required String birthPlaceName,
    required String birthPlaceState,
    required DateTime birthDate,
  }) async {
    final birthplaces = _birthplaceService != null
        ? await _birthplaceService.loadBirthplaces()
        : TestContactFixtures.sampleBirthplaces;

    final birthplace = birthplaces.firstWhere(
      (b) =>
          b.name.toLowerCase() == birthPlaceName.toLowerCase() &&
          b.state.toLowerCase() == birthPlaceState.toLowerCase(),
      orElse: () => throw const BirthplaceNotFoundFailure(),
    );

    final fiscalCode = TaxCodeGenerator.generate(
      firstName: firstName,
      lastName: lastName,
      gender: gender,
      birthplaceCode: birthplace.code,
      dateOfBirth: birthDate,
    );

    return TaxCodeResponse(
      status: true,
      message: 'OK',
      data: TaxCodeData(fiscalCode: fiscalCode),
    );
  }
}
