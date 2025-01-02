<script setup lang="ts">
import { defineProps, ref } from "vue";

const props = defineProps<{
  documentTypes: string[];
  successHandler: (document: any) => void;
}>();

const supabase = useSupabaseClient();
const user = useSupabaseUser();
const selectedFile = ref<File | null>(null);
const isUploading = ref(false);

const state = ref({
  documentName: "",
  documentType: "",
  file: null,
});

const validation = {
  documentName: {
    validate: (value: string) => !!value,
    errorMessage: "Document name is required",
  },
  documentType: {
    validate: (value: string) => !!value,
    errorMessage: "Document type is required",
  },
  file: {
    validate: (value: File | null) => !!value,
    errorMessage: "Please select a file",
  },
};

const validateForm = () => {
  const errors = [];
  if (!state.value.documentName) {
    errors.push("Document name is required");
  }
  if (!state.value.documentType) {
    errors.push("Document type is required");
  }
  if (!selectedFile.value) {
    errors.push("Please select a file");
  }
  return errors;
};

const convertToUnderscore = () => {
  state.value.documentName = state.value.documentName.replace(/\s+/g, "_");
};

const handleFileChange = (files: FileList) => {
  if (files && files[0]) {
    selectedFile.value = files[0];
  }
};

const uploadDocument = async (data: any) => {
  const errors = validateForm();
  if (errors.length > 0) {
    alert(errors.join("\n"));
    return;
  }

  try {
    isUploading.value = true;

    if (!user.value) throw new Error("User not authenticated");

    const fileExt = selectedFile.value?.type.split("/").pop();
    const path = `${user.value.id}/${state.value.documentType}/${state.value.documentName}.${fileExt}`;

    // Start a Supabase transaction
    const { data, error } = await supabase
      .from("documents")
      .upsert({
        user_id: user.value.id,
        path,
        type: state.value.documentType,
        name: `${state.value.documentName}.${fileExt}`,
      })
      .select()
      .single();

    if (error) throw error;

    try {
      // Attempt file upload
      const { error: uploadError } = await supabase.storage
        .from("documents")
        .upload(path, selectedFile.value as File);

      if (uploadError) {
        // If upload fails, delete the database record
        await supabase.from("documents").delete().match({ id: data.id });
        throw uploadError;
      }

      props.successHandler(data);
      alert("Document uploaded successfully!");

      // Reset form
      selectedFile.value = null;
      state.value = {
        documentName: "",
        documentType: "",
        file: null,
      };
    } catch (error) {
      // Clean up any partial uploads
      await supabase.storage.from("documents").remove([path]);
      throw error;
    }
  } catch (error: any) {
    console.error("Error uploading document:", error);
    alert(error.message || "Failed to upload document. Please try again.");
  } finally {
    isUploading.value = false;
  }
};
</script>

<template>
  <UForm
    :state="state"
    :validation="validation"
    @submit="uploadDocument"
    class="flex flex-col gap-4"
  >
    <UFormGroup label="Document Name" name="documentName">
      <UInput
        v-model="state.documentName"
        @update:modelValue="convertToUnderscore"
        placeholder="Enter document name"
      />
    </UFormGroup>

    <UFormGroup label="Document Type" name="documentType">
      <USelect
        v-model="state.documentType"
        :options="documentTypes"
        placeholder="Select..."
      />
    </UFormGroup>

    <UFormGroup label="Upload Document" name="file">
      <UInput
        type="file"
        size="sm"
        icon="i-heroicons-folder"
        @change="handleFileChange"
        accept=".csv, .pdf"
      />
    </UFormGroup>

    <UButton
      type="submit"
      :loading="isUploading"
      :disabled="isUploading"
      class="w-fit"
    >
      Upload
    </UButton>
  </UForm>
</template>
