import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../youcanpay_sdk.dart';
import '../configs/constants.dart';
import '../factories/ycp_response_factory.dart';
import '../models/http_response.dart';
import '../models/ycp_response_3ds.dart';
import '../models/ycp_response_sale.dart';
import '../models/ycpay_response.dart';
import '../widgets/ycp_webview.dart';
import 'based_service.dart';

class PayWithCardService extends BasedService {
  BuildContext context;
  PayWithCardService({required this.context});

  void payWithCard(
      {required String token,
      required String pubKey,
      required CardInformation cardInformation,
      required Function(String? transactionId) onSuccessfulPayment,
      required Function(String? message) onFailedPayment}) async {

    var formData = FormData.fromMap({
      'pub_key': pubKey,
      'token_id': token,
      'expire_date':
          '${cardInformation.expireDateMonth.padLeft(2, '0')}/${cardInformation.expireDateYear.padLeft(2, '0')}',
      'credit_card': cardInformation.cardNumber,
      'cvv': cardInformation.cvv,
      'card_holder_name': cardInformation.cardHolderName,
      'payment_method[type]': 'credit_card',
      'is_mobile': '1',
    });

    try {
      HttpResponse response = await httpAdapter.post(url: Constants.payWithCardUrl, body: formData);
      YCPayResponse ycPayResponse = YCPResponseFactory.fromJSON(response);

      if (ycPayResponse is YCPResponseSale) {
        if (ycPayResponse.success) {
          onSuccessfulPayment(ycPayResponse.transactionId);

          return;
        }
        onFailedPayment(ycPayResponse.message);

        return;
      }

      if (ycPayResponse is YCPResponse3ds) {
        on3dsPayment(
            onFailedPayment: onFailedPayment, onSuccessfulPayment: onSuccessfulPayment, response: ycPayResponse);

        return;
      }
    } catch (e) {
      onFailedPayment(e.toString());
    }
  }

  void on3dsPayment(
      {required YCPResponse3ds response,
      required Function(String? transactionId) onSuccessfulPayment,
      required Function(String? message) onFailedPayment}) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            child: YCPWebView(
              onFailedPayment: (message) {
                onFailedPayment(message);
              },
              onSuccessfulPayment: (transactionId) {
                onSuccessfulPayment(transactionId);
              },
              response: response,
            ));
      },
    );
  }
}
