import { apiClient } from './client';
import type { ApiResponse, PollsParams } from './types';
import type { poll, Post } from '$lib/Poll/interface';
import type { WorkGroup } from '$lib/Group/WorkingGroups/interface';

export class PollsApi {
  /**
   * Fetches polls for a specific group
   */
  static async getGroupPolls(groupId: string, pollIds: number[], orderBy: string): Promise<ApiResponse<poll>> {
    return apiClient<ApiResponse<poll>>(
      `group/${groupId}/poll/list?id_list=${pollIds.join(',')}&order_by=${orderBy}`
    );
  }

  /**
   * Fetches polls for the home feed (across all groups)
   */
  static async getHomePolls(orderBy: string): Promise<ApiResponse<poll>> {
    return apiClient<ApiResponse<poll>>(`home/polls?order_by=${orderBy}&limit=1000`);
  }

  /**
   * Fetches all available workgroups (Used only for "one group" flowback)
   */
  static async getWorkGroups(): Promise<ApiResponse<WorkGroup>> {
    return apiClient<ApiResponse<WorkGroup>>('group/1/list');
  }
} 