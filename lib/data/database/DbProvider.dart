import 'dart:io';
import 'package:crypto_offline/data/repository/DbRepository/DbRepository.dart';
import 'package:crypto_offline/domain/entities/CoinEntity.dart';
import 'package:crypto_offline/domain/entities/PriceEntity.dart';
import 'package:crypto_offline/domain/entities/TransactionEntity.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

final String coinTable = "coinTable";
final String transactionTable = "transactionTable";
final String currenciesTable = "currenciesTable";
final String pricesTable = "pricesTable";
final String trastWalletTable = "trastWalletTable";

class DatabaseProvider implements DbRepository {
  DatabaseProvider();

  Database? _database;

  DatabaseProvider._();

  static final DatabaseProvider dbProvider = DatabaseProvider._();

  openDb(String name, String password) async {
    if (_database != null) {
      return _database!;
    }
    print("1!!!!!_database = $_database");
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    //"crypto_offline_db.db is our database instance name
    String path = join(documentsDirectory.path, (name + ".db"));
    print("1!!!!!_database path = $path");
    //await Sqflite.devSetDebugModeOn(true);
    _database = await openDatabase(path,
        password: password, version: 1, onCreate: initDatabase);
  }

  //This is optional, and only used for changing DB schema migrations
  void onUpgrade(Database database, int oldVersion, int newVersion) {
    if (newVersion > oldVersion) {
      initDatabase(database, oldVersion + 1);
    }
  }

  void initDatabase(Database database, int version) async {
    Batch batch = database.batch();
    batch.execute("CREATE TABLE $coinTable ("
        "coinId TEXT PRIMARY KEY,"
        "symbol TEXT,"
        "name TEXT,"
        "image TEXT,"
        "currentPrice REAL,"
        "percentChange24h REAL,"
        "percentChange7d REAL,"
        "marketCap INTEGER,"
        "rank INTEGER,"
        "price REAL,"
        "adaPrice REAL,"
        "liquidAda REAL,"
        "isRelevant INTEGER"
        ")");

    batch.execute("CREATE TABLE $currenciesTable ("
        "currencyId INTEGER PRIMARY KEY,"
        "symbol TEXT,"
        "ticker TEXT,"
        "name TEXT,"
        "updated TEXT"
        ")");

    batch.execute("CREATE TABLE $pricesTable ("
        "pricesId INTEGER PRIMARY KEY AUTOINCREMENT,"
        "date TEXT,"
        "name TEXT,"
        "symbol TEXT,"
        "cost REAL,"
        "usdPrice REAL,"
        "adaPrice REAL,"
        "eurPrice REAL,"
        "btcPrice REAL,"
        "ethPrice REAL,"
        "updated TEXT,"
        "coinId TEXT NOT NULL,"
        "percentChange24h REAL,"
        "percentChange7d REAL,"
        "marketCap INTEGER,"
        "liquidAda REAL,"
        "currencyId INTEGER,"
        "FOREIGN KEY(coinId) REFERENCES coinTable(coinId) ON DELETE CASCADE ON UPDATE CASCADE,"
        "FOREIGN KEY(currencyId) REFERENCES currenciesTable(currencyId) ON DELETE CASCADE ON UPDATE CASCADE"
        ")");

    batch.execute("CREATE TABLE $transactionTable ("
        "transactionId INTEGER PRIMARY KEY AUTOINCREMENT,"
        "cryptoTicker TEXT,"
        "type TEXT,"
        "details TEXT,"
        "timestamp TEXT,"
        "lastActiveTime TEXT,"
        "qty REAL,"
        "storedin TEXT,"
        "walletAddress TEXT,"
        "notes TEXT,"
        "price REAL,"
        "price2 REAL,"
        "usdPrice REAL,"
        "adaPrice REAL,"
        "eurPrice REAL,"
        "btcPrice REAL,"
        "ethPrice REAL,"
        "deleted INTEGER,"
        "updated TEXT,"
        "coinId TEXT NOT NULL,"
        "currencyId INTEGER,"
        "currencyId2 INTEGER,"
        "FOREIGN KEY(coinId) REFERENCES coinTable(coinId) ON DELETE CASCADE ON UPDATE CASCADE,"
        "FOREIGN KEY(currencyId) REFERENCES currenciesTable(currencyId) ON DELETE CASCADE ON UPDATE CASCADE,"
        "FOREIGN KEY(currencyId2) REFERENCES currenciesTable(currencyId) ON DELETE CASCADE ON UPDATE CASCADE"
        ")");

    batch.execute("CREATE TABLE $trastWalletTable ("
        "walletId INTEGER PRIMARY KEY AUTOINCREMENT,"
        "trastWallet TEXT UNIQUE"
        ")");
    await batch.commit();
  }

  dbMigration(String name, String password) async {
    var coins = await _database!.query(coinTable);
    var currencies = await _database!.query(currenciesTable);
    var prices = await _database!.query(pricesTable);
    var transaction = await _database!.query(transactionTable);
    var trastWallet = await _database!.query(trastWalletTable);
    print('coins !!!!!!!!!!!!!$coins');
    print('currencies !!!!!!!!!!!!!$currencies');
    print('prices !!!!!!!!!!!!!$prices');
    print('transaction !!!!!!!!!!!!!$transaction');
    print('trastWallet !!!!!!!!!!!!!$trastWallet');
    //await Sqflite.devSetDebugModeOn(true);
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, (name + ".db"));
    print('path !!!!!!!!!!!!!$path');
    // var version = await _database?.getVersion();
    Database newDB = await openDatabase(path,
        password: password, version: 1, onCreate: initDatabase);
    //await openDatabase(path, password: password, version: 1,
    //    onCreate: (Database db, int version) async {
    Batch batch = newDB.batch();
    if (coins.length != 0) {
      coins.forEach(
          (Map<String, Object?> coin) async => batch.insert(coinTable, coin,
              //where: "coinId = ?", whereArgs: [coins.indexOf(coin)],
              nullColumnHack: "coinId = ?",
              conflictAlgorithm: ConflictAlgorithm.replace));
    }
    if (currencies.length != 0) {
      currencies.forEach((Map<String, Object?> currency) async => batch.insert(
          currenciesTable, currency,
          nullColumnHack: "currencyId = ?",
          conflictAlgorithm: ConflictAlgorithm.replace));
    }
    if (prices.length != 0) {
      prices.forEach((Map<String, Object?> price) async => batch.insert(
          pricesTable, price,
          nullColumnHack: "pricesId = ?",
          conflictAlgorithm: ConflictAlgorithm.replace));
    }
    if (transaction.length != 0) {
      transaction.forEach((Map<String, Object?> transact) async => batch.insert(
          transactionTable, transact,
          nullColumnHack: "transactionId = ?",
          conflictAlgorithm: ConflictAlgorithm.replace));
    }
    if (trastWallet.length != 0) {
      trastWallet.forEach((Map<String, Object?> trast) async => batch.insert(
          trastWalletTable, trast,
          nullColumnHack: "walletId = ?",
          conflictAlgorithm: ConflictAlgorithm.replace));
    }
    await batch.commit();
    print('!!!!!!!!!!!!!SUCCESS!!!!!!!!!!!!!');
    // _database!.close();
    //newDB.close();
    //});
  }

  initDBMigration(Database database, int version) async {}

  putCoin(CoinEntity coinEntity) async {
    var result = _database!.insert(coinTable, coinEntity.toDatabaseJson());
    return result;
  }

  Future<List<CoinEntity>> getAllCoins() async {
    var result = await _database!.query(coinTable);
    List<CoinEntity> list = result.isNotEmpty
        ? result.map((c) => CoinEntity.fromDatabaseJson(c)).toList()
        : [];
    return list;
  }

  Future<CoinEntity> getCoin(String id) async {
    var result =
        await _database!.query(coinTable, where: "coinId = ?", whereArgs: [id]);
    CoinEntity? coin =
        result.isNotEmpty ? CoinEntity.fromDatabaseJson(result.first) : null;
    return coin!;
  }

  updateCoin(CoinEntity newCoinEntity) async {
    var result = await _database!.update(
        coinTable, newCoinEntity.toDatabaseJson(),
        where: "coinId = ?", whereArgs: [newCoinEntity.coinId]);
    return result;
  }

  updateCoinIsRelevant(CoinEntity newCoinEntity) async {
    var result = await _database!.rawUpdate(
        'UPDATE $coinTable SET isRelevant = ? WHERE coinId = ?',
        [newCoinEntity.isRelevant, newCoinEntity.coinId]);
    return result;
  }

  saveCoinPrice(PriceEntity priceEntity) async {
    var result = _database!.insert(pricesTable, priceEntity.toDatabaseJson());
    return result;
  }

  deleteCoin(int id) async {
    var result = await _database!
        .delete(coinTable, where: "coinId = ?", whereArgs: [id]);
    return result;
  }

  deleteAllCoin() async {
    var result = await _database!.delete(
      coinTable,
    );
    return result;
  }

  getPath() async {
    var path = _database?.path;
    return path;
  }

  Future<void> deleteDb(String path) => databaseFactory.deleteDatabase(path);

  isOpenDb() async {
    _database?.isOpen;
    print("await _database?.isOpen = ${_database?.isOpen}");
  }

  @override
  deleteTransaction(int id) async {
    var result = await _database!
        .delete(transactionTable, where: "transactionId = ?", whereArgs: [id]);
    return result;
  }

  @override
  Future<List<TransactionEntity>> getTransaction(int id) async {
    var result = await _database!
        .query(transactionTable, where: "transactionId = ?", whereArgs: [id]);
    List<TransactionEntity> list = result.isNotEmpty
        ? result.map((c) => TransactionEntity.fromDatabaseJson(c)).toList()
        : [];
    return list;
  }

  @override
  putTransaction(TransactionEntity transactionEntity) async {
    try {
      var result = _database!
          .insert(transactionTable, transactionEntity.toDatabaseJson());
      return result;
    } on Exception catch (_) {
      throw UnimplementedError();
    }
  }

  @override
  updateTransaction(
      TransactionEntity newTransactionEntity, int transactionId) async {
    var result = await _database!.update(
        transactionTable, newTransactionEntity.toDatabaseJson(),
        where: "transactionId = ?",
        whereArgs: [newTransactionEntity.transactionId]);
    return result;
  }

  @override
  Future<List<TransactionEntity>> getAllTransactionByIdCoin(String id) async {
    var result = await _database!
        .query(transactionTable, where: "coinId = ?", whereArgs: [id]);
    List<TransactionEntity> list = result.isNotEmpty
        ? result.map((c) => TransactionEntity.fromDatabaseJson(c)).toList()
        : [];
    return list;
  }

  @override
  Future<List<TransactionEntity>> getAllTransaction() async {
    var result = await _database!.query(transactionTable);
    List<TransactionEntity> list = result.isNotEmpty
        ? result.map((c) => TransactionEntity.fromDatabaseJson(c)).toList()
        : [];
    return list;
  }

  @override
  Future<List<PriceEntity>> getCoinPrices(String date) async {
    var result = await _database!
        .query(pricesTable, where: "date = ?", whereArgs: [date]);
    List<PriceEntity> list = result.isNotEmpty
        ? result.map((c) => PriceEntity.fromDatabaseJson(c)).toList()
        : [];
    return list;
  }

  @override
  Future<List<PriceEntity>> getCoinPriceById(String idCoin, String date) async {
    var result = await _database!.query(pricesTable,
        where: "coinId = ? and date = ?", whereArgs: [idCoin, date]);
    List<PriceEntity> list = result.isNotEmpty
        ? result.map((c) => PriceEntity.fromDatabaseJson(c)).toList()
        : [];
    return list;
  }

  @override
  Future<List<TrastWalletEntity>> getTrastWallet() async {
    var result = await _database!.query(trastWalletTable);
    List<TrastWalletEntity> list = result.isNotEmpty
        ? result.map((c) => TrastWalletEntity.fromDatabaseJson(c)).toList()
        : [];
    return list;
  }

  @override
  saveTrastWallet(TrastWalletEntity trastWalletEntity) async {
    var result =
        _database!.insert(trastWalletTable, trastWalletEntity.toDatabaseJson());
    return result;
  }

  @override
  Future<bool> closeDb(String name, String password) async {
    //await Sqflite.devSetDebugModeOn(true);
    bool dbClosed = false;
    if (_database != null) {
      await _database!.close();
      password = '';
      // name = '';
      _database = null;
      dbClosed = true;
    } else {
      await openDb(name, password);
      await _database!.close();
      password = '';
      // name = '';
      _database = null;
      dbClosed = true;
    }
    return dbClosed;
  }
}
