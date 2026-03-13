export type SareeItem = {
  id: string;
  name: string;
  fabric: string;
  region: string;
  price: number;
  imageUrl: string;
  description: string;
};

export type TryOnResult = {
  id: string;
  sareeId: string;
  sareeName: string;
  imageUrl: string;
  createdAt: string;
};

export type CreditBundle = {
  id: string;
  credits: number;
  price: number;
  label: string;
};

export type ApiKey = {
  id: string;
  name: string;
  value: string;
  createdAt: string;
  status: "active" | "revoked";
};
