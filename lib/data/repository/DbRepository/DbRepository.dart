import 'package:crypto_offline/domain/entities/CoinEntity.dart';
import 'package:crypto_offline/domain/entities/PriceEntity.dart';
import 'package:crypto_offline/domain/entities/TransactionEntity.dart';

abstract class DbRepository {
  saveCoinPrice(PriceEntity priceEntity);

  Future<List<PriceEntity>> getCoinPrices(String date);

  Future<List<PriceEntity>> getCoinPriceById(String idCoin, String date);

  Future<List<CoinEntity>> getAllCoins();

  putCoin(CoinEntity coinEntity);

  Future<CoinEntity> getCoin(String id);

  updateCoin(CoinEntity newCoinEntity);

  updateCoinIsRelevant(CoinEntity newCoinEntity);

  deleteCoin(int id);

  deleteAllCoin();

  getPath();

  dbMigration(String path, String password);

  putTransaction(TransactionEntity transactionEntity);

  Future<List<TransactionEntity>> getAllTransactionByIdCoin(String id);

  Future<List<TransactionEntity>> getAllTransaction();

  Future<List<TransactionEntity>> getTransaction(int id);

  updateTransaction(TransactionEntity newTransactionEntity, int transactionId);

  deleteTransaction(int id);

  openDb(String name, String pass);

  Future<bool> closeDb(String name, String password);

  isOpenDb();

  Future<List<TrastWalletEntity>> getTrastWallet();

  saveTrastWallet(TrastWalletEntity trastWalletEntity);
}
