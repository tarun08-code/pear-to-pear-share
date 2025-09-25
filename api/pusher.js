const Pusher = require('pusher');

// Initialize Pusher (you'll need to add your credentials)
const pusher = new Pusher({
  appId: process.env.PUSHER_APP_ID || 'your_app_id',
  key: process.env.PUSHER_KEY || 'your_key', 
  secret: process.env.PUSHER_SECRET || 'your_secret',
  cluster: process.env.PUSHER_CLUSTER || 'us2',
  useTLS: true
});

export default async function handler(req, res) {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method === 'POST') {
    const { event, channel, data } = req.body;

    try {
      await pusher.trigger(channel, event, data);
      res.status(200).json({ success: true });
    } catch (error) {
      console.error('Pusher error:', error);
      res.status(500).json({ error: 'Failed to send message' });
    }
  } else {
    res.status(405).json({ error: 'Method not allowed' });
  }
}