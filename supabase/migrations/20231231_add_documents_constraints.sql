-- Update documents table to add NOT NULL constraints
ALTER TABLE documents
ALTER COLUMN path SET NOT NULL,
ALTER COLUMN type SET NOT NULL,
ALTER COLUMN name SET NOT NULL;

-- Add check constraints to ensure non-empty strings
ALTER TABLE documents
ADD CONSTRAINT documents_path_not_empty CHECK (path <> ''),
ADD CONSTRAINT documents_type_not_empty CHECK (type <> ''),
ADD CONSTRAINT documents_name_not_empty CHECK (name <> '');
