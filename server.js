var http = require('http');

var app = require("./app");

const port = 3000;
const server = http.createServer(app.app);

server.listen(port);