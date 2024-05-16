<script lang="ts">
	import { _ } from 'svelte-i18n';

    export let Class = ""
</script>

<div class={"flex flex-col gap-6 border p-4 " + Class}>
    <h1 class="leading-10">{$_("Flowback terms of service")}</h1>
    <p>
        {$_(`§1: the user agreeing to the terms of service means that they have acknowledged and accepted all
        of the terms fully and that they understand said terms.`)} 
    </p>
    <p>
        {$_(`§2: the user may not post anything illegal going against Swedish law, otherwise their posts will
        be reported and removed from the site. The report-responsibility lies with every group owner, by
        creating a group this responsibility has been taken on by the creator user.`)}
    </p>
    <p>{$_("§3: the user guarantees that they are a real human being.")}</p>
    <p>{$_("§4: the terms of service is to be followed by all users.")}</p>
    <p class="font-bold">{$_("Note: your username will be public on the forum.")}</p>
</div>