import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo1/features/preauth/pre_home/data/models/monthly_income_params_model.dart';

class PreHomeLocalDataSource {
  static const _kConn = 'prehome_connections';
  static const _kMonths = 'prehome_payout_months';
  static const _kPrice = 'prehome_app_price';
  static const _kRate = 'prehome_commission_rate';
  MonthlyIncomeParamsModel? _last;
  MonthlyIncomeParamsModel? get last => _last;
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final hasConn = prefs.containsKey(_kConn);
    final hasMonths = prefs.containsKey(_kMonths);
    if (hasConn && hasMonths) {
      _last = MonthlyIncomeParamsModel(
        connections: prefs.getInt(_kConn) ?? 12,
        payoutMonths: prefs.getInt(_kMonths) ?? 36,
        appPrice: (prefs.getDouble(_kPrice) ?? 20000.0),
        commissionRate: (prefs.getDouble(_kRate) ?? 0.10),
      );
    }
  }
  void save(MonthlyIncomeParamsModel params) {
    _last = params;
    SharedPreferences.getInstance().then((p) {
      p.setInt(_kConn, params.connections);
      p.setInt(_kMonths, params.payoutMonths);
      p.setDouble(_kPrice, params.appPrice);
      p.setDouble(_kRate, params.commissionRate);
    });
  }
}