const express = require('express');
const { createServer } = require('http');
const { Server } = require('socket.io');
const path = require('path');

const app = express();
const server = createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

const rooms = new Map();

// Serve static files (including your HTML file)
app.use(express.static(path.join(__dirname)));

// Route to serve the main page
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

io.on('connection', (socket) => {
  console.log('Client connected:', socket.id);

  socket.on('create-room', (roomCode) => {
    socket.join(roomCode);
    rooms.set(roomCode, {
      sender: socket.id,
      receivers: [],
      createdAt: new Date()
    });
    socket.emit('room-created', roomCode);
    console.log(`Room created: ${roomCode} by ${socket.id}`);
  });

  socket.on('join-room', (roomCode) => {
    const room = rooms.get(roomCode);
    if (room) {
      socket.join(roomCode);
      room.receivers.push(socket.id);
      socket.to(roomCode).emit('receiver-joined', socket.id);
      socket.emit('joined-room', roomCode);
      console.log(`Client ${socket.id} joined room: ${roomCode}`);
    } else {
      socket.emit('room-not-found', roomCode);
      console.log(`Room not found: ${roomCode}`);
    }
  });

  socket.on('offer', (data) => {
    console.log(`Offer sent to room: ${data.room}`);
    socket.to(data.room).emit('offer', {
      offer: data.offer,
      sender: socket.id
    });
  });

  socket.on('answer', (data) => {
    console.log(`Answer sent to room: ${data.room}`);
    socket.to(data.room).emit('answer', {
      answer: data.answer,
      sender: socket.id
    });
  });

  socket.on('ice-candidate', (data) => {
    console.log(`ICE candidate sent to room: ${data.room}`);
    socket.to(data.room).emit('ice-candidate', {
      candidate: data.candidate,
      sender: socket.id
    });
  });

  socket.on('file-info', (data) => {
    console.log(`File info sent to room: ${data.room}`);
    socket.to(data.room).emit('file-info', {
      files: data.files,
      sender: socket.id
    });
  });

  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id);

    // Clean up rooms where this socket was the sender
    for (const [roomCode, room] of rooms.entries()) {
      if (room.sender === socket.id) {
        // Notify receivers that sender has left
        socket.to(roomCode).emit('sender-disconnected');
        rooms.delete(roomCode);
        console.log(`Room ${roomCode} deleted - sender disconnected`);
      } else {
        // Remove from receivers list
        const receiverIndex = room.receivers.indexOf(socket.id);
        if (receiverIndex > -1) {
          room.receivers.splice(receiverIndex, 1);
          socket.to(roomCode).emit('receiver-left', socket.id);
        }
      }
    }
  });

  // Heartbeat to keep rooms alive and clean up old ones
  socket.on('ping', () => {
    socket.emit('pong');
  });
});

// Clean up old rooms every 30 minutes
setInterval(() => {
  const now = new Date();
  const thirtyMinutesAgo = new Date(now.getTime() - 30 * 60 * 1000);

  for (const [roomCode, room] of rooms.entries()) {
    if (room.createdAt < thirtyMinutesAgo) {
      rooms.delete(roomCode);
      console.log(`Room ${roomCode} cleaned up - too old`);
    }
  }
}, 30 * 60 * 1000);

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Signaling server running on port ${PORT}`);
  console.log(`Open http://localhost:${PORT} to use the file sharing app`);
});