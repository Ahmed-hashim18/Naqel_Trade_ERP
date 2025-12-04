import { useState } from "react";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { Employee } from "@/types/employee";
import { Department } from "@/types/department";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Plus } from "lucide-react";
import { toast } from "sonner";

interface EmployeeFormDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  employee: Employee | null;
  onSave: (employee: Partial<Employee>) => void;
  departments: Department[];
  onCreateDepartment?: (dept: Partial<Department>) => Promise<any>;
}

export function EmployeeFormDialog({
  open,
  onOpenChange,
  employee,
  onSave,
  departments,
  onCreateDepartment,
}: EmployeeFormDialogProps) {
  const [showNewDept, setShowNewDept] = useState(false);
  const [newDeptName, setNewDeptName] = useState("");
  const [newDeptCode, setNewDeptCode] = useState("");
  const [selectedDeptId, setSelectedDeptId] = useState(employee?.departmentId || "");

  const handleDepartmentChange = (value: string) => {
    if (value === "__create_new__") {
      setShowNewDept(true);
    } else {
      setSelectedDeptId(value);
    }
  };

  const handleCreateDepartment = async () => {
    if (!newDeptName.trim() || !newDeptCode.trim()) {
      toast.error("Department name and code are required");
      return;
    }

    if (onCreateDepartment) {
      try {
        const newDept = await onCreateDepartment({
          name: newDeptName.trim(),
          code: newDeptCode.trim().toUpperCase(),
        });
        setSelectedDeptId(newDept.id);
        setShowNewDept(false);
        setNewDeptName("");
        setNewDeptCode("");
      } catch (error) {
        // Error handled in hook
      }
    }
  };

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);
    const data: Partial<Employee> = {
      firstName: formData.get("firstName") as string,
      lastName: formData.get("lastName") as string,
      email: formData.get("email") as string,
      phone: formData.get("phone") as string,
      dateOfBirth: formData.get("dateOfBirth") as string,
      gender: formData.get("gender") as any,
      address: formData.get("address") as string,
      city: formData.get("city") as string,
      state: formData.get("state") as string,
      zipCode: formData.get("zipCode") as string,
      country: formData.get("country") as string,
      departmentId: selectedDeptId,
      position: formData.get("position") as string,
      employmentType: formData.get("employmentType") as any,
      employmentStatus: formData.get("employmentStatus") as any,
      hireDate: formData.get("hireDate") as string,
      baseSalary: Number(formData.get("baseSalary")),
      currency: formData.get("currency") as string,
      paymentFrequency: formData.get("paymentFrequency") as any,
      notes: formData.get("notes") as string,
    };
    onSave(data);
    onOpenChange(false);
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-3xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>{employee ? "Edit Employee" : "Add New Employee"}</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit}>
          <Tabs defaultValue="personal" className="w-full">
            <TabsList className="grid w-full grid-cols-3">
              <TabsTrigger value="personal">Personal</TabsTrigger>
              <TabsTrigger value="employment">Employment</TabsTrigger>
              <TabsTrigger value="compensation">Compensation</TabsTrigger>
            </TabsList>
            
            <TabsContent value="personal" className="space-y-4 mt-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="firstName">First Name *</Label>
                  <Input id="firstName" name="firstName" defaultValue={employee?.firstName} required />
                </div>
                <div>
                  <Label htmlFor="lastName">Last Name *</Label>
                  <Input id="lastName" name="lastName" defaultValue={employee?.lastName} required />
                </div>
              </div>
              
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="email">Email *</Label>
                  <Input id="email" name="email" type="email" defaultValue={employee?.email} required />
                </div>
                <div>
                  <Label htmlFor="phone">Phone *</Label>
                  <Input id="phone" name="phone" defaultValue={employee?.phone} required />
                </div>
              </div>
              
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="dateOfBirth">Date of Birth *</Label>
                  <Input id="dateOfBirth" name="dateOfBirth" type="date" defaultValue={employee?.dateOfBirth} required />
                </div>
                <div>
                  <Label htmlFor="gender">Gender *</Label>
                  <Select name="gender" defaultValue={employee?.gender || "prefer_not_to_say"}>
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="male">Male</SelectItem>
                      <SelectItem value="female">Female</SelectItem>
                      <SelectItem value="other">Other</SelectItem>
                      <SelectItem value="prefer_not_to_say">Prefer not to say</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>
              
              <div>
                <Label htmlFor="address">Address *</Label>
                <Input id="address" name="address" defaultValue={employee?.address} required />
              </div>
              
              <div className="grid grid-cols-3 gap-4">
                <div>
                  <Label htmlFor="city">City *</Label>
                  <Input id="city" name="city" defaultValue={employee?.city} required />
                </div>
                <div>
                  <Label htmlFor="state">State *</Label>
                  <Input id="state" name="state" defaultValue={employee?.state} required />
                </div>
                <div>
                  <Label htmlFor="zipCode">Zip Code *</Label>
                  <Input id="zipCode" name="zipCode" defaultValue={employee?.zipCode} required />
                </div>
              </div>
              
              <div>
                <Label htmlFor="country">Country *</Label>
                <Input id="country" name="country" defaultValue={employee?.country || "Mauritania"} required />
              </div>
            </TabsContent>
            
            <TabsContent value="employment" className="space-y-4 mt-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="departmentId">Department *</Label>
                  {!showNewDept ? (
                    <Select 
                      name="departmentId" 
                      value={selectedDeptId}
                      onValueChange={handleDepartmentChange}
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Select department" />
                      </SelectTrigger>
                      <SelectContent>
                        {onCreateDepartment && (
                          <SelectItem value="__create_new__" className="text-primary font-medium">
                            <span className="flex items-center gap-1">
                              <Plus className="h-4 w-4" />
                              Create new department
                            </span>
                          </SelectItem>
                        )}
                        {departments.map((dept) => (
                          <SelectItem key={dept.id} value={dept.id}>
                            {dept.name}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  ) : (
                    <div className="space-y-2 p-3 border rounded-lg bg-muted/50">
                      <div className="text-sm font-medium">New Department</div>
                      <Input
                        placeholder="Department name *"
                        value={newDeptName}
                        onChange={(e) => setNewDeptName(e.target.value)}
                      />
                      <Input
                        placeholder="Department code *"
                        value={newDeptCode}
                        onChange={(e) => setNewDeptCode(e.target.value)}
                      />
                      <div className="flex gap-2">
                        <Button type="button" size="sm" onClick={handleCreateDepartment}>
                          Create
                        </Button>
                        <Button type="button" size="sm" variant="outline" onClick={() => setShowNewDept(false)}>
                          Cancel
                        </Button>
                      </div>
                    </div>
                  )}
                </div>
                <div>
                  <Label htmlFor="position">Position *</Label>
                  <Input id="position" name="position" defaultValue={employee?.position} required />
                </div>
              </div>
              
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="employmentType">Employment Type *</Label>
                  <Select name="employmentType" defaultValue={employee?.employmentType || "full_time"}>
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="full_time">Full Time</SelectItem>
                      <SelectItem value="part_time">Part Time</SelectItem>
                      <SelectItem value="contract">Contract</SelectItem>
                      <SelectItem value="intern">Intern</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div>
                  <Label htmlFor="employmentStatus">Status *</Label>
                  <Select name="employmentStatus" defaultValue={employee?.employmentStatus || "active"}>
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="active">Active</SelectItem>
                      <SelectItem value="on_leave">On Leave</SelectItem>
                      <SelectItem value="probation">Probation</SelectItem>
                      <SelectItem value="terminated">Terminated</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>
              
              <div>
                <Label htmlFor="hireDate">Hire Date *</Label>
                <Input id="hireDate" name="hireDate" type="date" defaultValue={employee?.hireDate} required />
              </div>
              
              <div>
                <Label htmlFor="notes">Notes</Label>
                <Textarea id="notes" name="notes" defaultValue={employee?.notes} rows={3} />
              </div>
            </TabsContent>
            
            <TabsContent value="compensation" className="space-y-4 mt-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="baseSalary">Base Salary *</Label>
                  <Input id="baseSalary" name="baseSalary" type="number" step="0.01" defaultValue={employee?.baseSalary} required />
                </div>
                <div>
                  <Label htmlFor="currency">Currency *</Label>
                  <Select name="currency" defaultValue={employee?.currency || "MRU"}>
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="MRU">MRU</SelectItem>
                      <SelectItem value="USD">USD</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>
              
              <div>
                <Label htmlFor="paymentFrequency">Payment Frequency *</Label>
                <Select name="paymentFrequency" defaultValue={employee?.paymentFrequency || "monthly"}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="weekly">Weekly</SelectItem>
                    <SelectItem value="bi-weekly">Bi-Weekly</SelectItem>
                    <SelectItem value="monthly">Monthly</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </TabsContent>
          </Tabs>
          
          <div className="flex justify-end gap-3 mt-6">
            <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
              Cancel
            </Button>
            <Button type="submit">
              {employee ? "Update" : "Create"} Employee
            </Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
}
