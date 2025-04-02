import { browser } from '$app/environment';
import { goto } from '$app/navigation';
import { env } from '$env/dynamic/public';

type FetchOptions = {
  method: string;
  headers?: Record<string, string>;
  body?: string | null;
  needs_authorization?: boolean;
  needs_json?: boolean;
};

export async function apiClient<T>(
  endpoint: string, 
  options: Partial<FetchOptions> = {}
): Promise<T> {
  const {
    method = 'GET',
    body = null,
    needs_authorization = true,
    needs_json = true,
  } = options;

  if (method === 'GET' && body !== null) {
    console.warn("Method 'GET' does not take any body, use query parameters instead. For example: /api?id=5");
  }

  if (!browser) {
    throw new Error('Cannot make API calls during SSR');
  }

  let headers: Record<string, string> = {};

  // Handle authorization
  if (needs_authorization) {
    const token = localStorage.getItem('token');
    const relativePath = new URL(location.href).pathname;

    if (token) {
      headers.Authorization = `Token ${token}`;
    } else if (relativePath !== '/login') {
      goto('/login');
      throw new Error('Not authenticated');
    }
  }

  // Handle JSON headers
  if (needs_json) {
    headers.Accept = 'application/json';
    headers['Content-Type'] = 'application/json';
  }

  // Construct URL
  const url = endpoint.includes(env.PUBLIC_API_URL)
    ? endpoint
    : `${env.PUBLIC_API_URL}/${env.PUBLIC_HAS_API === 'TRUE' ? 'api/' : ''}${endpoint}`;

  // Prepare request options
  const fetchOptions: RequestInit = {
    method,
    headers,
  };

  if (method !== 'GET' && body !== null) {
    fetchOptions.body = needs_json ? JSON.stringify(body) : body;
  }

  const response = await fetch(url, fetchOptions);

  // Handle 401 unauthorized
  if (response.status === 401) {
    const relativePath = new URL(location.href).pathname;
    if (relativePath !== '/login') {
      goto('/login');
      throw new Error('Not authenticated');
    }
  }

  // Handle response
  try {
    const data = await response.json();
    if (!response.ok) {
      throw new Error(data.detail || 'API call failed');
    }
    return data as T;
  } catch (error) {
    if (!response.ok) {
      throw new Error('API call failed');
    }
    return {} as T;
  }
} 