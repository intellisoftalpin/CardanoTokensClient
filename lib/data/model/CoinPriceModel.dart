
import 'CurrentPrice.dart';

class CoinPriceModel {
  CoinPriceModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.localization,
    required this.marketData,

  });
  late final String id;
  late final String symbol;
  late final String name;
  late final Localization localization;
  late final MarketData marketData;

  CoinPriceModel.fromJson(Map<String, dynamic> json){
    id = json['id'];
    symbol = json['symbol'];
    name = json['name'];
    localization = Localization.fromJson(json['localization']);
    marketData = MarketData.fromJson(json['market_data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['symbol'] = symbol;
    _data['name'] = name;
    _data['localization'] = localization.toJson();
    _data['market_data'] = marketData.toJson();
    return _data;
  }

  @override
  String toString() {
    return '{id: $id, name: $name, symbol: $symbol, localization: $localization, '
        'marketData: $marketData,}';
  }
}

class Localization {
  Localization({
    required this.en,
    required this.de,
    required this.es,
    required this.fr,
    required this.it,
    required this.pl,
    required this.ro,
    required this.hu,
    required this.nl,
    required this.pt,
    required this.sv,
    required this.vi,
    required this.tr,
    required this.ru,
  });
  late final String en;
  late final String de;
  late final String es;
  late final String fr;
  late final String it;
  late final String pl;
  late final String ro;
  late final String hu;
  late final String nl;
  late final String pt;
  late final String sv;
  late final String vi;
  late final String tr;
  late final String ru;

  Localization.fromJson(Map<String, dynamic> json){
    en = json['en'];
    de = json['de'];
    es = json['es'];
    fr = json['fr'];
    it = json['it'];
    pl = json['pl'];
    ro = json['ro'];
    hu = json['hu'];
    nl = json['nl'];
    pt = json['pt'];
    sv = json['sv'];
    vi = json['vi'];
    tr = json['tr'];
    ru = json['ru'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['en'] = en;
    _data['de'] = de;
    _data['es'] = es;
    _data['fr'] = fr;
    _data['it'] = it;
    _data['pl'] = pl;
    _data['ro'] = ro;
    _data['hu'] = hu;
    _data['nl'] = nl;
    _data['pt'] = pt;
    _data['sv'] = sv;
    _data['vi'] = vi;
    _data['tr'] = tr;
    _data['ru'] = ru;
    return _data;
  }

  @override
  String toString() {
    return '{en: $en, de: $de, fr: $fr, ru: $ru,}';
  }
}

class MarketData {
  MarketData({
    required this.currentPrice,

  });
  late final CurrentPrice currentPrice;


  MarketData.fromJson(Map<String, dynamic> json){
    currentPrice = CurrentPrice.fromJson(json['current_price']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['current_price'] = currentPrice.toJson();
    return _data;
  }
  @override
  String toString() {
    return '{currentPrice: $currentPrice,}';
  }
}
