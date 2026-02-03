// TODO: Delete the entire API folder

import { browser } from '$app/environment';
import { goto } from '$app/navigation';
import { env } from '$env/dynamic/public';

interface RequestOptions {
  method: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH';
  requiresAuth?: boolean;
  jsonResponse?: boolean;
  body?: unknown;
}

/**
 * Makes an authenticated API request to the backend
 * @throws {Error} If called during SSR or if authentication fails
 */
export async function apiClient<ResponseType>(
  endpoint: string,
  options: Partial<RequestOptions> = {}
): Promise<ResponseType> {
  const {
    method = 'GET',
    body = null,
    requiresAuth = true,
    jsonResponse = true,
  } = options;

  ensureClientSideExecution();
  warnIfGetRequestHasBody(method, body);

  const headers = buildHeaders({ requiresAuth, jsonResponse });
  const url = buildApiUrl(endpoint);
  
  const response = await fetch(url, {
    method,
    headers,
    ...(shouldIncludeBody(method, body) && {
      body: jsonResponse ? JSON.stringify(body) : (body as string)
    })
  });

  return handleResponse<ResponseType>(response, jsonResponse);
}

// Helper functions
function ensureClientSideExecution() {
  if (!browser) {
    throw new Error('API calls can only be made in the browser, not during SSR');
  }
}

function warnIfGetRequestHasBody(method: string, body: unknown) {
  if (method === 'GET' && body !== null) {
    console.warn('GET requests should not include a body. Use query parameters instead (e.g., /api?id=5)');
  }
}

function buildHeaders({ requiresAuth, jsonResponse }: Pick<RequestOptions, 'requiresAuth' | 'jsonResponse'>) {
  const headers: Record<string, string> = {};

  if (requiresAuth) {
    const token = localStorage.getItem('token');
    if (!token) {
      redirectToLogin();
      throw new Error('Authentication required');
    }
    headers.Authorization = `Token ${token}`;
  }

  if (jsonResponse) {
    headers.Accept = 'application/json';
    headers['Content-Type'] = 'application/json';
  }

  return headers;
}

function buildApiUrl(endpoint: string): string {
  if (endpoint.includes(env.PUBLIC_API_URL)) {
    return endpoint;
  }

  const apiPrefix = env.PUBLIC_HAS_API === 'TRUE' ? 'api/' : '';
  return `${env.PUBLIC_API_URL}/${apiPrefix}${endpoint}`;
}

function shouldIncludeBody(method: string, body: unknown): boolean {
  return method !== 'GET' && body !== null;
}

function redirectToLogin() {
  const currentPath = new URL(location.href).pathname;
  if (currentPath !== '/login') {
    goto('/login');
  }
}

async function handleResponse<T>(response: Response, jsonResponse: boolean): Promise<T> {
  if (response.status === 401) {
    redirectToLogin();
    throw new Error('Authentication expired or invalid');
  }

  if (!response.ok) {
    const data = await response.json().catch(() => ({}));
    throw new Error(data.detail || 'API request failed');
  }

  // Return undefined for void responses or empty responses
  if (response.status === 204 || response.headers.get('content-length') === '0') {
    return undefined as T;
  }

  if (!jsonResponse) {
    return {} as T;
  }

  const data = await response.json();
  return data as T;
} 