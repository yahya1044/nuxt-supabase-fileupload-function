export default defineNuxtRouteMiddleware((to, from) => {
  const user = useSupabaseUser();
  console.log("wwww", user);

  // Redirect to login if not authenticated and trying to access a protected route
  if (!user.value && to.path !== "/login") {
    return navigateTo("/login");
  }

  // Redirect authenticated users away from login
  if (user.value && to.path === "/login") {
    return navigateTo("/"); // Or the desired authenticated route
  }
});
