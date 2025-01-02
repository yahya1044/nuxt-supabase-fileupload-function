<script setup lang="ts">
const supabase = useSupabaseClient();

definePageMeta({
  middleware: "auth",
});

const login = async () => {
  const { error } = await supabase.auth.signInWithPassword({
    email: "yahya.ibrahim1044@gmail.com",
    password: "NewDay@15",
  });
  if (error) console.error("Login failed:", error);
  else {
    navigateTo("/");
  }
};

const register = async () => {
  const { error } = await supabase.auth.signUp({
    email: "yahya.ibrahim1044@gmail.com",
    password: "NewDay@15",
  });
  if (error) console.error("Login failed:", error);
  else {
    navigateTo("/");
  }
};
</script>

<template>
  <div class="flex justify-center p-10 gap-10">
    <UButton size="lg" @click="register" class="text-white">Register</UButton>
    <UButton size="lg" @click="login" class="text-white">Login</UButton>
  </div>
</template>
