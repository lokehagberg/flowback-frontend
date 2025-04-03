import { apiClient } from './client';
import type { timeProposal } from '$lib/Poll/interface';
import type { ApiResponse } from './types';

interface ScheduleProposal {
  start_date: Date;
  end_date: Date;
}

export class SchedulesApi {
  static async getProposals(pollId: string): Promise<ApiResponse<timeProposal>> {
    return apiClient<ApiResponse<timeProposal>>(`group/poll/${pollId}/proposals?limit=10000`);
  }

  static async getVotes(pollId: string): Promise<ApiResponse<{ proposal: number }>> {
    return apiClient<ApiResponse<{ proposal: number }>>(`group/poll/${pollId}/proposal/votes?limit=10000`);
  }

  static async createProposal(pollId: string, proposal: ScheduleProposal): Promise<number> {
    return apiClient<number>(`group/poll/${pollId}/proposal/create`, {
      method: 'POST',
      body: proposal
    });
  }

  static async updateVotes(pollId: string, proposals: number[]): Promise<void> {
    await apiClient(`group/poll/${pollId}/proposal/vote/update`, {
      method: 'POST',
      body: { proposals }
    });
  }
} 