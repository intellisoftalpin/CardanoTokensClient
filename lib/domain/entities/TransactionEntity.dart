class TransactionEntity {
  late int? transactionId;
  late String? cryptoTicker;
  late String type;
  late String details;
  late String timestamp;
  late String lastActiveTime;
  late double qty;
  late String? storedin;
  late String? walletAddress;
  late String? notes;
  late double? price;
  late double? price2;
  late double? usdPrice;
  late double? adaPrice;
  late double? eurPrice;
  late double? btcPrice;
  late double? ethPrice;
  late int? deleted;
  late String? updated;
  late String coinId;
  late int? currencyId;
  late int? currencyId2;

  TransactionEntity({
    this.transactionId,
    this.cryptoTicker,
    required this.type,
    required this.details,
    required this.timestamp,
    required this.lastActiveTime,
    required this.qty,
    this.storedin,
    this.walletAddress,
    this.notes,
    this.price,
    this.price2,
    this.usdPrice,
    this.adaPrice,
    this.eurPrice,
    this.btcPrice,
    this.ethPrice,
    this.deleted,
    this.updated,
    required this.coinId,
    this.currencyId,
    this.currencyId2,
  });

  @override
  String toString() {
    return '{transactionId: $transactionId, cryptoTicker: $cryptoTicker, type: $type, details: $details, timestamp: $timestamp, qty: $qty, '
        'storedin: $storedin, walletAddress: $walletAddress, notes: $notes, usdPrice: $usdPrice, adaPrice: $adaPrice, price: $price, price2: $price2, '
        'eurPrice: $eurPrice, btcPrice: $btcPrice, ethPrice: $ethPrice, deleted: $deleted, updated: $updated, '
        'coinId: $coinId, lastActiveTime: $lastActiveTime currencyId: $currencyId, currencyId2: $currencyId2 }';
  }

  factory TransactionEntity.fromDatabaseJson(Map<String, dynamic> json) =>
      TransactionEntity(
        transactionId: json['transactionId'],
        cryptoTicker: json['cryptoTicker'],
        type: json['type'],
        details: json['details'],
        timestamp: (json['timestamp']),
        lastActiveTime: json['lastActiveTime'],
        qty: json['qty'],
        storedin: json['storedin'],
        walletAddress: json['walletAddress'],
        notes: json['notes'],
        price: json['price'],
        price2: json['price2'],
        usdPrice: json['usdPrice'],
        adaPrice: json['adaPrice'],
        eurPrice: json['eurPrice'],
        btcPrice: json['btcPrice'],
        ethPrice: json['ethPrice'],
        deleted: json['deleted'],
        updated: json['updated'],
        coinId: json['coinId'],
        currencyId: json['currencyId'],
        currencyId2: json['currencyId2'],
      );

  Map<String, dynamic> toDatabaseJson() => {
        "transactionId": this.transactionId,
        "cryptoTicker": this.cryptoTicker,
        "type": this.type,
        "details": this.details,
        "timestamp": this.timestamp,
        "lastActiveTime": this.lastActiveTime,
        "qty": this.qty,
        "storedin": this.storedin,
        "walletAddress": this.walletAddress,
        "notes": this.notes,
        "price": this.price,
        "price2": this.price2,
        "usdPrice": this.usdPrice,
        "adaPrice": this.adaPrice,
        "eurPrice": this.eurPrice,
        "btcPrice": this.btcPrice,
        "ethPrice": this.ethPrice,
        "deleted": this.deleted,
        "updated": this.updated,
        "coinId": this.coinId,
        "currencyId": this.currencyId,
        "currencyId2": this.currencyId2
      };

  List<Object?> get props => [
        transactionId,
        cryptoTicker,
        type,
        details,
        timestamp,
        lastActiveTime,
        qty,
        storedin,
        walletAddress,
        notes,
        price,
        price2,
        usdPrice,
        adaPrice,
        eurPrice,
        btcPrice,
        ethPrice,
        deleted,
        updated,
        coinId,
        currencyId,
        currencyId2,
      ];
}

class TrastWalletEntity {
  late String? trastWallet;

  TrastWalletEntity({
    this.trastWallet,
  });

  @override
  String toString() {
    return '{trastWallet: $trastWallet }';
  }

  factory TrastWalletEntity.fromDatabaseJson(Map<String, dynamic> json) =>
      TrastWalletEntity(
        trastWallet: json['trastWallet'],
      );

  Map<String, dynamic> toDatabaseJson() => {
        "trastWallet": this.trastWallet,
      };

  List<Object?> get props => [
        trastWallet,
      ];
}
