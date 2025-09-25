# ShareMeOnline - WebRTC File Sharing

A peer-to-peer file sharing application using WebRTC technology. Share files directly between devices without uploading to any server.

## Features

- 🔒 **Private & Secure**: Direct peer-to-peer transfers
- 🚀 **No File Size Limits**: Transfer any size files
- 📱 **Cross-Platform**: Works on any device with a modern browser
- 🎯 **Simple Interface**: Just drag, drop, and share
- 🔐 **Room-Based**: Secure 6-digit codes for connections
- ⚡ **Real-time**: Instant file transfers once connected

## Prerequisites

- Node.js (version 14 or higher)
- npm (comes with Node.js)
- Modern web browser with WebRTC support

## Setup Instructions

1. **Install Dependencies**
   ```bash
   npm install
   ```

2. **Start the Server**
   ```bash
   npm start
   ```
   
   Or for development with auto-restart:
   ```bash
   npm run dev
   ```

3. **Open in Browser**
   - Open `http://localhost:3000` in your web browser
   - The application will be available on all devices on your network

## How to Use

### Sending Files

1. **Select Files**: Drag and drop files or click to browse
2. **Generate Code**: Click "Generate Share Code" 
3. **Share Code**: Give the 6-digit code to receivers
4. **Wait for Connection**: Keep the page open while others connect
5. **Send Files**: Click "Send File" when receivers request them

### Receiving Files

1. **Get Code**: Obtain the 6-digit code from the sender
2. **Enter Code**: Type the code in the "Enter Share Code" field
3. **Connect**: Click "Connect" to join the room
4. **Download**: Click "Request Download" for available files

## Technical Details

### Architecture
- **Frontend**: HTML5, CSS3, Vanilla JavaScript
- **Backend**: Node.js with Express and Socket.IO
- **WebRTC**: Peer-to-peer data channels for file transfer
- **Signaling**: Socket.IO for WebRTC handshake coordination

### Security
- All file transfers happen directly between browsers
- No files are stored on the server
- Rooms are automatically cleaned up after 30 minutes
- Each session uses a unique 6-digit code

### Browser Compatibility
- Chrome 60+
- Firefox 55+
- Safari 12+
- Edge 79+

## Network Configuration

### For Local Network Use
The application works out-of-the-box on local networks.

### For Internet Use
For transfers across the internet, you may need to configure STUN/TURN servers:

1. Edit the `rtcConfig` in `index.html`
2. Add your TURN server credentials:
```javascript
const rtcConfig = {
  iceServers: [
    { urls: 'stun:stun.l.google.com:19302' },
    { 
      urls: 'turn:your-turn-server.com:3478',
      username: 'your-username',
      credential: 'your-password'
    }
  ]
};
```

## Deployment

### Local Development
```bash
npm start
```

### Production Deployment
1. Set environment variable: `PORT=your-port`
2. Use a process manager like PM2:
```bash
npm install -g pm2
pm2 start server.js --name sharemeeonline
```

## Troubleshooting

### Connection Issues
- Ensure both devices are on the same network (for local use)
- Check firewall settings
- Try refreshing both browsers
- Verify the 6-digit code is correct

### File Transfer Problems
- Large files may take time to establish connection
- Ensure stable network connection
- Don't close browser tabs during transfer

## License

MIT License - feel free to use and modify as needed.

## Contributing

Pull requests are welcome! Please feel free to submit issues and feature requests.# pear-to-pear-share
