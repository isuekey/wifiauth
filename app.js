'use strict';
var express = require('express'),
    bodyParser = require('body-parser'),
    oauthserver = require('oauth2-server'); // Would be: 'oauth2-server'
var path = require('path');
var multer = require('multer');
var timers = require("timers");

var controllerAccount = require('./api/controllers/account');
var controllerGroup = require('./api/controllers/group');
var controllerUpload = require('./api/controllers/upload');
var helperEth = require('./api/helpers/ethCheckHelper');
var helperBtc = require('./api/helpers/btcCheckHelper');

var app = express();
var upload = multer({ dest: "uploads/" });
app.set('view engine', 'jade');
app.use(express.static(path.join(__dirname, 'public')));


app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.oauth = oauthserver({
    model: require('./api/models/oauth2.model'),
    grants: ['password', 'refresh_token'],
    debug: true
});

// Handle token grant requests
app.all('/wifiauth/token', app.oauth.grant());
//上传文件
app.post('/wifiauth/upload', upload.single('file'), controllerUpload.receiveFile);
app.get('/wifiauth/uploads/:filename', controllerUpload.sendFile);
app.post('/wifiauth/phone/code/send', controllerAccount.sendPhoneCode);
app.post('/wifiauth/phone/code/prepare', controllerAccount.preparePhoneCode);
app.post('/wifiauth/code/verify/refresh', controllerAccount.refreshVerifyCode);
app.get('/wifiauth/code/verify/:id/:timestamp', controllerAccount.refreshVerifyCodeImage);

app.post('/wifiauth/signup', controllerAccount.createAccount);
app.post('/wifiauth/resetpassword', controllerAccount.resetPassword);

app.post('/wifiauth/authed/subscribe', app.oauth.authorise(), controllerAccount.createSubscribe);
app.get('/wifiauth/authed/subscribe', app.oauth.authorise(), controllerAccount.getSubscribeInfo);
app.get('/wifiauth/authed/account', app.oauth.authorise(), controllerAccount.getAccount);
app.get('/wifiauth/authed/checked', app.oauth.authorise(), controllerAccount.getChecked);
app.post('/wifiauth/authed/checked', app.oauth.authorise(), controllerAccount.addAchecked);

app.put('/wifiauth/authed/checked/:checkedId', app.oauth.authorise(), controllerAccount.updateChecked);
app.get('/wifiauth/authed/list/all/checked', app.oauth.authorise(), controllerAccount.queryAllChecked);
app.get('/wifiauth/authed/checked/tx/:address', app.oauth.authorise(), controllerAccount.getTradeCount);


app.get('/wifiauth/authed/checked', app.oauth.authorise(), controllerAccount.getChecked);

app.get('/wifiauth/authed/list/subscribe/:phone', app.oauth.authorise(), controllerAccount.subListOfPhone);
app.get('/wifiauth/authed/list/checked/:phone', app.oauth.authorise(), controllerAccount.checkedListOfPhone);

app.get('/wifiauth/authed/send/msg/list', app.oauth.authorise(), controllerAccount.needSendMsgAccountList);
app.post('/wifiauth/authed/send/msg/to/:phone', app.oauth.authorise(), controllerAccount.sendMsgToAccount);
app.post('/wifiauth/authed/ubc/address', app.oauth.authorise(), controllerAccount.saveUBCAddress);
app.get('/wifiauth/authed/ubc/address', app.oauth.authorise(), controllerAccount.getUBCAddress);
app.get('/wifiauth/authed/ubc/query/all', app.oauth.authorise(), controllerAccount.queryUBCAddress);
app.get('/wifiauth/group',controllerGroup.view);

app.get('/oauth/authorise', app.oauth.authorise(), function(req, res) {
    // Will require a valid access_token
    res.send('Secret area');
});

app.get('/public', function(req, res) {
    res.send('public area');
});
//helperEth.startCheckEth();

//timers.setTimeout(helperBtc.startCheckBtc, 15 * 1000);
//helperBtc.startCheckBtc();

app.use(app.oauth.errorHandler());

var port = process.env.PORT || 10010;
app.listen(port);

// for test
module.exports = app;
