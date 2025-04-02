import { apiClient } from './client';
import type { ApiResponse, PollsParams } from './types';
import type { poll, Post } from '$lib/Poll/interface';
import type { Thread } from '$lib/Group/interface';
import type { WorkGroup } from '$lib/Group/WorkingGroups/interface';

export class PollsApi {
  static async getPosts(infoToGet: string, params: PollsParams, delegatePoolId?: number): Promise<ApiResponse<Post>> {
    const baseUrl = this.getBaseUrl(infoToGet, delegatePoolId);
    const queryParams = new URLSearchParams();
    
    Object.entries(params).forEach(([key, value]) => {
      if (value !== undefined && value !== null) {
        queryParams.append(key, value.toString());
      }
    });

    return apiClient<ApiResponse<Post>>(`${baseUrl}?${queryParams.toString()}`, {
      method: 'GET',
      requiresAuth: true,
      jsonResponse: true,
    });
  }

  static async getPolls(groupId: string | null, pollIds: number[], orderBy: string): Promise<ApiResponse<poll>> {
    const url = groupId
      ? `group/${groupId}/poll/list?id_list=${pollIds.join(',')}&order_by=${orderBy}`
      : `home/polls?order_by=${orderBy}`;
    
    return apiClient<ApiResponse<poll>>(url, {
      method: 'GET',
      requiresAuth: true,
      jsonResponse: true,
    });
  }

  static async getThreads(groupId: string | null, threadIds: number[], orderBy: string): Promise<ApiResponse<Thread>> {
    const url = groupId
      ? `group/thread/list?group_ids=${groupId}&limit=1000&order_by=pinned,${orderBy}&id_list=${threadIds.join(',')}`
      : `group/thread/list?group_ids=1,2,3,4&order_by=${orderBy}`;
    
    return apiClient<ApiResponse<Thread>>(url, {
      method: 'GET',
      requiresAuth: true,
      jsonResponse: true,
    });
  }

  static async getWorkGroups(): Promise<ApiResponse<WorkGroup>> {
    return apiClient<ApiResponse<WorkGroup>>('group/1/list', {
      method: 'GET',
      requiresAuth: true,
      jsonResponse: true,
    });
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