// class UserBankAccount {
//   String? account_holder_name;
//   String? account_number;
//   String? bank_code;
//   String? bank_name;
//   String? created_at;
//   int? id;
//   String? updated_at;
//   int? user_id;
//
//   UserBankAccount({
//     this.account_holder_name,
//     this.account_number,
//     this.bank_code,
//     this.bank_name,
//     this.created_at,
//     this.id,
//     this.updated_at,
//     this.user_id,
//   });
//
//   factory UserBankAccount.fromJson(Map<String, dynamic> json) {
//     return UserBankAccount(
//       account_holder_name: json['account_holder_name'],
//       account_number: json['account_number'],
//       bank_code: json['bank_code'],
//       bank_name: json['bank_name'],
//       created_at: json['created_at'],
//       id: json['id'],
//       updated_at: json['updated_at'],
//       user_id: json['user_id'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['account_holder_name'] = this.account_holder_name;
//     data['account_number'] = this.account_number;
//     data['bank_code'] = this.bank_code;
//     data['bank_name'] = this.bank_name;
//     data['created_at'] = this.created_at;
//     data['id'] = this.id;
//     data['updated_at'] = this.updated_at;
//     data['user_id'] = this.user_id;
//     return data;
//   }
// }
