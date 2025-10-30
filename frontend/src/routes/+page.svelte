<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { isAuthenticated } from '$lib/stores';

  let authenticated = false;

  onMount(() => {
    const unsubscribe = isAuthenticated.subscribe((value) => {
      authenticated = value;
      if (value) {
        goto('/dashboard');
      }
    });

    return unsubscribe;
  });
</script>

<svelte:head>
  <title>Welcome - Authentication App</title>
</svelte:head>

<div class="container">
  <main class="landing-page">
    <div class="hero">
      <h1>Welcome to Secure Auth</h1>
      <p class="subtitle">A secure authentication system with comprehensive tracking</p>
    </div>

    <div class="actions">
      <a href="/signup" class="btn btn-primary">
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path>
          <circle cx="9" cy="7" r="4"></circle>
          <line x1="19" y1="8" x2="19" y2="14"></line>
          <line x1="22" y1="11" x2="16" y2="11"></line>
        </svg>
        Sign Up
      </a>
      <a href="/signin" class="btn btn-secondary">
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"></path>
          <polyline points="10 17 15 12 10 7"></polyline>
          <line x1="15" y1="12" x2="3" y2="12"></line>
        </svg>
        Sign In
      </a>
    </div>

    <div class="features">
      <div class="feature">
        <div class="icon">🔒</div>
        <h3>Secure</h3>
        <p>Industry-standard password policies</p>
      </div>
      <div class="feature">
        <div class="icon">📊</div>
        <h3>Tracking</h3>
        <p>Monitor all sign-in attempts</p>
      </div>
      <div class="feature">
        <div class="icon">🌍</div>
        <h3>Global</h3>
        <p>IP and location tracking</p>
      </div>
    </div>
  </main>
</div>

<style>
  :global(body) {
    margin: 0;
    padding: 0;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
  }

  .container {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 2rem;
  }

  .landing-page {
    max-width: 800px;
    width: 100%;
    text-align: center;
  }

  .hero {
    margin-bottom: 3rem;
  }

  h1 {
    color: white;
    font-size: 3.5rem;
    margin: 0 0 1rem 0;
    font-weight: 700;
    text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
  }

  .subtitle {
    color: rgba(255, 255, 255, 0.9);
    font-size: 1.25rem;
    margin: 0;
  }

  .actions {
    display: flex;
    gap: 1.5rem;
    justify-content: center;
    margin-bottom: 4rem;
  }

  .btn {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    padding: 1rem 2.5rem;
    font-size: 1.125rem;
    font-weight: 600;
    text-decoration: none;
    border-radius: 12px;
    transition: all 0.3s ease;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.2);
  }

  .btn-primary {
    background: white;
    color: #667eea;
  }

  .btn-primary:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 12px rgba(0, 0, 0, 0.3);
  }

  .btn-secondary {
    background: rgba(255, 255, 255, 0.2);
    color: white;
    border: 2px solid white;
  }

  .btn-secondary:hover {
    background: rgba(255, 255, 255, 0.3);
    transform: translateY(-2px);
    box-shadow: 0 6px 12px rgba(0, 0, 0, 0.3);
  }

  .features {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 2rem;
    margin-top: 3rem;
  }

  .feature {
    background: rgba(255, 255, 255, 0.1);
    backdrop-filter: blur(10px);
    padding: 2rem;
    border-radius: 12px;
    border: 1px solid rgba(255, 255, 255, 0.2);
  }

  .icon {
    font-size: 3rem;
    margin-bottom: 1rem;
  }

  h3 {
    color: white;
    font-size: 1.5rem;
    margin: 0 0 0.5rem 0;
  }

  .feature p {
    color: rgba(255, 255, 255, 0.8);
    margin: 0;
  }

  @media (max-width: 640px) {
    h1 {
      font-size: 2.5rem;
    }

    .actions {
      flex-direction: column;
    }

    .btn {
      width: 100%;
      justify-content: center;
    }
  }
</style>
