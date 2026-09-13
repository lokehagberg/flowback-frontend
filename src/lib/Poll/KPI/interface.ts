import type { GroupUser } from '$lib/Group/interface';
import type { proposal } from '$lib/Poll/interface';

export interface KPI {
  id: number;
  name: string;
  description: string;
  active: boolean;
  values: string[];
}

export interface KPIBetProposal {
  id: number;
  created_by: GroupUser;
  proposal: proposal;
  kpi_id: number;
  kpi_name: string;
  kpi_description: string;
  value: string;
  weight: number;
}

export interface KPIEvaluation {
  id: number;
  kpi_id: number;
  kpi_name: string;
  kpi_description: string;
  vote: string;
  proposal: proposal;
  created_by: GroupUser;
}

export interface CombinedBet {
  id: number;
  proposal: proposal;
  kpi_id: number;
  kpi_name: string;
  kpi_description: string | null;
  value: string;
  combined_bet: string | null;
  outcome: boolean;
}
