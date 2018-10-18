const express = require('express');

const app = express();

app.post('*', (req, res) => {
  const body = req.body;
  res
    .set({
      'Content-Type': 'application/json'
    })
    .status(200)
    .send(body);
});

app.listen(process.env.PORT);
