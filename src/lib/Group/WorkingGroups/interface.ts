import type { GroupUser } from "../interface";

export interface WorkGroup {
  name: string;
  members: number | null;
  direct_join: boolean;
  id: number;
  work_group_id: number;
  member_count: number;
  total_page: number;
  joined: boolean
  next: string;
  previous: string;
  chat: 1;
  requested_access: boolean;
  group_id?: number;
}

export interface WorkGroupUser {
  id: number;
  work_group_id: number;
  work_group_name: string;
  group_user: {
    id: number;
    user: {
      id: number;
      username: string;
      profile_image: string;
      banner_image: string;
    };
    is_admin: boolean;
    active: boolean;
    permission_id: number;
    permission_name: string;
    group_id: number;
    group_name: string;
    group_image: string;
  };
  is_moderator: boolean;
}

export interface WorkGroupInvite {
  id: number,
  work_group_id: number,
  work_group_name: string,
  group_user: GroupUser
}
