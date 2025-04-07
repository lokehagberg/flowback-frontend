import { apiClient } from './client';
import type { ApiResponse, PollsParams } from './types';
import type { poll, Post } from '$lib/Poll/interface';
import type { WorkGroup } from '$lib/Group/WorkingGroups/interface';

export class PollsApi {
  /**
   * Fetches posts based on the view context (home, group, delegate etc)
   */
  static async getPosts(infoToGet: string, params: PollsParams, delegatePoolId?: number): Promise<ApiResponse<Post>> {
    const baseUrl = this.getBaseUrl(infoToGet, delegatePoolId);
    const queryParams = new URLSearchParams();
    
    Object.entries(params).forEach(([key, value]) => {
      if (value !== undefined && value !== null) {
        queryParams.append(key, value.toString());
      }
    });

    return apiClient<ApiResponse<Post>>(`${baseUrl}?${queryParams.toString()}`);
  }

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

  private static getBaseUrl(infoToGet: string, delegatePoolId?: number): string {
    switch (infoToGet) {
      case 'home':
        return 'user/home';
      case 'delegate':
        if (!delegatePoolId) throw new Error('delegatePoolId is required for delegate view');
        return `group/poll/pool/${delegatePoolId}/votes`;
      case 'public':
        return 'home/polls';
      case 'user':
      case 'group':
        return 'user/home';
      default:
        throw new Error(`Unknown infoToGet: ${infoToGet}`);
    }
  }
} 