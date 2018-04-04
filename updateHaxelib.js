const fs = require('fs');
const pack = require('./package.json');
fs.readFile('haxelib.json', 'utf8', function (err,data) {
    if (err) {
        return console.log(err);
    }
    var result = data.replace(/\"version\": \"[0-9\.\-rc]+\",/g, '\"version\": \"' + pack.version + '\",');

    fs.writeFile('haxelib.json', result, 'utf8', function (err) {
        if (err) return console.log(err);
    });
});