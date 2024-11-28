<script>
	import Button from '$lib/Generic/Button.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import NewerDelegaions from '$lib/Group/Delegation/NewerDelegaions.svelte';
	import { _ } from 'svelte-i18n';
</script>

<Layout centered>
	<div class="bg-white p-6 shadow w-full text-left">
		<h1 class="text-xl font-semibold text-primary text-left">{$_('Automate')}</h1>
		<p>
			{$_(`Sometimes we have limited time and cannot participate fully, but still want to contribute.
			Reformum has a number of functions to automate parts of your engagement when you cannot
			participate yourself.`)}
		</p>
	</div>
	<div class="flex w-[80%] mt-6 gap-6">
		<div class="bg-white p-6 shadow">
			<ul>
				<li><input type="checkbox" /> {$_('Auto-choose meeting times')}</li>
				<li>
					<input type="checkbox" />
					{$_('Auto-vote')}
					<Button buttonStyle="primary-light" action={() => {}}>{$_('Become delegate')}</Button>
				</li>
				<li><input type="checkbox" /> {$_('Smart secretary')}</li>
			</ul>
		</div>

		<div class="bg-white p-6 shadow flex-grow">
             <NewerDelegaions />
		</div>
	</div>
</Layout>
