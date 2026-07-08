Supabase RLS enabled on all public app tables.
Basic authenticated policies created.
Collection access is controlled through collection_members.
Products are read-only for authenticated users.
Audit log and collection_stats are not client-writable.
Next risk area: collection creation must create collection_members row for the owner/user.