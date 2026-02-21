export interface report {
  title: string;
  description: string;
  group_id: number;
  post_id: number;
  post_type: 'poll' | 'thread'
  post_title?: string;
  post_description?: string;
  admin_action: "nothing" | "deleted";
}

export interface ModalButton {
  label: string;
  type: 'primary' | 'secondary' | 'warning' | 'default';
  class?: string;
  onClick: () => void;
  submit?: boolean;
}

export type poppup = {
  show?: boolean;
  message: string,
  success: boolean
}
