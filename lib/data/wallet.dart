
class Wallet  {
 String? id;
  String? name;
  String? walletType;
   String? blockchains;
   String? link;
   String? droid;
   String? ios;
   String? sort;

  Wallet({
    this.id,
    this.name,
    this.walletType,
    this.blockchains,
    this.link,
    this.droid,
    this.ios,
    this.sort,
  });

 Wallet.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    walletType = json['wallet_type'];
    blockchains = json['blockchains'];
    link = json['link'];
    droid = json['droid'];
    ios = json['ios'];
    sort = json['sort'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['wallet_type'] = this.walletType;
    data['blockchains'] = this.blockchains;
    data['link'] = this.link;
    data['droid'] = this.droid;
    data['ios'] = this.ios;
    data['sort'] = this.sort;

    return data;
  }

  @override
  String toString() {
    return '{id: $id, name: $name, wallet_type: $walletType, blockchains: $blockchains, '
        'link: $link, droid: $droid, ios: $ios, sort: $sort,}';
  }
}
