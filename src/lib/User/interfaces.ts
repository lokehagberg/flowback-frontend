import { writable } from 'svelte/store';

export interface User {
  banner_image: string;
  bio: string;
  email: string;
  profile_image?: string;
  profile_image_file?: File;
  banner_image_file?: File;
  username: string;
  website: string;
  id: number;
  contact_email: string;
  contact_phone: string;
  is_active: boolean
}

export interface GroupUser {
  banner_image: File | null;
  delegate: boolean;
  id: number;
  is_admin: boolean;
  permission_id: number | null;
  permission_name: string;
  profile_image: null;
  user_id: number;
  username: string;
  user: User;
  group_id: number;
}

export const userStore = writable<User | null>(null);
