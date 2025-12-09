-- NaqelERP Row Level Security (RLS) Policies
-- Comprehensive security policies for all tables

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

-- Function to check if user can perform action on module
CREATE OR REPLACE FUNCTION public.can_perform_action(
    _user_id UUID,
    _module TEXT,
    _action TEXT
)
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.user_roles ur
        JOIN public.module_permissions mp ON ur.role = (
            SELECT role_type FROM public.roles WHERE id = mp.role_id
        )
        WHERE ur.user_id = _user_id
        AND mp.module = _module
        AND (
            (_action = 'create' AND mp.can_create = true) OR
            (_action = 'read' AND mp.can_read = true) OR
            (_action = 'update' AND mp.can_update = true) OR
            (_action = 'delete' AND mp.can_delete = true) OR
            (_action = 'export' AND mp.can_export = true)
        )
    )
$$;

-- ============================================================================
-- ENABLE RLS ON ALL TABLES
-- ============================================================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
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
-- PROFILES TABLE POLICIES
-- ============================================================================

-- Users can view their own profile
CREATE POLICY "Users can view own profile"
ON profiles FOR SELECT
TO authenticated
USING (auth.uid() = id);

-- Admins and managers can view all profiles
CREATE POLICY "Admins and managers can view all profiles"
ON profiles FOR SELECT
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager']::app_role[]));

-- Users can update their own profile (except role)
CREATE POLICY "Users can update own profile"
ON profiles FOR UPDATE
TO authenticated
USING (auth.uid() = id);

-- Admins can update any profile
CREATE POLICY "Admins can update all profiles"
ON profiles FOR UPDATE
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- ============================================================================
-- USER ROLES TABLE POLICIES
-- ============================================================================

-- Admins can manage all user roles
CREATE POLICY "Admins can manage user roles"
ON user_roles FOR ALL
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- Users can view their own roles
CREATE POLICY "Users can view own roles"
ON user_roles FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- ============================================================================
-- ROLES TABLE POLICIES
-- ============================================================================

-- All authenticated users can view roles
CREATE POLICY "All users can view roles"
ON roles FOR SELECT
TO authenticated
USING (true);

-- Only admins can manage roles
CREATE POLICY "Admins can manage roles"
ON roles FOR ALL
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- ============================================================================
-- MODULE PERMISSIONS TABLE POLICIES
-- ============================================================================

-- All authenticated users can view permissions
CREATE POLICY "All users can view permissions"
ON module_permissions FOR SELECT
TO authenticated
USING (true);

-- Only admins can manage permissions
CREATE POLICY "Admins can manage permissions"
ON module_permissions FOR ALL
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- ============================================================================
-- DEPARTMENTS TABLE POLICIES
-- ============================================================================

-- All authenticated users can view departments
CREATE POLICY "All users can view departments"
ON departments FOR SELECT
TO authenticated
USING (true);

-- Admins, managers, and HR can create departments
CREATE POLICY "Authorized users can create departments"
ON departments FOR INSERT
TO authenticated
WITH CHECK (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'hr']::app_role[]));

-- Admins, managers, and HR can update departments
CREATE POLICY "Authorized users can update departments"
ON departments FOR UPDATE
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'hr']::app_role[]));

-- Only admins can delete departments
CREATE POLICY "Admins can delete departments"
ON departments FOR DELETE
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- ============================================================================
-- ACCOUNTS TABLE POLICIES
-- ============================================================================

-- All authenticated users can view accounts
CREATE POLICY "All users can view accounts"
ON accounts FOR SELECT
TO authenticated
USING (true);

-- Admins, managers, and accountants can create accounts
CREATE POLICY "Authorized users can create accounts"
ON accounts FOR INSERT
TO authenticated
WITH CHECK (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'accountant']::app_role[]));

-- Admins, managers, and accountants can update accounts
CREATE POLICY "Authorized users can update accounts"
ON accounts FOR UPDATE
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'accountant']::app_role[]));

-- Only admins can delete accounts
CREATE POLICY "Admins can delete accounts"
ON accounts FOR DELETE
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- ============================================================================
-- CUSTOMERS TABLE POLICIES
-- ============================================================================

-- Sales, accountants, managers, and admins can view customers
CREATE POLICY "Authorized users can view customers"
ON customers FOR SELECT
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'accountant', 'sales']::app_role[]));

-- Sales, managers, and admins can create customers
CREATE POLICY "Authorized users can create customers"
ON customers FOR INSERT
TO authenticated
WITH CHECK (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'sales']::app_role[]));

-- Sales, managers, and admins can update customers
CREATE POLICY "Authorized users can update customers"
ON customers FOR UPDATE
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'sales']::app_role[]));

-- Only admins can delete customers
CREATE POLICY "Admins can delete customers"
ON customers FOR DELETE
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- ============================================================================
-- VENDORS TABLE POLICIES
-- ============================================================================

-- Inventory, accountants, managers, and admins can view vendors
CREATE POLICY "Authorized users can view vendors"
ON vendors FOR SELECT
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'accountant', 'inventory']::app_role[]));

-- Inventory, managers, and admins can create vendors
CREATE POLICY "Authorized users can create vendors"
ON vendors FOR INSERT
TO authenticated
WITH CHECK (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'inventory']::app_role[]));

-- Inventory, managers, and admins can update vendors
CREATE POLICY "Authorized users can update vendors"
ON vendors FOR UPDATE
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'inventory']::app_role[]));

-- Only admins can delete vendors
CREATE POLICY "Admins can delete vendors"
ON vendors FOR DELETE
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- ============================================================================
-- PRODUCTS TABLE POLICIES
-- ============================================================================

-- All authenticated users can view active products
CREATE POLICY "All users can view products"
ON products FOR SELECT
TO authenticated
USING (true);

-- Inventory, sales, managers, and admins can create products
CREATE POLICY "Authorized users can create products"
ON products FOR INSERT
TO authenticated
WITH CHECK (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'inventory', 'sales']::app_role[]));

-- Inventory, sales, managers, and admins can update products
CREATE POLICY "Authorized users can update products"
ON products FOR UPDATE
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'inventory', 'sales']::app_role[]));

-- Only admins can delete products
CREATE POLICY "Admins can delete products"
ON products FOR DELETE
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- ============================================================================
-- STOCK MOVEMENTS TABLE POLICIES
-- ============================================================================

-- Inventory, managers, and admins can view stock movements
CREATE POLICY "Authorized users can view stock movements"
ON stock_movements FOR SELECT
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'inventory']::app_role[]));

-- Inventory, managers, and admins can create stock movements
CREATE POLICY "Authorized users can create stock movements"
ON stock_movements FOR INSERT
TO authenticated
WITH CHECK (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'inventory']::app_role[]));

-- ============================================================================
-- TRANSACTIONS TABLE POLICIES
-- ============================================================================

-- Accountants, managers, and admins can view transactions
CREATE POLICY "Authorized users can view transactions"
ON transactions FOR SELECT
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'accountant']::app_role[]));

-- Accountants, managers, and admins can create transactions
CREATE POLICY "Authorized users can create transactions"
ON transactions FOR INSERT
TO authenticated
WITH CHECK (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'accountant']::app_role[]));

-- Accountants, managers, and admins can update transactions
CREATE POLICY "Authorized users can update transactions"
ON transactions FOR UPDATE
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'accountant']::app_role[]));

-- Only admins can delete transactions
CREATE POLICY "Admins can delete transactions"
ON transactions FOR DELETE
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- ============================================================================
-- SALES ORDERS TABLE POLICIES
-- ============================================================================

-- Sales, accountants, managers, and admins can view sales
CREATE POLICY "Authorized users can view sales"
ON sales_orders FOR SELECT
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'accountant', 'sales']::app_role[]));

-- Sales, managers, and admins can create sales
CREATE POLICY "Authorized users can create sales"
ON sales_orders FOR INSERT
TO authenticated
WITH CHECK (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'sales']::app_role[]));

-- Sales, managers, and admins can update sales
CREATE POLICY "Authorized users can update sales"
ON sales_orders FOR UPDATE
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'sales']::app_role[]));

-- Only admins can delete sales
CREATE POLICY "Admins can delete sales"
ON sales_orders FOR DELETE
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- ============================================================================
-- SALES LINE ITEMS TABLE POLICIES
-- ============================================================================

-- Inherit policies from parent sales order
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

-- Inventory, accountants, managers, and admins can view purchases
CREATE POLICY "Authorized users can view purchases"
ON purchase_orders FOR SELECT
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'accountant', 'inventory']::app_role[]));

-- Inventory, managers, and admins can create purchases
CREATE POLICY "Authorized users can create purchases"
ON purchase_orders FOR INSERT
TO authenticated
WITH CHECK (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'inventory']::app_role[]));

-- Inventory, managers, and admins can update purchases
CREATE POLICY "Authorized users can update purchases"
ON purchase_orders FOR UPDATE
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'inventory']::app_role[]));

-- Only admins can delete purchases
CREATE POLICY "Admins can delete purchases"
ON purchase_orders FOR DELETE
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- ============================================================================
-- PURCHASE LINE ITEMS TABLE POLICIES
-- ============================================================================

-- Inherit policies from parent purchase order
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

-- HR, managers, and admins can view employees
CREATE POLICY "Authorized users can view employees"
ON employees FOR SELECT
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'hr']::app_role[]));

-- HR, managers, and admins can create employees
CREATE POLICY "Authorized users can create employees"
ON employees FOR INSERT
TO authenticated
WITH CHECK (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'hr']::app_role[]));

-- HR, managers, and admins can update employees
CREATE POLICY "Authorized users can update employees"
ON employees FOR UPDATE
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'hr']::app_role[]));

-- Only admins can delete employees
CREATE POLICY "Admins can delete employees"
ON employees FOR DELETE
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- ============================================================================
-- PAYROLL TABLE POLICIES
-- ============================================================================

-- HR, accountants, managers, and admins can view payroll
CREATE POLICY "Authorized users can view payroll"
ON payroll FOR SELECT
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'hr', 'accountant']::app_role[]));

-- HR, managers, and admins can create payroll
CREATE POLICY "Authorized users can create payroll"
ON payroll FOR INSERT
TO authenticated
WITH CHECK (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'hr']::app_role[]));

-- HR, managers, and admins can update payroll
CREATE POLICY "Authorized users can update payroll"
ON payroll FOR UPDATE
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'hr']::app_role[]));

-- Only admins can delete payroll
CREATE POLICY "Admins can delete payroll"
ON payroll FOR DELETE
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- ============================================================================
-- ACTIVITY LOGS TABLE POLICIES
-- ============================================================================

-- Users can view their own activity
CREATE POLICY "Users can view own activity"
ON activity_logs FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- Admins and managers can view all activity
CREATE POLICY "Admins and managers can view all activity"
ON activity_logs FOR SELECT
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager']::app_role[]));

-- All authenticated users can insert activity logs
CREATE POLICY "All users can create activity logs"
ON activity_logs FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

-- Only admins can delete activity logs
CREATE POLICY "Admins can delete activity logs"
ON activity_logs FOR DELETE
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- ============================================================================
-- PRODUCT CATEGORIES TABLE POLICIES
-- ============================================================================

-- All authenticated users can view categories
CREATE POLICY "All users can view categories"
ON product_categories FOR SELECT
TO authenticated
USING (true);

-- Inventory, managers, and admins can manage categories
CREATE POLICY "Authorized users can manage categories"
ON product_categories FOR ALL
TO authenticated
USING (public.has_any_role(auth.uid(), ARRAY['admin', 'manager', 'inventory']::app_role[]));
