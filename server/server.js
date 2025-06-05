// // server.js
// const WebSocket = require('ws');

// const wss = new WebSocket.Server({ port: 3000 }, () => {
//   console.log('WebSocket server started on ws://localhost:3000');
// });

// wss.on('connection', (ws) => {
//   console.log('Client connected');

//   ws.on('message', (message) => {
//     console.log('Received:', message.toString());
//     const name = message.toString().trim();
//     ws.send(`hello ${name}`);
//   });

//   ws.on('close', () => {
//     console.log('Client disconnected');
//   });
// });


const WebSocket = require('ws');
const wss = new WebSocket.Server({ port: 3000 }, () =>
  console.log('Server running on ws://localhost:3000')
);

const clients = new Map(); // Map of ws -> { username, room }

function broadcastToRoom(room, message, sender) {
  for (const [client, meta] of clients.entries()) {
    if (client.readyState === WebSocket.OPEN && meta.room === room && client !== sender) {
      client.send(JSON.stringify(message));
    }
  }
}

wss.on('connection', (ws) => {
  console.log('A client connected');

  ws.on('message', (raw) => {
    try {
      const data = JSON.parse(raw);

      if (data.type === 'join') {
        clients.set(ws, { username: data.username, room: data.room });
        console.log(`${data.username} joined room ${data.room}`);
      }

      if (data.type === 'message') {
        const meta = clients.get(ws);
        if (!meta) return;

        const chatMessage = {
          type: 'message',
          username: meta.username,
          room: meta.room,
          timestamp: new Date().toISOString(),
          text: data.text,
        };

        broadcastToRoom(meta.room, chatMessage, ws);
        ws.send(JSON.stringify(chatMessage)); // echo to sender too
      }
    } catch (e) {
      console.error('Invalid message:', e.message);
    }
  });

  ws.on('close', () => {
    console.log('Client disconnected');
    clients.delete(ws);
  });
});
