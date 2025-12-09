import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { Vendor } from "@/types/vendor";
import { toast } from "sonner";

export function useVendors() {
  const queryClient = useQueryClient();

  const vendorsQuery = useQuery({
    queryKey: ["vendors"],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("vendors")
        .select("*")
        .order("name");

      if (error) throw error;
      return data as Vendor[];
    },
  });

  const createVendorMutation = useMutation({
    mutationFn: async (vendorData: Partial<Vendor>) => {
      const { data, error } = await supabase
        .from("vendors")
        .insert({
          name: vendorData.name,
          email: vendorData.email || null,
          phone: vendorData.phone || null,
          address: vendorData.address || null,
          city: vendorData.city || null,
          country: vendorData.country || null,
          tax_id: vendorData.taxId || null,
          payment_terms: vendorData.paymentTerms || null,
          status: vendorData.status || "active",
        })
        .select()
        .single();

      if (error) throw error;
      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["vendors"] });
      toast.success("Vendor created successfully");
    },
    onError: (error: Error) => {
      toast.error("Failed to create vendor: " + error.message);
    },
  });

  return {
    vendors: vendorsQuery.data ?? [],
    isLoading: vendorsQuery.isLoading,
    error: vendorsQuery.error,
    createVendor: createVendorMutation.mutateAsync,
    refetch: () => queryClient.invalidateQueries({ queryKey: ["vendors"] }),
  };
}
