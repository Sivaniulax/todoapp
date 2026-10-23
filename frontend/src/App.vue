<script setup>
import AppNavbar from '@/components/AppNavbar.vue'
import GuestBanner from '@/components/GuestBanner.vue'
</script>

<template>
  <div class="page">
    <AppNavbar />
    <GuestBanner />
    <main class="container">
      <RouterView />
    </main>
    <footer class="footer">
      <span>TodoApp</span>
      <span class="rule" />
      <span>Rails API &middot; Vue 3</span>
    </footer>
  </div>
</template>
