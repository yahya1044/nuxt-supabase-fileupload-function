<template>
  <div class="flex flex-col justify-center py-6">
    <div class="w-full flex justify-end px-6 max-w-xl mx-auto">
      <UButton color="red" label="Sign Out" @click="signOut" />
    </div>

    <div class="max-w-xl w-full mx-auto px-6 pt-10">
      <UPopover overlay>
        <UButton
          color="white"
          label="Open"
          trailing-icon="i-heroicons-chevron-down-20-solid"
        />

        <template #panel>
          <div class="p-4 w-full">
            <FileUploader
              :document-types="docTypes"
              :successHandler="documentUploaded"
            />
          </div>
        </template>
      </UPopover>
    </div>
  </div>
</template>

<script setup lang="ts">
const supabase = useSupabaseClient();
const docTypes = ["CV", "COVER", "PDF"];

definePageMeta({
  middleware: "auth",
});

const signOut = async () => {
  const { error } = await supabase.auth.signOut();
  if (error) console.log(error);
  else {
    navigateTo("/login");
  }
};

const documentUploaded = (document: any) => {
  console.log(
    `Successfully uploaded document ${document.name} of type ${document.type} to url ${document.path}`
  );
};
</script>

<style scoped>
#headlessui-popover-button-v-0 {
  display: none !important;
}
</style>
