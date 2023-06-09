
import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class CoinEntity extends Equatable {
  late String coinId;
  late String symbol;
  late String name;
  late String? image;
  late double currentPrice;
  late double? percentChange24h;
  late double? percentChange7d;
  late int? marketCap;
  late int? rank;
  late double? price;
  late double? adaPrice;
  late double? liquidAda;
  late int isRelevant;

  CoinEntity({
    required this.coinId,
    required this.name,
    required this.symbol,
    required this.image,
    required this.currentPrice,
    required this.percentChange24h,
    required this.percentChange7d,
    required this.marketCap,
    required this.rank,
    required this.price,
    required this.adaPrice,
    required this.liquidAda,
    required this.isRelevant,
  });

  factory CoinEntity.fromDatabaseJson(Map<String, dynamic> data) => CoinEntity(
    coinId: data['coinId'],
    name: data['name'],
    symbol: data['symbol'],
    image: data['image'],
    currentPrice: data['currentPrice'],
    percentChange24h: data['percentChange24h'],
    percentChange7d: data['percentChange7d'],
    marketCap: data['marketCap'],
    rank: data['rank'],
    price: data['price'],
    adaPrice: data['adaPrice'],
    liquidAda: data['liquidAda'],
    isRelevant: data['isRelevant'],
  );

  Map<String, dynamic> toDatabaseJson() => {
    "coinId": this.coinId,
    "name": this.name,
    "symbol": this.symbol,
    "image": this.image,
    "currentPrice": this.currentPrice,
    "percentChange24h": this.percentChange24h,
    "percentChange7d": this.percentChange7d,
    "marketCap": this.marketCap,
    "rank": this.rank,
    "price": this.price,
    "adaPrice": this.adaPrice,
    "liquidAda": this.liquidAda,
    "isRelevant": this.isRelevant,
  };

  List<Object?> get props => [
    coinId,
    name,
    symbol,
    image,
    currentPrice,
    percentChange24h,
    percentChange7d,
    marketCap,
    rank,
    price,
    adaPrice,
    liquidAda,
    isRelevant
  ];
}