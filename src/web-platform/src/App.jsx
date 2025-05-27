import { useState, useEffect } from 'react';

function App() {
  const [apiMessage, setApiMessage] = useState('');

  useEffect(() => {
    fetch('/api/hello')
      .then(response => response.json())
      .then(data => setApiMessage(data.message))
      .catch(() => setApiMessage('Error fetching API message'));
  }, []);

  return (
    <>
      <h1>Hello World from Frontend (React + Vite) OK</h1>
      <p>Message from API: {apiMessage || 'Loading...'}</p>
    </>
  );
}

export default App;
