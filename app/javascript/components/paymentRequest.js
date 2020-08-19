// app/assets/javascripts/apple_pay.js
/**
* Returns a boolean value indicating if Apple Pay is supported
*/
function isApplePaySupported() {
  var unsupported = !window.ApplePaySession;
  if (!unsupported) {
    var promise = ApplePaySession.canMakePaymentsWithActiveCard(MERCHANT_ID);
    promise.then(function(canMakePayments) {
      return unsupported = unsupported || !!canMakePayments;
    });
  }
  return !unsupported;
};

/**
* This method is called when the page is loaded.
*/
document.addEventListener('DOMContentLoaded', () => {
  if (isApplePaySupported()) {
    $('#applepay-btn').on('click', applePayButtonClicked);
  } else {
    // Browser and/or user's cards do not support Apple Pay
  }
});


function applePayButtonClicked() {
  /**
  * Sample payment data
  */
  var paymentRequest =
    {
      countryCode: 'JP',
      currencyCode: 'JPY',
      total: {
        label: 'Purchase at MyStore',
        amount: 2000
      },
      supportedNetworks: ['masterCard', 'visa', 'discover', 'amex'],
      merchantCapabilities: ['supports3DS']
    };
  var session = new ApplePaySession(2, paymentRequest);

  /**
  * Makes an AJAX request to your application server with URL provided by Apple
  */
  function getSession(url) {
    return new Promise(function(resolve, reject) {
      var xhr = new XMLHttpRequest;
      var requestUrl = '/path/to/applepay/merchant/session';

      xhr.open('POST', requestUrl);

      xhr.onload = function() {
        if (this.status >= 200 && this.status < 300) {
          return resolve(JSON.parse(xhr.response));
        } else {
          return reject({
            status: this.status,
            statusText: xhr.statusText
          });
        }
      };

      xhr.onerror = function() {
        return reject({
          status: this.status,
          statusText: xhr.statusText
        });
      };

      xhr.setRequestHeader('Content-Type', 'application/json');

      return xhr.send(JSON.stringify({
        url: url
      }));
    });
  };

  /**
  * Merchant Validation
  * We call our merchant session endpoint, passing the URL to use
  */
  session.onvalidatemerchant = (event) => {
    const validationURL = event.validationURL;
    var promise = getSession(event.validationURL);
    promise.then(function(response) {
      session.completeMerchantValidation(response);
    });
  };

  /**
  * This is called when user dismisses the payment modal
  */
  session.oncancel = (event) => {
    // Re-enable Apple Pay button
  };

  /**
  * Payment Authorization
  * Here you receive the encrypted payment data. You would then send it
  * on to your payment provider for processing, and return an appropriate
  * status in session.completePayment()
  */
  session.onpaymentauthorized = (event) => {
    const payment = event.payment;
    // You can see a sample `payment` object in an image below.
    // Use the token returned in `payment` object to create the charge on your payment gateway.

    if (chargeCreationSucceeds) {
      // Capture payment from Apple Pay
      session.completePayment(ApplePaySession.STATUS_SUCCESS);
    } else {
      // Release payment from Apple Pay
      session.completePayment(ApplePaySession.STATUS_FAILURE);
    }
  };

  /**
  * This will show up the modal for payments through Apple Pay
  */
  session.begin();
}