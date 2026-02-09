
const http = require('http');

const hostname = '127.0.0.1';
const port = 3000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'application/json');
  
  // Simulate processing delay
  setTimeout(() => {
    // Allows all receipts
    const response = {
      isValid: true,
      productId: 'remove_ads', // Mock response
      timestamp: Date.now()
    };
    
    res.end(JSON.stringify(response));
    console.log(`Verified receipt at ${new Date().toISOString()}`);
  }, 500);
});

server.listen(port, hostname, () => {
  console.log(`Dummy Verification Server running at http://${hostname}:${port}/`);
});
