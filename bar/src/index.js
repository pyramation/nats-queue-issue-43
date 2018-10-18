const express = require('express');

const app = express();

app.post('/*', (req, res) => {
  res.status(200).send('OK');
});

app.listen(9999);
