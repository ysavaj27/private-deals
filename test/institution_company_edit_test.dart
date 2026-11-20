import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/features/institution/companies/presentation/company_list/company_list_page_ctrl.dart';
import 'package:private_deals/src/features/institution/data/institution_endpoints.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'package:private_deals/src/features/institution/data/models/company/company_model.dart';
import 'package:private_deals/src/features/institution/institution_routes.dart';

void main() {
  test('company update and events endpoints match handoff', () {
    expect(
      InstitutionEndpoints.updateCompany,
      'v2/business/institution/company/update',
    );
    expect(
      InstitutionEndpoints.companyEvents,
      'v2/business/institution/company/events',
    );
    expect(
      InstitutionEndpoints.updateCompanyEvent,
      'v2/business/institution/company/events/update',
    );
    expect(
      InstitutionEndpoints.deleteCompanyEvent,
      'v2/business/institution/company/events/delete',
    );
  });

  test('edit and events routes preserve company type and slug', () {
    expect(
      CompanyRouteContext.fromPath(
        '/institution/companies/unlisted/acme-co/edit',
      ).type,
      CompanyType.unlisted,
    );
    expect(
      CompanyRouteContext.fromPath(
        '/institution/companies/secondary/acme-co/events',
      ).type,
      CompanyType.secondary,
    );
    expect(
      InstitutionRoutes.companyAction(
        InstitutionRoutes.editCompanyPage,
        type: 'unlisted',
        slug: 'acme co',
      ),
      '/institution/companies/unlisted/acme%20co/edit',
    );
    expect(
      InstitutionRoutes.companyAction(
        InstitutionRoutes.eventsPage,
        type: 'secondary',
        slug: 'acme',
      ),
      '/institution/companies/secondary/acme/events',
    );
  });

  test('company detail parsing fills edit form source fields', () {
    final company = CompanyModel.fromJson({
      'id': 42,
      'slug': 'acme',
      'brand_name': 'Acme',
      'company_name': 'Acme Private Limited',
      'cin': 'U12345MH2020PTC123456',
      'about': 'Builds widgets',
      'min_investment_amount': 35000,
      'alternative_names': 'Acme, Acme Ltd',
      'list_order': '10',
      'is_editable': true,
      'sector': {'id': 7, 'name': 'Tech'},
      'fundamentals': {
        'lot_size': 100,
        'market_cap': 12.5,
        'pe_ratio': 25.5,
        'pb_ratio': 3.2,
        'debt_to_equity': 0.45,
        'roe': 18.5,
        'book_value': 120,
        'face_value': 10,
        'depository': 'NSDL',
        'pan_number': 'ABCDE1234F',
        'isin_number': 'INE123A01016',
        'rta': 'Link',
        'total_shares': 1000000,
      },
    });

    expect(company.id, 42);
    expect(company.isEditable, isTrue);
    expect(company.about, 'Builds widgets');
    expect(company.minInvestmentAmount, 35000);
    expect(company.alternativeNames, 'Acme, Acme Ltd');
    expect(company.listOrder, '10');
    expect(company.fundamentals.marketCap, 12.5);
    expect(company.fundamentals.peRatio, 25.5);
    expect(company.fundamentals.panNumber, 'ABCDE1234F');
    expect(company.fundamentals.totalShares, 1000000);
  });

  test('is_editable accepts common API truthy forms', () {
    expect(CompanyModel.fromJson({'is_editable': 1}).isEditable, isTrue);
    expect(CompanyModel.fromJson({'is_editable': '1'}).isEditable, isTrue);
    expect(CompanyModel.fromJson({'is_editable': 'true'}).isEditable, isTrue);
    expect(CompanyModel.fromJson({'is_editable': 0}).isEditable, isFalse);
    expect(CompanyModel.fromJson({}).isEditable, isFalse);
  });

  test('detail root financial fields merge into fundamentals', () {
    final company = CompanyModel.fromJson({
      'id': 5,
      'about': 'Root about',
      'min_investment_amount': 1000,
      'lot_size': 50,
      'market_cap': 8,
      'pe_ratio': 11,
      'fundamentals': {'pb_ratio': 2.1},
    });

    expect(company.about, 'Root about');
    expect(company.minInvestmentAmount, 1000);
    expect(company.fundamentals.lotSize, 50);
    expect(company.fundamentals.marketCap, 8);
    expect(company.fundamentals.peRatio, 11);
    expect(company.fundamentals.pbRatio, 2.1);
  });

  test('company event model prefers file_url for download', () {
    final event = CompanyEventModel.fromJson({
      'id': 9,
      'date': '19-11-2026',
      'title': 'Board update',
      'description': 'Quarterly note',
      'file': 'legacy.pdf',
      'file_url': 'https://cdn.example/events/note.pdf',
    });

    expect(event.id, 9);
    expect(event.title, 'Board update');
    expect(event.date, DateTime(2026, 11, 19));
    expect(event.downloadUrl, 'https://cdn.example/events/note.pdf');
  });
}
