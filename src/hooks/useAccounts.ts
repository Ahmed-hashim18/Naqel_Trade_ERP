import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { Account, AccountType, AccountStatus } from "@/types/account";
import { toast } from "@/lib/toast";

export function useAccounts() {
  const queryClient = useQueryClient();

  const accountsQuery = useQuery({
    queryKey: ["accounts"],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("accounts")
        .select("*")
        .order("code");

      if (error) throw error;
      
      return data.map((acc) => ({
        id: acc.id,
        code: acc.code,
        name: acc.name,
        type: acc.type as AccountType,
        parentId: acc.parent_id,
        balance: acc.balance,
        description: acc.description,
        status: acc.status as AccountStatus,
        createdAt: new Date(acc.created_at),
        updatedAt: new Date(acc.updated_at),
      })) as Account[];
    },
  });

  const createAccount = useMutation({
    mutationFn: async (accountData: Partial<Account>) => {
      const { data, error } = await supabase
        .from("accounts")
        .insert({
          code: accountData.code,
          name: accountData.name,
          type: accountData.type,
          parent_id: accountData.parentId,
          balance: accountData.balance || 0,
          description: accountData.description,
          status: accountData.status || "active",
        })
        .select()
        .single();

      if (error) throw error;
      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["accounts"] });
      toast.success("Account created successfully");
    },
    onError: (error: Error) => {
      toast.error("Failed to create account", error.message);
    },
  });

  const updateAccount = useMutation({
    mutationFn: async ({ id, data }: { id: string; data: Partial<Account> }) => {
      const { error } = await supabase
        .from("accounts")
        .update({
          code: data.code,
          name: data.name,
          type: data.type,
          parent_id: data.parentId,
          balance: data.balance,
          description: data.description,
          status: data.status,
        })
        .eq("id", id);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["accounts"] });
      toast.success("Account updated successfully");
    },
    onError: (error: Error) => {
      toast.error("Failed to update account", error.message);
    },
  });

  const deleteAccount = useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from("accounts").delete().eq("id", id);
      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["accounts"] });
      toast.success("Account deleted successfully");
    },
    onError: (error: Error) => {
      toast.error("Failed to delete account", error.message);
    },
  });

  const bulkDeleteAccounts = useMutation({
    mutationFn: async (ids: string[]) => {
      const { error } = await supabase.from("accounts").delete().in("id", ids);
      if (error) throw error;
    },
    onSuccess: (_, ids) => {
      queryClient.invalidateQueries({ queryKey: ["accounts"] });
      toast.success(`${ids.length} account(s) deleted successfully`);
    },
    onError: (error: Error) => {
      toast.error("Failed to delete accounts", error.message);
    },
  });

  const bulkUpdateStatus = useMutation({
    mutationFn: async ({ ids, status }: { ids: string[]; status: AccountStatus }) => {
      const { error } = await supabase
        .from("accounts")
        .update({ status })
        .in("id", ids);

      if (error) throw error;
    },
    onSuccess: (_, { ids }) => {
      queryClient.invalidateQueries({ queryKey: ["accounts"] });
      toast.success(`${ids.length} account(s) updated successfully`);
    },
    onError: (error: Error) => {
      toast.error("Failed to update accounts", error.message);
    },
  });

  return {
    accounts: accountsQuery.data ?? [],
    isLoading: accountsQuery.isLoading,
    error: accountsQuery.error,
    createAccount: createAccount.mutateAsync,
    updateAccount: updateAccount.mutateAsync,
    deleteAccount: deleteAccount.mutateAsync,
    bulkDeleteAccounts: bulkDeleteAccounts.mutateAsync,
    bulkUpdateStatus: bulkUpdateStatus.mutateAsync,
  };
}
