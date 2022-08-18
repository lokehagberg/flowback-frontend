<script lang="ts">
  let onHoverGroup = false;
</script>

<div class="bg-white pt-3 pl-6 pr-6 pb-3 shadow-lg rounded cursor-pointer vote-thumbnail"
on:click={() => {onHoverGroup ? window.location.href = "/groups/1" : window.location.href = "/poll"}}
>
      <h1 class="text-left text-blue-500 hover:underline text-3xl p-2 pl-0">Vote to destroy Lithuania</h1>
      <p class="mt-2">I really think we should do it. Please click here to post ways to do it Lorem, ipsum dolor sit amet consectetur adipisicing elit. Magnam nemo praesentium, dolore voluptatum adipisci quidem enim at animi cum alias omnis. A at reiciendis quasi repellendus laudantium pariatur reprehenderit eius?</p>
      <div class="flex justify-between text-sm text-gray-600 mt-4">
        <p class="hover:underline" on:mouseover={() => onHoverGroup = true} on:mouseleave={() => onHoverGroup = false} on:click={() => window.location.href = '/groups/1'}>We hate lithuania for no reason</p>
        <p>Finishes at 2022-08-12</p>
        <p>5 proposals</p>
      </div>
    </div>

<style>
  .vote-thumbnail:hover{
    outline: 2px #ccc solid
  }
</style>

