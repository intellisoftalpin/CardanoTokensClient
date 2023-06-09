
class Decimal {

  static double convertPriceRoundToDouble(num price) {
    print("price one = $price");
    var string = '';
    var cost = 0.0;
    if (price == 1 || price == 1.0) {
    cost = price.toDouble();
    } else
    if (price < 0) {
      price = price * (-1);
      if (price >= 1) {
        //var num = price.toString().split('.');
        //var parc = "0." + "${num.last}";
        string = price.toStringAsFixed(2);
        //double pric = double.parse(parc);
        //print("pric = $pric");
        // if (0.01 > pric && pric >= 0.001) {
        //   string = price.toStringAsFixed(4);
        // } else if (0.1 > pric && pric >= 0.01) {
        //   string = price.toStringAsFixed(2);
        // } else if (0.001 > pric && pric >= 0.0001) {
        //   string = price.toStringAsFixed(5);
        // } else if (0.0001 > pric && pric >= 0.00001) {
        //   string = price.toStringAsFixed(6);
        // } else if (0.00001 > pric && pric >= 0.000001) {
        //   string = price.toStringAsFixed(7);
        // } else if (0.000001 > pric && pric >= 0.0000001) {
        //   string = price.toStringAsFixed(8);
        // } else if (0.0000001 > pric && pric >= 0.00000001) {
        //   string = price.toStringAsFixed(9);
        // } else if (0.00000001 > pric && pric >= 0.0000000000001) {
        //   string = price.toStringAsFixed(12);
        // } else if (1 > pric && pric >= 0.1) {
        //   string = price.toStringAsFixed(2);
        // } else if (1 > price && price >= 0.1) {
        //   string = price.toStringAsFixed(2);
        // } else if (0.1 > price && price >= 0.01) {
        //   string = price.toStringAsFixed(3);
        // } else if (0.01 > price && price >= 0.001) {
        //   string = price.toStringAsFixed(4);
        // } else if (0.001 > price && price >= 0.0001) {
        //   string = price.toStringAsFixed(5);
        // } else if (0.0001 > price && price >= 0.00001) {
        //   string = price.toStringAsFixed(6);
        // } else if (0.00001 > price && price >= 0.000001) {
        //   string = price.toStringAsFixed(7);
        // } else if (0.000001 > price && price >= 0.0000001) {
        //   string = price.toStringAsFixed(8);
        // } else if (0.0000001 > price && price >= 0.00000001) {
        //   string = price.toStringAsFixed(9);
        // } else if (0.00000001 > price && price >= 0.0000000000001) {
        //   string = price.toStringAsFixed(12);
        // } else if (price == 0.0) {
        //   cost = 0.0;
        // } else if (pric == 0.0) {
        //   string = (price).toString();
        // }
          string = string.toString().replaceAll(",", ".");
          print("string = $string");
          cost = double.parse(string) / -1;
      } else if (price < 1) {
        if (1.0 > price && price >= 0.1) {
          string = price.toStringAsFixed(2);
        } else if (0.1 > price && price >= 0.01) {
          string = price.toStringAsFixed(3);
        } else if (0.01 > price && price >= 0.001) {
          string = price.toStringAsFixed(4);
        } else if (0.001 > price && price >= 0.0001) {
          string = price.toStringAsFixed(5);
        } else if (0.0001 > price && price >= 0.00001) {
          string = price.toStringAsFixed(6);
        } else if (0.00001 > price && price >= 0.000001) {
          string = price.toStringAsFixed(7);
        } else if (0.000001 > price && price >= 0.0000001) {
          string = price.toStringAsFixed(8);
        } else if (0.0000001 > price && price >= 0.00000001) {
          string = price.toStringAsFixed(9);
        } else if (0.00000001 > price && price >= 0.000000000001) {
          string = price.toStringAsFixed(12);
        } else if (0.000000000001 > price && price >= 0.0000000000001) {
          string = price.toStringAsFixed(13);
        } else if (0.0000000000001 > price && price >= 0.00000000000001) {
          string = price.toStringAsFixed(14);
        } else if (price == 0.0) {
          string = '0.0';
        } else if (0.000000000001 > price) {
          string = price.toStringAsExponential(12);
        }
        string = string.toString().replaceAll(",", ".");
        print("price < 0 :::string = $string");
        cost = double.parse(string) / -1;
      }
      } else if (price > 0) {
      if (price > 1) {
        //var num = price.toString().split('.');
        string = price.toStringAsFixed(2);
        //var parc = "0." + "${num.last}";
        //double pric = double.parse(parc);
        //print("pric = $pric");
        // if (0.01 > pric && pric >= 0.001) {
        //   string = price.toStringAsFixed(4);
        // } else if (0.1 > pric && pric >= 0.01) {
        //   string = price.toStringAsFixed(2);
        // } else if (0.001 > pric && pric >= 0.0001) {
        //   string = price.toStringAsFixed(5);
        // } else if (0.0001 > pric && pric >= 0.00001) {
        //   string = price.toStringAsFixed(6);
        // } else if (0.00001 > pric && pric >= 0.000001) {
        //   string = price.toStringAsFixed(7);
        // } else if (0.000001 > pric && pric >= 0.0000001) {
        //   string = price.toStringAsFixed(8);
        // } else if (0.0000001 > pric && pric >= 0.00000001) {
        //   string = price.toStringAsFixed(9);
        // } else if (0.00000001 > pric && pric >= 0.0000000000001) {
        //   string = price.toStringAsFixed(12);
        // } else if (1 > pric && pric >= 0.1) {
        //   string = price.toStringAsFixed(2);
        // } else if (pric == 0.0) {
        //   string = (price / 1).toString();
        // }
      } else if (price < 1) {
        if (1.0 > price && price >= 0.1) {
          string = price.toStringAsFixed(2);
        } else if (0.1 > price && price >= 0.01) {
          string = price.toStringAsFixed(3);
        } else if (0.01 > price && price >= 0.001) {
          string = price.toStringAsFixed(4);
        } else if (0.001 > price && price >= 0.0001) {
          string = price.toStringAsFixed(5);
        } else if (0.0001 > price && price >= 0.00001) {
          string = price.toStringAsFixed(6);
        } else if (0.00001 > price && price >= 0.000001) {
          string = price.toStringAsFixed(7);
        } else if (0.000001 > price && price >= 0.0000001) {
          string = price.toStringAsFixed(8);
        } else if (0.0000001 > price && price >= 0.00000001) {
          string = price.toStringAsFixed(9);
        } else if (0.00000001 > price && price >= 0.000000000001) {
          string = price.toStringAsFixed(12);
        } else if (price == 0.0) {
          string = '0.0';
        } else if (0.000000000001 > price && price >= 0.0000000000001) {
          string = price.toStringAsFixed(13);
        } else if (0.0000000000001 > price && price >= 0.00000000000001) {
          string = price.toStringAsFixed(14);
        } else if (0.00000000000001 > price) {
          string = price.toStringAsExponential(14);
        }
      }
      string = string.toString().replaceAll(",", ".");
      print("string before parse = $string");
      cost = double.parse(string);
      print("string after parse = $cost");
    }
      return cost;
    }

  static String convertPriceRoundToString(num price) {
    print("price one = $price");
    var string = '';
    if (price == 1 || price == 1.0) {
      string = price.toStringAsFixed(2);
    } else
    if (price < 0) {
      price = price * (-1);
      if (price >= 1) {
        string = price.toStringAsFixed(2);
        string = string.toString().replaceAll(",", ".");
        print("string = $string");
      } else if (price < 1) {
        if (1.0 > price && price >= 0.1) {
          string = price.toStringAsFixed(2);
        } else if (0.1 > price && price >= 0.01) {
          string = price.toStringAsFixed(3);
        } else if (0.01 > price && price >= 0.001) {
          string = price.toStringAsFixed(4);
        } else if (0.001 > price && price >= 0.0001) {
          string = price.toStringAsFixed(5);
        } else if (0.0001 > price && price >= 0.00001) {
          string = price.toStringAsFixed(6);
        } else if (0.00001 > price && price >= 0.000001) {
          string = price.toStringAsFixed(7);
        } else if (0.000001 > price && price >= 0.0000001) {
          string = price.toStringAsFixed(8);
        } else if (0.0000001 > price && price >= 0.00000001) {
          string = price.toStringAsFixed(9);
        } else if (0.00000001 > price && price >= 0.000000000001) {
          string = price.toStringAsFixed(12);
        } else if (price == 0.0) {
          string = '0.0';
        } else if (0.000000000001 > price) {
          string = price.toStringAsExponential(12);
        }
        string = string.toString().replaceAll(",", ".");
        print("price < 0 :::string = $string");
      }
    } else if (price > 0) {
      if (price > 1) {
        string = price.toStringAsFixed(2);
      } else if (price < 1) {
        if (1.0 > price && price >= 0.1) {
          string = price.toStringAsFixed(2);
        } else if (0.1 > price && price >= 0.01) {
          string = price.toStringAsFixed(3);
        } else if (0.01 > price && price >= 0.001) {
          string = price.toStringAsFixed(4);
        } else if (0.001 > price && price >= 0.0001) {
          string = price.toStringAsFixed(5);
        } else if (0.0001 > price && price >= 0.00001) {
          string = price.toStringAsFixed(6);
        } else if (0.00001 > price && price >= 0.000001) {
          string = price.toStringAsFixed(7);
        } else if (0.000001 > price && price >= 0.0000001) {
          string = price.toStringAsFixed(8);
        } else if (0.0000001 > price && price >= 0.00000001) {
          string = price.toStringAsFixed(9);
        } else if (0.00000001 > price && price >= 0.000000000001) {
          string = price.toStringAsFixed(12);
        } else if (price == 0.0) {
          string = '0.0';
        } else if (0.000000000001 > price) {
          string = price.toStringAsExponential(12);
        }
      }
      string = string.toString().replaceAll(",", ".");
      print("string = $string");
    }
    return string;
  }

    static String dividePrice(String price) {
        final result = price.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ');
        return result;
    }
}


