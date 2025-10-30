<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { authApi } from '$lib/api';
  import { setUser } from '$lib/stores';
  import { getIpData } from '$lib/ipService';
  import { validatePassword, isPasswordValid, passwordPolicyRules } from '$lib/passwordPolicy';

  let name = '';
  let email = '';
  let password = '';
  let confirmPassword = '';
  let loading = false;
  let error = '';
  let success = false;
  let ipData = null;
  
  let passwordValidation = {
    minLength: false,
    hasUpperCase: false,
    hasLowerCase: false,
    hasNumber: false,
    hasSpecialChar: false,
  };

  $: passwordValidation = validatePassword(password);
  $: passwordsMatch = password && confirmPassword && password === confirmPassword;
  $: canSubmit = name && email && isPasswordValid(password) && passwordsMatch && !loading;

  onMount(async () => {
    // Fetch IP data on component mount
    ipData = await getIpData();
  });

  async function handleSubmit() {
    if (!canSubmit) return;

    loading = true;
    error = '';

    try {
      const response = await authApi.signup(name, email, password, ipData);
      success = true;
      
      // Optionally auto-login after signup
      setTimeout(() => {
        goto('/signin');
      }, 2000);
    } catch (err) {
      error = err.response?.data?.message || 'Failed to sign up. Please try again.';
      console.error('Signup error:', err);
    } finally {
      loading = false;
    }
  }
</script>

<svelte:head>
  <title>Sign Up - Authentication App</title>
</svelte:head>

<div class="container">
  <div class="card">
    <div class="card-header">
      <h1>Create Account</h1>
      <p>Join us today and experience secure authentication</p>
    </div>

    {#if success}
      <div class="success-message">
        <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
          <polyline points="22 4 12 14.01 9 11.01"></polyline>
        </svg>
        <h2>Account Created Successfully!</h2>
        <p>Redirecting to sign in...</p>
      </div>
    {:else}
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
          <label for="name">Full Name</label>
          <input
            id="name"
            type="text"
            bind:value={name}
            placeholder="John Doe"
            required
          />
        </div>

        <div class="form-group">
          <label for="email">Email Address</label>
          <input
            id="email"
            type="email"
            bind:value={email}
            placeholder="john@example.com"
            required
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
          />
        </div>

        <div class="password-policy">
          <p class="policy-title">Password Requirements:</p>
          {#each passwordPolicyRules as rule}
            <div class="policy-item" class:valid={passwordValidation[rule.key]} class:invalid={!passwordValidation[rule.key] && password}>
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                {#if passwordValidation[rule.key]}
                  <polyline points="20 6 9 17 4 12"></polyline>
                {:else}
                  <line x1="18" y1="6" x2="6" y2="18"></line>
                  <line x1="6" y1="6" x2="18" y2="18"></line>
                {/if}
              </svg>
              <span>{rule.label}</span>
            </div>
          {/each}
        </div>

        <div class="form-group">
          <label for="confirmPassword">Confirm Password</label>
          <input
            id="confirmPassword"
            type="password"
            bind:value={confirmPassword}
            placeholder="Confirm your password"
            required
          />
          {#if confirmPassword && !passwordsMatch}
            <span class="field-error">Passwords do not match</span>
          {/if}
        </div>

        {#if ipData}
          <div class="ip-info">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <circle cx="12" cy="12" r="10"></circle>
              <line x1="2" y1="12" x2="22" y2="12"></line>
              <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"></path>
            </svg>
            <span>Signing up from: {ipData.city}, {ipData.country}</span>
          </div>
        {/if}

        <button type="submit" class="btn-submit" disabled={!canSubmit}>
          {#if loading}
            <span class="spinner"></span>
            Creating Account...
          {:else}
            Sign Up
          {/if}
        </button>
      </form>

      <div class="card-footer">
        Already have an account? <a href="/signin">Sign In</a>
      </div>
    {/if}
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
    max-width: 480px;
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

  .password-policy {
    background: #f7fafc;
    border-radius: 8px;
    padding: 1rem;
    margin-bottom: 1.5rem;
  }

  .policy-title {
    margin: 0 0 0.75rem 0;
    font-weight: 600;
    font-size: 0.875rem;
    color: #2d3748;
  }

  .policy-item {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    margin-bottom: 0.5rem;
    font-size: 0.875rem;
    color: #718096;
  }

  .policy-item:last-child {
    margin-bottom: 0;
  }

  .policy-item.valid {
    color: #38a169;
  }

  .policy-item.valid svg {
    stroke: #38a169;
  }

  .policy-item.invalid {
    color: #e53e3e;
  }

  .policy-item.invalid svg {
    stroke: #e53e3e;
  }

  .field-error {
    display: block;
    color: #e53e3e;
    font-size: 0.875rem;
    margin-top: 0.25rem;
  }

  .ip-info {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.75rem 1rem;
    background: #edf2f7;
    border-radius: 8px;
    margin-bottom: 1.5rem;
    font-size: 0.875rem;
    color: #4a5568;
  }

  .ip-info svg {
    flex-shrink: 0;
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

  .success-message {
    padding: 3rem 2.5rem;
    text-align: center;
    color: #38a169;
  }

  .success-message svg {
    margin-bottom: 1rem;
  }

  .success-message h2 {
    margin: 0 0 0.5rem 0;
    color: #2f855a;
  }

  .success-message p {
    margin: 0;
    color: #68d391;
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
