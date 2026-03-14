import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { GoogleOAuthProvider } from '@react-oauth/google';
import '@fontsource/poppins/400.css';
import '@fontsource/poppins/500.css';
import '@fontsource/poppins/600.css';
import '@fontsource/raleway/600.css';
import '@fontsource/raleway/700.css';
import App from './App.tsx';

const configuredGoogleClientId = import.meta.env.VITE_GOOGLE_CLIENT_ID?.trim();
const googleClientId =
  configuredGoogleClientId && configuredGoogleClientId.length > 0
    ? configuredGoogleClientId
    : '000000000000-placeholder.apps.googleusercontent.com';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <GoogleOAuthProvider clientId={googleClientId}>
      <App />
    </GoogleOAuthProvider>
  </StrictMode>,
);
