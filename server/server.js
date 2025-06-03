// server.js
const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 3000 }, () => {
  console.log('WebSocket server started on ws://localhost:3000');
});

wss.on('connection', (ws) => {
  console.log('Client connected');

  ws.on('message', (message) => {
    console.log('Received:', message.toString());
    const name = message.toString().trim();
    ws.send(`Hello ${name}`);
  });

  ws.on('close', () => {
    console.log('Client disconnected');
  });
});
