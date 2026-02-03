import { writable } from "svelte/store";
import type { Group } from "../interface";
import type { WorkGroup } from "../WorkingGroups/interface";

export interface kanban {
  assignee: { id: number; profile_image: string; username: string } | null;

  created_by: {
    id: number;
    profile_image: string | null;
    username: string;
  };
  description: string | null;
  id: number;
  lane: number;
  work_group?: { name: string; id: number };
  title: string;
  origin_id: number;
  origin_type: 'group' | 'user';
  group_name: string;
  priority?: number | null;
  end_date?: string | null;
  attachments: { id: number; file: string; file_name: string }[];
}

export interface kanbanEdited {
  entry_id: number;
  description: string | null;
  title: string;
  assignee_id?: number | null;
  priority?: number | null;
  end_date?: string | null;
  attachments?: { id: number; file: string; file_name: string }[];
  work_group?: { name: string; id: number } | null;
}

export interface Filter {
  assignee: number | null;
  group: string | null;
  workgroup: number | null;
  search: string;
  type: 'home' | 'group'
}

// TODO: Move to more appropriate location
export let groupStore = writable<Group[]>([]);
export let workgroupStore = writable<WorkGroup[]>([]);
