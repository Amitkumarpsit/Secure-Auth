<script>
  import { goto } from '$app/navigation';
  import { authApi } from '$lib/api';
  import { setUser } from '$lib/stores';
  import { getIpData } from '$lib/ipService';

  let email = '';
  let password = '';
  let loading = false;
  let error = '';

  async function handleSubmit() {
    if (!email || !password) return;

    loading = true;
    error = '';

    try {
      // Get IP data
      const ipData = await getIpData();
      
      // Attempt sign in
      const response = await authApi.signin(email, password, ipData);
      
      // Store user data and token
      setUser(response.user, response.token);
      
      // Redirect to dashboard
      goto('/dashboard');
    } catch (err) {
      error = 'Invalid email or password';
      console.error('Sign in error:', err);
    } finally {
      loading = false;
    }
  }
</script>

<svelte:head>
  <title>Sign In - Authentication App</title>
</svelte:head>

<div class="container">
  <div class="card">
    <div class="card-header">
      <h1>Welcome Back</h1>
      <p>Sign in to access your dashboard</p>
    </div>

    <form on:submit|preventDefault={handleSubmit}>
      {#if error}
        <div class="error-message">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"></circle>
            <line x1="12" y1="8" x2="12" y2="12"></line>
            <line x1="12" y1="16" x2="12.01" y2="16"></line>
          </svg>
          {error}
        </div>
      {/if}

      <div class="form-group">
        <label for="email">Email Address</label>
        <input
          id="email"
          type="email"
          bind:value={email}
          placeholder="john@example.com"
          required
          autocomplete="email"
        />
      </div>

      <div class="form-group">
        <label for="password">Password</label>
        <input
          id="password"
          type="password"
          bind:value={password}
          placeholder="Enter your password"
          required
          autocomplete="current-password"
        />
      </div>

      <button type="submit" class="btn-submit" disabled={loading || !email || !password}>
        {#if loading}
          <span class="spinner"></span>
          Signing In...
        {:else}
          Sign In
        {/if}
      </button>
    </form>

    <div class="card-footer">
      Don't have an account? <a href="/signup">Sign Up</a>
    </div>
  </div>
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

  .card {
    background: white;
    border-radius: 16px;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
    max-width: 420px;
    width: 100%;
    overflow: hidden;
  }

  .card-header {
    padding: 2.5rem 2.5rem 1.5rem;
    text-align: center;
  }

  h1 {
    margin: 0 0 0.5rem 0;
    color: #1a202c;
    font-size: 2rem;
  }

  .card-header p {
    margin: 0;
    color: #718096;
  }

  form {
    padding: 0 2.5rem 2rem;
  }

  .form-group {
    margin-bottom: 1.5rem;
  }

  label {
    display: block;
    margin-bottom: 0.5rem;
    color: #2d3748;
    font-weight: 600;
    font-size: 0.875rem;
  }

  input {
    width: 100%;
    padding: 0.75rem 1rem;
    border: 2px solid #e2e8f0;
    border-radius: 8px;
    font-size: 1rem;
    transition: all 0.2s;
    box-sizing: border-box;
  }

  input:focus {
    outline: none;
    border-color: #667eea;
    box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
  }

  .btn-submit {
    width: 100%;
    padding: 1rem;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border: none;
    border-radius: 8px;
    font-size: 1rem;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.5rem;
    margin-top: 2rem;
  }

  .btn-submit:hover:not(:disabled) {
    transform: translateY(-2px);
    box-shadow: 0 8px 20px rgba(102, 126, 234, 0.4);
  }

  .btn-submit:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }

  .spinner {
    width: 16px;
    height: 16px;
    border: 2px solid rgba(255, 255, 255, 0.3);
    border-top-color: white;
    border-radius: 50%;
    animation: spin 0.6s linear infinite;
  }

  @keyframes spin {
    to { transform: rotate(360deg); }
  }

  .error-message {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 1rem;
    background: #fff5f5;
    border: 1px solid #fc8181;
    border-radius: 8px;
    color: #c53030;
    margin-bottom: 1.5rem;
  }

  .card-footer {
    padding: 1.5rem 2.5rem;
    background: #f7fafc;
    text-align: center;
    color: #4a5568;
  }

  .card-footer a {
    color: #667eea;
    text-decoration: none;
    font-weight: 600;
  }

  .card-footer a:hover {
    text-decoration: underline;
  }

  @media (max-width: 640px) {
    .card-header, form, .card-footer {
      padding-left: 1.5rem;
      padding-right: 1.5rem;
    }
  }
</style>
