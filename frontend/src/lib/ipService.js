/**
 * Get user's IP and location information
 * Using ipapi.co for IP geolocation
 */
export async function getIpData() {
  try {
    const response = await fetch('https://ipapi.co/json/');
    if (!response.ok) {
      throw new Error('Failed to fetch IP data');
    }
    const data = await response.json();
    return {
      ip: data.ip,
      country: data.country_name,
      city: data.city,
    };
  } catch (error) {
    console.error('Error fetching IP data:', error);
    // Return default values if IP lookup fails
    return {
      ip: 'unknown',
      country: 'unknown',
      city: 'unknown',
    };
  }
}
