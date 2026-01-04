import React, { useState } from "react";
import { useForm, Controller } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { AlertCircle, Loader2 } from "lucide-react";

// shadcn/ui imports
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Badge } from "@/components/ui/badge";
import { Separator } from "@/components/ui/separator";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

// ============================================
// ZOD SCHEMAS
// ============================================

const luhnCheck = (cardNumber: string): boolean => {
  const cleaned = cardNumber.replace(/\s/g, "");
  if (!/^[0-9]{13,19}$/.test(cleaned)) return false;
  let sum = 0;
  let isEven = false;
  for (let i = cleaned.length - 1; i >= 0; i--) {
    let digit = parseInt(cleaned[i], 10);
    if (isEven) {
      digit *= 2;
      if (digit > 9) digit -= 9;
    }
    sum += digit;
    isEven = !isEven;
  }
  return sum % 10 === 0;
};

const expiryCheck = (expiry: string): boolean => {
  const regex = /^(0[1-9]|1[0-2])\/([0-9]{2})$/;
  if (!regex.test(expiry)) return false;
  const [month, year] = expiry.split("/");
  const expDate = new Date(2000 + parseInt(year), parseInt(month) - 1);
  return expDate >= new Date();
};

const checkoutFormSchema = z
  .object({
    account: z
      .object({
        email: z.string().min(1, "Email is required").email("Invalid email"),
        password: z
          .string()
          .min(1, "Password is required")
          .min(8, "Min 8 characters")
          .regex(/[A-Z]/, "Need uppercase")
          .regex(/[0-9]/, "Need number"),
        confirmPassword: z.string().min(1, "Please confirm"),
        contact: z.object({
          phone: z
            .string()
            .min(1, "Phone required")
            .regex(/^\+[0-9]{10,14}$/, "Invalid phone"),
        }),
      })
      .refine((data) => data.password === data.confirmPassword, {
        message: "Passwords must match",
        path: ["confirmPassword"],
      }),
    payment: z.object({
      method: z.string().min(1, "Select method"),
      expiry: z
        .string()
        .min(1, "Required")
        .regex(/^(0[1-9]|1[0-2])\/([0-9]{2})$/, "MM/YY")
        .refine(expiryCheck, "Expired"),
      cvv: z
        .string()
        .min(1, "Required")
        .regex(/^[0-9]{3,4}$/, "3-4 digits"),
      billingAddress: z.string().min(1, "Required"),
      cardNumber: z
        .string()
        .min(1, "Required")
        .refine(luhnCheck, "Invalid card"),
    }),
    shippingDetails: z.object({
      shippingSameAsBilling: z.boolean(),
    }),
    shipping: z.object({
      address: z.string(),
      country: z.string(),
      state: z.string(),
      city: z.string(),
      postalCode: z.string(),
    }),
  })
  .superRefine((data, ctx) => {
    if (!data.shippingDetails.shippingSameAsBilling) {
      const fields = [
        "address",
        "country",
        "state",
        "city",
        "postalCode",
      ] as const;
      fields.forEach((field) => {
        if (!data.shipping[field]) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: "Required",
            path: ["shipping", field],
          });
        }
      });
    }
  });

type CheckoutFormData = z.infer<typeof checkoutFormSchema>;

// ============================================
// HELPER COMPONENTS
// ============================================

const FormField = ({
  label,
  error,
  children,
}: {
  label: string;
  error?: string;
  children: React.ReactNode;
}) => (
  <div className="space-y-2">
    <Label className={error ? "text-destructive" : ""}>{label}</Label>
    {children}
    {error && (
      <p className="text-sm text-destructive flex items-center gap-1">
        <AlertCircle className="h-3 w-3" />
        {error}
      </p>
    )}
  </div>
);

// ============================================
// MAIN COMPONENT
// ============================================

export default function CheckoutForm() {
  const [isSubmitting, setIsSubmitting] = useState(false);

  const {
    register,
    handleSubmit,
    control,
    formState: { errors, isSubmitted },
    watch,
    setValue,
  } = useForm<CheckoutFormData>({
    resolver: zodResolver(checkoutFormSchema),
    mode: "onBlur",
    defaultValues: {
      account: {
        email: "vicrokx@gmail.com",
        password: "",
        confirmPassword: "",
        contact: { phone: "+31683214074" },
      },
      payment: {
        method: "",
        expiry: "",
        cvv: "123",
        billingAddress: "",
        cardNumber: "9999 9999 9999 9999",
      },
      shippingDetails: { shippingSameAsBilling: false },
      shipping: {
        address: "",
        country: "",
        state: "",
        city: "",
        postalCode: "",
      },
    },
  });

  const shippingSameAsBilling = watch("shippingDetails.shippingSameAsBilling");

  const onSubmit = async (data: CheckoutFormData) => {
    setIsSubmitting(true);
    await new Promise((r) => setTimeout(r, 2000));
    setIsSubmitting(false);
    alert("Order submitted!");
  };

  const getError = (path: string) => {
    return path.split(".").reduce((obj: any, key) => obj?.[key], errors)
      ?.message as string | undefined;
  };

  const formatCard = (v: string) =>
    v
      .replace(/\D/g, "")
      .replace(/(.{4})/g, "$1 ")
      .trim()
      .slice(0, 19);
  const formatExpiry = (v: string) => {
    const d = v.replace(/\D/g, "");
    return d.length >= 2 ? d.slice(0, 2) + "/" + d.slice(2, 4) : d;
  };

  return (
    <div className="min-h-screen bg-gray-50 p-6">
      <div className="max-w-lg mx-auto space-y-6">
        {/* Tech badges */}
        <div className="flex flex-wrap gap-2 justify-center">
          <Badge variant="secondary">React Hook Form</Badge>
          <Badge variant="secondary">Zod</Badge>
          <Badge variant="secondary">shadcn/ui</Badge>
          <Badge variant="secondary">TypeScript</Badge>
        </div>

        <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
          {/* Error alert */}
          {isSubmitted && Object.keys(errors).length > 0 && (
            <Alert variant="destructive">
              <AlertCircle className="h-4 w-4" />
              <AlertDescription>Please fix the errors below.</AlertDescription>
            </Alert>
          )}

          {/* Account */}
          <Card>
            <CardHeader>
              <CardTitle>Account</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <FormField label="Email" error={getError("account.email")}>
                  <Input type="email" {...register("account.email")} />
                </FormField>
                <FormField
                  label="Password"
                  error={getError("account.password")}
                >
                  <Input type="password" {...register("account.password")} />
                </FormField>
              </div>
              <FormField
                label="Confirm password"
                error={getError("account.confirmPassword")}
              >
                <Input
                  type="password"
                  {...register("account.confirmPassword")}
                />
              </FormField>

              <Separator />
              <p className="text-xs text-muted-foreground uppercase tracking-wide">
                Contact
              </p>
              <FormField
                label="Phone"
                error={getError("account.contact.phone")}
              >
                <Input type="tel" {...register("account.contact.phone")} />
              </FormField>
            </CardContent>
          </Card>

          {/* Payment */}
          <Card>
            <CardHeader>
              <CardTitle>Payment</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <FormField
                label="Payment Method"
                error={getError("payment.method")}
              >
                <Controller
                  name="payment.method"
                  control={control}
                  render={({ field }) => (
                    <Select onValueChange={field.onChange} value={field.value}>
                      <SelectTrigger>
                        <SelectValue placeholder="Select method" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="card">Credit/Debit Card</SelectItem>
                        <SelectItem value="paypal">PayPal</SelectItem>
                      </SelectContent>
                    </Select>
                  )}
                />
              </FormField>

              <div className="grid grid-cols-3 gap-3">
                <FormField label="Expiry" error={getError("payment.expiry")}>
                  <Input
                    placeholder="MM/YY"
                    {...register("payment.expiry")}
                    onChange={(e) =>
                      setValue("payment.expiry", formatExpiry(e.target.value))
                    }
                  />
                </FormField>
                <FormField label="CVV" error={getError("payment.cvv")}>
                  <Input
                    {...register("payment.cvv")}
                    onChange={(e) =>
                      setValue(
                        "payment.cvv",
                        e.target.value.replace(/\D/g, "").slice(0, 4),
                      )
                    }
                  />
                </FormField>
                <FormField
                  label="Billing address"
                  error={getError("payment.billingAddress")}
                >
                  <Input {...register("payment.billingAddress")} />
                </FormField>
              </div>

              <FormField
                label="Card number"
                error={getError("payment.cardNumber")}
              >
                <Input
                  {...register("payment.cardNumber")}
                  onChange={(e) =>
                    setValue("payment.cardNumber", formatCard(e.target.value))
                  }
                />
              </FormField>
            </CardContent>
          </Card>

          {/* Shipping */}
          <Card>
            <CardHeader>
              <CardTitle>Shipping details</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center justify-between">
                <Label>Shipping same as billing</Label>
                <Controller
                  name="shippingDetails.shippingSameAsBilling"
                  control={control}
                  render={({ field }) => (
                    <Switch
                      checked={field.value}
                      onCheckedChange={field.onChange}
                    />
                  )}
                />
              </div>

              {!shippingSameAsBilling && (
                <>
                  <Separator />
                  <p className="text-xs text-muted-foreground uppercase tracking-wide">
                    Shipping Address
                  </p>

                  <FormField
                    label="Address"
                    error={getError("shipping.address")}
                  >
                    <Input {...register("shipping.address")} />
                  </FormField>

                  <FormField
                    label="Country"
                    error={getError("shipping.country")}
                  >
                    <Controller
                      name="shipping.country"
                      control={control}
                      render={({ field }) => (
                        <Select
                          onValueChange={field.onChange}
                          value={field.value}
                        >
                          <SelectTrigger>
                            <SelectValue placeholder="Select country" />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectItem value="US">United States</SelectItem>
                            <SelectItem value="CA">Canada</SelectItem>
                            <SelectItem value="UK">United Kingdom</SelectItem>
                          </SelectContent>
                        </Select>
                      )}
                    />
                  </FormField>

                  <div className="grid grid-cols-2 gap-4">
                    <FormField label="State" error={getError("shipping.state")}>
                      <Input {...register("shipping.state")} />
                    </FormField>
                    <FormField label="City" error={getError("shipping.city")}>
                      <Input {...register("shipping.city")} />
                    </FormField>
                  </div>

                  <FormField
                    label="Postal code"
                    error={getError("shipping.postalCode")}
                  >
                    <Input {...register("shipping.postalCode")} />
                  </FormField>
                </>
              )}
            </CardContent>
          </Card>

          {/* Submit */}
          <Button
            type="submit"
            className="w-full"
            size="lg"
            disabled={isSubmitting}
          >
            {isSubmitting && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
            {isSubmitting ? "Processing..." : "Submit"}
          </Button>
        </form>
      </div>
    </div>
  );
}
