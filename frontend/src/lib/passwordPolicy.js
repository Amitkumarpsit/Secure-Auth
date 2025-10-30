/**
 * Password policy validation
 * Returns an object with validation results for each policy point
 */
export function validatePassword(password) {
  return {
    minLength: password.length >= 8,
    hasUpperCase: /[A-Z]/.test(password),
    hasLowerCase: /[a-z]/.test(password),
    hasNumber: /\d/.test(password),
    hasSpecialChar: /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password),
  };
}

export function isPasswordValid(password) {
  const validation = validatePassword(password);
  return Object.values(validation).every((valid) => valid);
}

export const passwordPolicyRules = [
  { key: 'minLength', label: 'At least 8 characters' },
  { key: 'hasUpperCase', label: 'Contains uppercase letter' },
  { key: 'hasLowerCase', label: 'Contains lowercase letter' },
  { key: 'hasNumber', label: 'Contains a number' },
  { key: 'hasSpecialChar', label: 'Contains special character (!@#$%^&*)' },
];
