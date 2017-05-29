var fs = require('fs');
var lpse = JSON.parse(require('../lpse_201601.json').response.data);
var fields = [];

for (var key in lpse[0])
  fields.push(key);

fs.writeFileSync('lpse_fields.txt', fields.join('\n'));
