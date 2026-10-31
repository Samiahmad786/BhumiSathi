import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bhumi_saathi/features/calculator/calculator_logic.dart';

final Map<String, dynamic> _units = {
  'base': [
    {'id': 'sqft', 'sqft': '1', 'name': {'en': 'Sq Ft'}},
    {'id': 'sqm', 'sqft': '10.7639104167', 'name': {'en': 'Sq Meter'}},
    {'id': 'decimal', 'sqft': '435.6', 'name': {'en': 'Decimal'}},
    {'id': 'acre', 'sqft': '43560', 'name': {'en': 'Acre'}},
  ],
  'standards': {
    'bihar': {
      'label': 'Bihar – standard',
      'units': [
        {'id': 'katha', 'sqft': '720', 'name': {'en': 'Katha'}},
        {'id': 'dhur', 'sqft': '36', 'name': {'en': 'Dhur'}},
      ],
      'districtOverrides': {
        'muzaffarpur': {
          'label': 'Muzaffarpur – local',
          'units': {'katha': '1361.25', 'dhur': '68.0625'}
        }
      }
    }
  }
};

Decimal _row(List<ConversionRow> rows, String id) => rows.firstWhere((r) => r.unit.id == id).value;

void main() {
  final bihar = StandardResolver.resolve(_units, 'bihar', 'patna');
  UnitDef u(ConversionStandard s, String id) => s.units.firstWhere((x) => x.id == id);

  test('1 acre = 43,560 sq ft = 100 decimal', () {
    final rows = CalcEngine.convertAll(Decimal.one, u(bihar, 'acre'), bihar.units);
    expect(_row(rows, 'sqft'), Decimal.parse('43560'));
    expect(_row(rows, 'decimal'), Decimal.parse('100'));
  });

  test('1 decimal = 435.6 sq ft', () {
    final rows = CalcEngine.convertAll(Decimal.one, u(bihar, 'decimal'), bihar.units);
    expect(_row(rows, 'sqft'), Decimal.parse('435.6'));
  });

  test('no floating point drift: 0.1 acre = 10 decimal exactly', () {
    final rows = CalcEngine.convertAll(Decimal.parse('0.1'), u(bihar, 'acre'), bihar.units);
    expect(_row(rows, 'decimal'), Decimal.parse('10'));
    expect(_row(rows, 'sqft'), Decimal.parse('4356'));
  });

  test('Bihar: 1 katha = 720 sq ft = 20 dhur', () {
    final rows = CalcEngine.convertAll(Decimal.one, u(bihar, 'katha'), bihar.units);
    expect(_row(rows, 'sqft'), Decimal.parse('720'));
    expect(_row(rows, 'dhur'), Decimal.parse('20'));
  });

  test('district override is applied', () {
    final muz = StandardResolver.resolve(_units, 'bihar', 'muzaffarpur');
    expect(muz.label, 'Muzaffarpur – local');
    expect(u(muz, 'katha').sqft, Decimal.parse('1361.25'));
  });

  test('custom value override', () {
    final custom = bihar.withCustom({'katha': Decimal.parse('900')});
    final rows = CalcEngine.convertAll(Decimal.one, u(custom, 'katha'), custom.units);
    expect(_row(rows, 'sqft'), Decimal.parse('900'));
  });

  test('unknown state falls back to base units', () {
    final s = StandardResolver.resolve(_units, 'nowhere', null);
    expect(s.units.length, 4);
  });

  test('parse and Indian grouping', () {
    expect(CalcEngine.parse(''), isNull);
    expect(CalcEngine.parse('abc'), isNull);
    expect(CalcEngine.parse('1,250.5'), Decimal.parse('1250.5'));
    expect(CalcEngine.format(Decimal.parse('1234567.5')), '12,34,567.5');
    expect(CalcEngine.format(Decimal.parse('720.0000')), '720');
  });
}
