/**

navigator.alipay.pay({"seller":"007slm@163.com",subject":"x51","body":"x5企业版","price":"0.01","tradeNo":"123456","timeout":"30m","notifyUrl":"wwww.justep.com"},function(msgCode){alert(msgCode)},function(msg){alert(msg)})
**/
/*
var exec = require('cordova/exec');
module.exports = {
    pay: function(orderInfo,onSuccess,onError){
        exec(onSuccess, onError, "Alipay", "pay", [orderInfo]);
    }
};

*/
var Alipay = function() {}

Alipay.prototype.settings = {
    partner: '',
    seller_id: '',
    rsa_public: '',
    locked: false,
    debug: false
}

Alipay.prototype.getOrderInfo = function(opts) {
    var _this = this;
    var opts = this.merge({
        out_trade_no: new Date().getTime(),
        subject: '商品标题',
        body: '商品描述',
        total_fee: '0.01',
        notify_url: 'http://m.alipay.com',
        return_url: ''
    }, opts);

    var params = 'partner="' + this.settings.partner + '"&seller_id="' + this.settings.seller_id + '"&service="mobile.securitypay.pay"&_input_charset="UTF-8"&payment_type="1"&it_b_pay="1m"';

    for (var k in opts) {
        params += '&' + k + '="' + encodeURI(opts[k]) + '"';
    };

    if (opts.debug) {
        console.log(params);
    }
    return params;

}

Alipay.prototype.pay = function(params, sign, succ, fail) {
    var _this = this;

    if (this.settings.locked) {
        return false;
    }

    this.settings.locked = true;

    var succ_func = function(e) {
        _this.settings.locked = false;
        if (typeof succ !== 'undefined') {
            succ(e);
        } else {
            console.log(e);
        }
    }

    var fail_func = function(e) {
        _this.settings.locked = false;
        if (typeof fail !== 'undefined') {
            fail(e);
        } else {
            console.log(e);
        }
    }

    cordova.exec(succ_func, fail_func, 'Alipay', 'pay', [params, sign, _this.settings]);

    return true;
};

Alipay.prototype.merge = function(defaults, target) {
    if (typeof target === 'undefined') {
        return defaults;
    }

    for (var k in defaults) {
        if (!target.hasOwnProperty(k)) {
            target[k] = defaults[k];
        }
    }

    return target;
};

module.exports = new Alipay();
