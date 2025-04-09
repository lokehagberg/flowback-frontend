import { apiClient } from './client';
import type { User } from '$lib/User/interfaces';

export class UsersApi {
    static async getCurrentUser(): Promise<User> {
        return apiClient<User>('user');
    }

    static async logout(): Promise<void> {
        await apiClient<void>('logout', {
            method: 'POST'
        });
    }
} 