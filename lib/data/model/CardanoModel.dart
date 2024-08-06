
class CardanoModel {
  String? updated;
  double? usd;
  double? eur;
  double? btc;
  int? eth;
  List<Tokens>? tokens;

  CardanoModel(
      {this.updated, this.usd, this.eur, this.btc, this.eth, this.tokens});

  CardanoModel.fromJson(Map<String, dynamic> json) {
    updated = json['updated'];
    usd = json['usd'];
    eur = json['eur'];
    btc = json['btc'];
    eth = json['eth'];
    if (json['tokens'] != null) {
      tokens = <Tokens>[];
      json['tokens'].forEach((v) {
        tokens!.add(new Tokens.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['updated'] = this.updated;
    data['usd'] = this.usd;
    data['eur'] = this.eur;
    data['btc'] = this.btc;
    data['eth'] = this.eth;
    if (this.tokens != null) {
      data['tokens'] = this.tokens!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  String toString() {
    return '{updated: $updated, usd: $usd, eur: $eur, btc: $btc, eth: $eth, tokens: $tokens}';
  }
}

class Tokens {
  String? tokenId;
  String? name;
  String? altNames;
  double? priceAda;
  double? priceUsd;
  String? policyId;
  String? assetId;
  String? assetName;
  String? tokenLink;
  int? decimals;
  String? description;
  String? explorerLink;
  double? priceTrend24h;
  double? priceTrend7d;
  double? priceTrend30d;
  double? totalSupply;
  double? capAda;
  double? capUsd;
  double? liquidAda;
  List<String>? exchanges;

  Tokens(
      {this.tokenId,
        this.name,
        this.altNames,
        this.priceAda,
        this.priceUsd,
        this.policyId,
        this.assetId,
        this.assetName,
        this.tokenLink,
        this.decimals,
        this.description,
        this.explorerLink,
        this.priceTrend24h,
        this.priceTrend7d,
        this.priceTrend30d,
        this.totalSupply,
        this.capAda,
        this.capUsd,
        this.liquidAda,
        this.exchanges});

  Tokens.fromJson(Map<String, dynamic> json) {
    tokenId = json['token_id'];
    name = json['name'];
    altNames = json['alt_names'];
    priceAda = json['price_ada'] / 1;
    priceUsd = json['price_usd'] / 1;
    policyId = json['policy_id'];
    assetId = json['asset_id'];
    assetName = json['asset_name'];
    tokenLink = json['token_link'];
    decimals = json['decimals'];
    description = json['description'];
    explorerLink = json['explorer_link'];
    priceTrend24h = json['price_trend_24h'] / 1;
    priceTrend7d = json['price_trend_7d'] /1;
    priceTrend30d = json['price_trend_30d'] /1;
    totalSupply = json['total_supply'] / 1;
    capAda = json['cap_ada'] / 1;
    capUsd = json['cap_usd'] / 1;
    liquidAda = json['locked_liquidity_ada'] / 1;
    exchanges = json['exchanges'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token_id'] = this.tokenId;
    data['name'] = this.name;
    data['alt_names'] = this.altNames;
    data['price_ada'] = this.priceAda;
    data['price_usd'] = this.priceUsd;
    data['policy_id'] = this.policyId;
    data['asset_id'] = this.assetId;
    data['asset_name'] = this.assetName;
    data['token_link'] = this.tokenLink;
    data['decimals'] = this.decimals;
    data['description'] = this.description;
    data['explorer_link'] = this.explorerLink;
    data['price_trend_24h'] = this.priceTrend24h;
    data['price_trend_7d'] = this.priceTrend7d;
    data['price_trend_30d'] = this.priceTrend30d;
    data['total_supply'] = this.totalSupply;
    data['cap_ada'] = this.capAda;
    data['cap_usd'] = this.capUsd;
    data['locked_liquidity_ada'] = this.liquidAda;
    data['exchanges'] = this.exchanges;
    return data;
  }

  @override
  String toString() {
    return '{token_id: $tokenId, name: $name, alt_names: $altNames, price_ada: $priceAda,'
        'price_usd: $priceUsd, policy_id: $policyId, asset_id: $assetId, asset_name: $assetName,'
        'token_link: $tokenLink, decimals: $decimals, description: $description, explorer_link: $explorerLink'
        'price_trend_24h: $priceTrend24h, price_trend_7d: $priceTrend7d, price_trend_30d: $priceTrend30d, '
        'total_supply: $totalSupply, cap_ada: $capAda, cap_usd: $capUsd, locked_liquidity_ada: $liquidAda, exchanges: $exchanges}';
  }
}