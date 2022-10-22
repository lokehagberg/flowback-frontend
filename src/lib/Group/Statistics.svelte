<script lang="ts">
	import { _ } from 'svelte-i18n';
	export let memberCount:number;
</script>

<div class="bg-white p-6 text-xl rounded shadow p-6">
	<div><span>{$_('Members')}: </span>{memberCount}</div>
	<div><span>{$_("Documents")}: </span>9</div>
</div>
