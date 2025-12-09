-- Setup Row Level Security (RLS) policies for all application tables
-- This file should be run AFTER 03_setup_auth_rls_policies.sql

-- ============================================================================
-- SECURITY DEFINER FUNCTIONS
-- ============================================================================

-- Function to check if user has a specific role
CREATE OR REPLACE FUNCTION public.has_role(_user_id UUID, _role app_role)
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.user_roles
        WHERE user_id = _user_id
        AND role = _role
    )
$$;

-- Function to check if user has any of the specified roles
CREATE OR REPLACE FUNCTION public.has_any_role(_user_id UUID, _roles app_role[])
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.user_roles
        WHERE user_id = _user_id
        AND role = ANY(_roles)
    )
$$;

-- ============================================================================
-- ENABLE RLS ON ALL TABLES
-- ============================================================================

ALTER TABLE module_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendors ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales_line_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_line_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE payroll ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_logs ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- MODULE PERMISSIONS TABLE POLICIES
-- ============================================================================

CREATE POLICY "All users can view permissions"
ON module_permissions FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Admins can manage permissions"
ON module_permissions FOR ALL
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- ============================================================================
-- DEPARTMENTS TABLE POLICIES
-- ============================================================================

CREATE POLICY "All users can view departments"
ON departments FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Authorized users can create departments"
ON departments FOR INSERT
TO authenticated
WITH CHECK (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'hr']::app_role[]));

CREATE POLICY "Authorized users can update departments"
ON departments FOR UPDATE
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'hr']::app_role[]));

CREATE POLICY "Admins can delete departments"
ON departments FOR DELETE
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- ============================================================================
-- ACCOUNTS TABLE POLICIES
-- ============================================================================

CREATE POLICY "All users can view accounts"
ON accounts FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Authorized users can create accounts"
ON accounts FOR INSERT
TO authenticated
WITH CHECK (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'accountant']::app_role[]));

CREATE POLICY "Authorized users can update accounts"
ON accounts FOR UPDATE
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'accountant']::app_role[]));

CREATE POLICY "Admins can delete accounts"
ON accounts FOR DELETE
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- ============================================================================
-- CUSTOMERS TABLE POLICIES
-- ============================================================================

CREATE POLICY "Authorized users can view customers"
ON customers FOR SELECT
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'accountant', 'sales']::app_role[]));

CREATE POLICY "Authorized users can create customers"
ON customers FOR INSERT
TO authenticated
WITH CHECK (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'sales']::app_role[]));

CREATE POLICY "Authorized users can update customers"
ON customers FOR UPDATE
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'sales']::app_role[]));

CREATE POLICY "Admins can delete customers"
ON customers FOR DELETE
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- ============================================================================
-- VENDORS TABLE POLICIES
-- ============================================================================

CREATE POLICY "Authorized users can view vendors"
ON vendors FOR SELECT
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'accountant', 'inventory']::app_role[]));

CREATE POLICY "Authorized users can create vendors"
ON vendors FOR INSERT
TO authenticated
WITH CHECK (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'inventory']::app_role[]));

CREATE POLICY "Authorized users can update vendors"
ON vendors FOR UPDATE
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'inventory']::app_role[]));

CREATE POLICY "Admins can delete vendors"
ON vendors FOR DELETE
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- ============================================================================
-- PRODUCTS TABLE POLICIES
-- ============================================================================

CREATE POLICY "All users can view products"
ON products FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Authorized users can create products"
ON products FOR INSERT
TO authenticated
WITH CHECK (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'inventory', 'sales']::app_role[]));

CREATE POLICY "Authorized users can update products"
ON products FOR UPDATE
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'inventory', 'sales']::app_role[]));

CREATE POLICY "Admins can delete products"
ON products FOR DELETE
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- ============================================================================
-- STOCK MOVEMENTS TABLE POLICIES
-- ============================================================================

CREATE POLICY "Authorized users can view stock movements"
ON stock_movements FOR SELECT
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'inventory']::app_role[]));

CREATE POLICY "Authorized users can create stock movements"
ON stock_movements FOR INSERT
TO authenticated
WITH CHECK (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'inventory']::app_role[]));

-- ============================================================================
-- TRANSACTIONS TABLE POLICIES
-- ============================================================================

CREATE POLICY "Authorized users can view transactions"
ON transactions FOR SELECT
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'accountant']::app_role[]));

CREATE POLICY "Authorized users can create transactions"
ON transactions FOR INSERT
TO authenticated
WITH CHECK (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'accountant']::app_role[]));

CREATE POLICY "Authorized users can update transactions"
ON transactions FOR UPDATE
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'accountant']::app_role[]));

CREATE POLICY "Admins can delete transactions"
ON transactions FOR DELETE
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- ============================================================================
-- SALES ORDERS TABLE POLICIES
-- ============================================================================

CREATE POLICY "Authorized users can view sales"
ON sales_orders FOR SELECT
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'accountant', 'sales']::app_role[]));

CREATE POLICY "Authorized users can create sales"
ON sales_orders FOR INSERT
TO authenticated
WITH CHECK (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'sales']::app_role[]));

CREATE POLICY "Authorized users can update sales"
ON sales_orders FOR UPDATE
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'sales']::app_role[]));

CREATE POLICY "Admins can delete sales"
ON sales_orders FOR DELETE
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- ============================================================================
-- SALES LINE ITEMS TABLE POLICIES
-- ============================================================================

CREATE POLICY "Users with sales access can view line items"
ON sales_line_items FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM sales_orders
        WHERE id = sales_line_items.sale_id
        AND public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'accountant', 'sales']::app_role[])
    )
);

CREATE POLICY "Authorized users can manage line items"
ON sales_line_items FOR ALL
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'sales']::app_role[]));

-- ============================================================================
-- PURCHASE ORDERS TABLE POLICIES
-- ============================================================================

CREATE POLICY "Authorized users can view purchases"
ON purchase_orders FOR SELECT
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'accountant', 'inventory']::app_role[]));

CREATE POLICY "Authorized users can create purchases"
ON purchase_orders FOR INSERT
TO authenticated
WITH CHECK (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'inventory']::app_role[]));

CREATE POLICY "Authorized users can update purchases"
ON purchase_orders FOR UPDATE
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'inventory']::app_role[]));

CREATE POLICY "Admins can delete purchases"
ON purchase_orders FOR DELETE
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- ============================================================================
-- PURCHASE LINE ITEMS TABLE POLICIES
-- ============================================================================

CREATE POLICY "Users with purchase access can view line items"
ON purchase_line_items FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM purchase_orders
        WHERE id = purchase_line_items.purchase_order_id
        AND public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'accountant', 'inventory']::app_role[])
    )
);

CREATE POLICY "Authorized users can manage line items"
ON purchase_line_items FOR ALL
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'inventory']::app_role[]));

-- ============================================================================
-- EMPLOYEES TABLE POLICIES
-- ============================================================================

CREATE POLICY "Authorized users can view employees"
ON employees FOR SELECT
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'hr']::app_role[]));

CREATE POLICY "Authorized users can create employees"
ON employees FOR INSERT
TO authenticated
WITH CHECK (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'hr']::app_role[]));

CREATE POLICY "Authorized users can update employees"
ON employees FOR UPDATE
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'hr']::app_role[]));

CREATE POLICY "Admins can delete employees"
ON employees FOR DELETE
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- ============================================================================
-- PAYROLL TABLE POLICIES
-- ============================================================================

CREATE POLICY "Authorized users can view payroll"
ON payroll FOR SELECT
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'hr', 'accountant']::app_role[]));

CREATE POLICY "Authorized users can create payroll"
ON payroll FOR INSERT
TO authenticated
WITH CHECK (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'hr']::app_role[]));

CREATE POLICY "Authorized users can update payroll"
ON payroll FOR UPDATE
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'hr']::app_role[]));

CREATE POLICY "Admins can delete payroll"
ON payroll FOR DELETE
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- ============================================================================
-- ACTIVITY LOGS TABLE POLICIES
-- ============================================================================

CREATE POLICY "Users can view own activity"
ON activity_logs FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "Admins and managers can view all activity"
ON activity_logs FOR SELECT
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager']::app_role[]));

CREATE POLICY "All users can create activity logs"
ON activity_logs FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Admins can delete activity logs"
ON activity_logs FOR DELETE
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- ============================================================================
-- PRODUCT CATEGORIES TABLE POLICIES
-- ============================================================================

CREATE POLICY "All users can view categories"
ON product_categories FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Authorized users can manage categories"
ON product_categories FOR ALL
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'inventory']::app_role[]));

