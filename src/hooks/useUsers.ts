import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { User, AppRole } from "@/types/user";
import { toast } from "@/lib/toast";

export function useUsers() {
  const queryClient = useQueryClient();

  const usersQuery = useQuery({
    queryKey: ["users"],
    queryFn: async () => {
      // Fetch profiles with their roles in a single query using join
      const { data: profiles, error: profilesError } = await supabase
        .from("profiles")
        .select(`
          *,
          user_roles!left(role)
        `)
        .order("created_at", { ascending: false })
        .limit(500); // Limit to prevent slow queries

      if (profilesError) {
        console.error("Error fetching profiles:", profilesError);
        throw profilesError;
      }

      if (!profiles) return [];

      return profiles.map((profile: any) => {
        // Handle the joined user_roles (can be array or single object)
        const roleData = profile.user_roles;
        let role: AppRole = "viewer";
        
        if (Array.isArray(roleData) && roleData.length > 0) {
          role = roleData[0].role as AppRole;
        } else if (roleData && roleData.role) {
          role = roleData.role as AppRole;
        }

        return {
          id: profile.id,
          name: profile.name || "",
          email: profile.email,
          role,
          status: profile.status || "active",
          avatar: profile.avatar_url,
          createdAt: profile.created_at,
          lastLogin: profile.last_login,
        } as User;
      });
    },
    staleTime: 30000, // Cache for 30 seconds
  });

  const updateUserRole = useMutation({
    mutationFn: async ({ userId, role }: { userId: string; role: AppRole }) => {
      // Check if user already has a role
      const { data: existing } = await supabase
        .from("user_roles")
        .select("*")
        .eq("user_id", userId)
        .single();

      if (existing) {
        const { error } = await supabase
          .from("user_roles")
          .update({ role })
          .eq("user_id", userId);
        if (error) throw error;
      } else {
        const { error } = await supabase
          .from("user_roles")
          .insert({ user_id: userId, role });
        if (error) throw error;
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["users"] });
      toast.success("User role updated successfully");
    },
    onError: (error: Error) => {
      toast.error("Failed to update user role", error.message);
    },
  });

  const updateUserStatus = useMutation({
    mutationFn: async ({ userId, status }: { userId: string; status: "active" | "inactive" }) => {
      const { error } = await supabase
        .from("profiles")
        .update({ status })
        .eq("id", userId);
      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["users"] });
      toast.success("User status updated successfully");
    },
    onError: (error: Error) => {
      toast.error("Failed to update user status", error.message);
    },
  });

  const updateUser = useMutation({
    mutationFn: async ({ userId, data }: { userId: string; data: Partial<User> }) => {
      // Update profile
      const { error: profileError } = await supabase
        .from("profiles")
        .update({
          name: data.name,
          status: data.status,
        })
        .eq("id", userId);

      if (profileError) throw profileError;

      // Update role if provided
      if (data.role) {
        const { data: existing } = await supabase
          .from("user_roles")
          .select("*")
          .eq("user_id", userId)
          .maybeSingle();

        if (existing) {
          const { error } = await supabase
            .from("user_roles")
            .update({ role: data.role })
            .eq("user_id", userId);
          if (error) throw error;
        } else {
          const { error } = await supabase
            .from("user_roles")
            .insert({ user_id: userId, role: data.role });
          if (error) throw error;
        }
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["users"] });
      toast.success("User updated successfully");
    },
    onError: (error: Error) => {
      toast.error("Failed to update user", error.message);
    },
  });

  return {
    users: usersQuery.data ?? [],
    isLoading: usersQuery.isLoading,
    error: usersQuery.error,
    updateUserRole: updateUserRole.mutateAsync,
    updateUserStatus: updateUserStatus.mutateAsync,
    updateUser: updateUser.mutateAsync,
  };
}
