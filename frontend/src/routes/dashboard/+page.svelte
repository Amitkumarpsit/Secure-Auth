<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { user, isAuthenticated, logout } from '$lib/stores';
  import { authApi } from '$lib/api';

  let currentUser = null;
  let signInAttempts = [];
  let loading = true;
  let error = '';

  onMount(async () => {
    const unsubscribe = user.subscribe((value) => {
      currentUser = value;
    });

    const unsubscribeAuth = isAuthenticated.subscribe((value) => {
      if (!value) {
        goto('/signin');
      }
    });

    if (currentUser) {
      await loadSignInAttempts();
    }

    return () => {
      unsubscribe();
      unsubscribeAuth();
    };
  });

  async function loadSignInAttempts() {
    loading = true;
    error = '';
    try {
      const data = await authApi.getSignInAttempts(currentUser.id);
      signInAttempts = data;
    } catch (err) {
      error = err.response?.data?.message || 'Failed to load sign-in attempts';
      console.error('Error loading sign-in attempts:', err);
    } finally {
      loading = false;
    }
  }

  function handleLogout() {
    logout();
    goto('/');
  }

  function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleString('en-US', {
      month: 'short',
      day: 'numeric',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  }
</script>

<svelte:head>
  <title>Dashboard - Authentication App</title>
</svelte:head>

<div class="dashboard">
  <nav class="navbar">
    <div class="nav-content">
      <h1 class="logo">Secure Auth</h1>
      <div class="nav-right">
        {#if currentUser}
          <span class="user-name">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
              <circle cx="12" cy="7" r="4"></circle>
            </svg>
            {currentUser.name}
          </span>
        {/if}
        <button class="btn-logout" on:click={handleLogout}>
          <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
            <polyline points="16 17 21 12 16 7"></polyline>
            <line x1="21" y1="12" x2="9" y2="12"></line>
          </svg>
          Logout
        </button>
      </div>
    </div>
  </nav>

  <main class="main-content">
    <div class="container">
      <div class="header">
        <h2>Dashboard</h2>
        <p>View your sign-in activity and security information</p>
      </div>

      {#if currentUser}
        <div class="user-info-card">
          <div class="info-header">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
              <circle cx="12" cy="7" r="4"></circle>
            </svg>
            <h3>Account Information</h3>
          </div>
          <div class="info-grid">
            <div class="info-item">
              <span class="label">Name:</span>
              <span class="value">{currentUser.name}</span>
            </div>
            <div class="info-item">
              <span class="label">Email:</span>
              <span class="value">{currentUser.email}</span>
            </div>
          </div>
        </div>
      {/if}

      <div class="section">
        <div class="section-header">
          <div>
            <h3>Sign-In Attempts</h3>
            <p>Recent authentication activity on your account</p>
          </div>
          <button class="btn-refresh" on:click={loadSignInAttempts} disabled={loading}>
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class:spinning={loading}>
              <polyline points="23 4 23 10 17 10"></polyline>
              <polyline points="1 20 1 14 7 14"></polyline>
              <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"></path>
            </svg>
            Refresh
          </button>
        </div>

        {#if loading}
          <div class="loading-state">
            <div class="spinner-large"></div>
            <p>Loading sign-in attempts...</p>
          </div>
        {:else if error}
          <div class="error-state">
            <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <circle cx="12" cy="12" r="10"></circle>
              <line x1="12" y1="8" x2="12" y2="12"></line>
              <line x1="12" y1="16" x2="12.01" y2="16"></line>
            </svg>
            <p>{error}</p>
          </div>
        {:else if signInAttempts.length === 0}
          <div class="empty-state">
            <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path>
            </svg>
            <h3>No Sign-In Attempts</h3>
            <p>Your sign-in activity will appear here</p>
          </div>
        {:else}
          <div class="table-container">
            <table>
              <thead>
                <tr>
                  <th>Date & Time</th>
                  <th>Status</th>
                  <th>IP Address</th>
                  <th>Location</th>
                  <th>Device</th>
                </tr>
              </thead>
              <tbody>
                {#each signInAttempts as attempt}
                  <tr>
                    <td>{formatDate(attempt.attempted_at)}</td>
                    <td>
                      <span class="status-badge" class:success={attempt.success} class:failure={!attempt.success}>
                        {#if attempt.success}
                          <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <polyline points="20 6 9 17 4 12"></polyline>
                          </svg>
                          Success
                        {:else}
                          <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <line x1="18" y1="6" x2="6" y2="18"></line>
                            <line x1="6" y1="6" x2="18" y2="18"></line>
                          </svg>
                          Failed
                        {/if}
                      </span>
                      {#if !attempt.success && attempt.failure_reason}
                        <div class="failure-reason">{attempt.failure_reason}</div>
                      {/if}
                    </td>
                    <td class="mono">{attempt.ip_address || 'N/A'}</td>
                    <td>
                      {#if attempt.city && attempt.country}
                        <div class="location">
                          <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path>
                            <circle cx="12" cy="10" r="3"></circle>
                          </svg>
                          {attempt.city}, {attempt.country}
                        </div>
                      {:else}
                        N/A
                      {/if}
                    </td>
                    <td class="device-info">
                      {#if attempt.user_agent}
                        {attempt.user_agent.substring(0, 50)}{attempt.user_agent.length > 50 ? '...' : ''}
                      {:else}
                        N/A
                      {/if}
                    </td>
                  </tr>
                {/each}
              </tbody>
            </table>
          </div>
        {/if}
      </div>
    </div>
  </main>
</div>

<style>
  :global(body) {
    margin: 0;
    padding: 0;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
    background: #f7fafc;
  }

  .dashboard {
    min-height: 100vh;
  }

  .navbar {
    background: white;
    border-bottom: 1px solid #e2e8f0;
    padding: 1rem 0;
    position: sticky;
    top: 0;
    z-index: 100;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  }

  .nav-content {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 2rem;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .logo {
    margin: 0;
    font-size: 1.5rem;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
  }

  .nav-right {
    display: flex;
    align-items: center;
    gap: 1.5rem;
  }

  .user-name {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    color: #2d3748;
    font-weight: 500;
  }

  .btn-logout {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.625rem 1.25rem;
    background: #f7fafc;
    border: 1px solid #e2e8f0;
    border-radius: 8px;
    color: #4a5568;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s;
  }

  .btn-logout:hover {
    background: #edf2f7;
    border-color: #cbd5e0;
  }

  .main-content {
    padding: 2rem 0;
  }

  .container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 2rem;
  }

  .header {
    margin-bottom: 2rem;
  }

  .header h2 {
    margin: 0 0 0.5rem 0;
    color: #1a202c;
    font-size: 2rem;
  }

  .header p {
    margin: 0;
    color: #718096;
  }

  .user-info-card {
    background: white;
    border-radius: 12px;
    padding: 1.5rem;
    margin-bottom: 2rem;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  }

  .info-header {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    margin-bottom: 1.5rem;
    color: #2d3748;
  }

  .info-header h3 {
    margin: 0;
    font-size: 1.25rem;
  }

  .info-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 1.5rem;
  }

  .info-item {
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
  }

  .label {
    color: #718096;
    font-size: 0.875rem;
    font-weight: 500;
  }

  .value {
    color: #2d3748;
    font-size: 1rem;
    font-weight: 600;
  }

  .section {
    background: white;
    border-radius: 12px;
    padding: 1.5rem;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  }

  .section-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 1.5rem;
  }

  .section-header h3 {
    margin: 0 0 0.25rem 0;
    color: #1a202c;
    font-size: 1.5rem;
  }

  .section-header p {
    margin: 0;
    color: #718096;
    font-size: 0.875rem;
  }

  .btn-refresh {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.5rem 1rem;
    background: #f7fafc;
    border: 1px solid #e2e8f0;
    border-radius: 8px;
    color: #4a5568;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s;
  }

  .btn-refresh:hover:not(:disabled) {
    background: #edf2f7;
  }

  .btn-refresh:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }

  .spinning {
    animation: spin 1s linear infinite;
  }

  @keyframes spin {
    to { transform: rotate(360deg); }
  }

  .loading-state, .empty-state, .error-state {
    text-align: center;
    padding: 3rem 2rem;
  }

  .spinner-large {
    width: 48px;
    height: 48px;
    border: 4px solid #e2e8f0;
    border-top-color: #667eea;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
    margin: 0 auto 1rem;
  }

  .empty-state svg {
    color: #cbd5e0;
    margin-bottom: 1rem;
  }

  .empty-state h3 {
    margin: 0 0 0.5rem 0;
    color: #2d3748;
  }

  .empty-state p {
    margin: 0;
    color: #718096;
  }

  .error-state svg {
    color: #fc8181;
    margin-bottom: 1rem;
  }

  .error-state p {
    color: #c53030;
    margin: 0;
  }

  .table-container {
    overflow-x: auto;
  }

  table {
    width: 100%;
    border-collapse: collapse;
  }

  thead {
    background: #f7fafc;
  }

  th {
    padding: 0.75rem 1rem;
    text-align: left;
    font-weight: 600;
    color: #4a5568;
    font-size: 0.875rem;
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }

  td {
    padding: 1rem;
    border-top: 1px solid #e2e8f0;
    color: #2d3748;
  }

  .mono {
    font-family: 'Courier New', monospace;
    font-size: 0.875rem;
  }

  .status-badge {
    display: inline-flex;
    align-items: center;
    gap: 0.375rem;
    padding: 0.375rem 0.75rem;
    border-radius: 9999px;
    font-size: 0.875rem;
    font-weight: 500;
  }

  .status-badge.success {
    background: #c6f6d5;
    color: #22543d;
  }

  .status-badge.failure {
    background: #fed7d7;
    color: #742a2a;
  }

  .failure-reason {
    margin-top: 0.25rem;
    font-size: 0.75rem;
    color: #e53e3e;
  }

  .location {
    display: flex;
    align-items: center;
    gap: 0.375rem;
  }

  .device-info {
    font-size: 0.875rem;
    color: #718096;
    max-width: 300px;
  }

  @media (max-width: 768px) {
    .nav-content {
      padding: 0 1rem;
    }

    .container {
      padding: 0 1rem;
    }

    .user-name {
      display: none;
    }

    .section-header {
      flex-direction: column;
      gap: 1rem;
    }

    .btn-refresh {
      align-self: flex-end;
    }

    .table-container {
      font-size: 0.875rem;
    }

    th, td {
      padding: 0.5rem;
    }
  }
</style>
