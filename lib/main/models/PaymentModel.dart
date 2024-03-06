import '../../main.dart';

class PaymentModel{
  int? index;
  String? title;
  String? image;
  bool? isSelected=false;
  PaymentModel({this.index,this.image, this.title});

}

List<PaymentModel> getPaymentItems() {
  List<PaymentModel> list = [];
  list.add(PaymentModel(index: 1,image: 'assets/icons/ic_cash.png', title: language.cash));
  list.add(PaymentModel(index: 2,image: 'assets/icons/ic_credit_card.png', title: language.online));
  list.add(PaymentModel(index: 3,image: 'assets/icons/ic_credit_card.png', title: language.wallet));
  return list;
}
