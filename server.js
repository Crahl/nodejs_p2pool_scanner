// set up ======================================================================
//
var app 	= require('express')();
var server	= require('http').Server(app);
var io		= require('socket.io')(server);
var port	= process.env.PORT || 3000;
var logger 	= require('morgan');
var bodyParser 	= require('body-parser');
var path 	= require('path');
var fs 		= require('fs');

// configuration ===============================================================
//
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.set('view engine', 'jade');
app.set('views', path.join(__dirname, 'views'));

// routes ======================================================================
//
app.get('/', function(req, res) {
	res.render('index', {
		title: 'DASH P2Pool Scanner'
	});
});

app.get('/map', function(req, res) {
	res.render('map', {
		title: 'DASH P2Pool Scanner Map'
	});
});

app.get('/chart', function(req, res) {
	res.render('chart', {
		title: 'DASH P2Pool Scanner Chart'
	});
});

// =====================================
// Error Handler========================
// =====================================
app.get('*', function(req, res, next) {
	var err = new Error();
	err.status = 404;
	next(err);
});

app.use(function(err, req, res, next) {
	res.status(err.status || 500);
	res.render('error', {title: '404'});
});

// =====================================
// Socket Handler=======================
// =====================================
io.on('connection', function (socket) {
        var exec = require('child_process').exec;
	exec("perl /srv/git/nodejs_p2pool_scanner/perl/fetch_rrd.pl /srv/git/nodejs_p2pool_scanner/perl/rrd/dash.rrd AVERAGE 300 now -24h", function(err, stdout, stderr) {
		socket.emit('initiateChart', { dataPoints: JSON.parse(stdout) });
	});
	fs.readFile('dash.json', function(err, data) {
		socket.emit('initiateNodes', { nodes: JSON.parse(data) });
	});
});
setInterval(function(){
	var exec = require('child_process').exec;
	exec("perl /srv/git/nodejs_p2pool_scanner/perl/fetch_rrd.pl /srv/git/nodejs_p2pool_scanner/perl/rrd/dash.rrd AVERAGE 300 now -60s", function(err, stdout, stderr) {
		io.emit('updateChart', { newPoint: JSON.parse(stdout) });
	});
}, 60000);

// launch ======================================================================
//
app.set('port', process.env.PORT || port);
server.listen(app.get('port'), function() {
	console.log('Express server listening on port ' + server.address().port);
});

