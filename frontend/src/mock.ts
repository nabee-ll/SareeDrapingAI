import type { ApiKey, CreditBundle, SareeItem, TryOnResult } from './types';

export const sarees: SareeItem[] = [
  {
    id: 's1',
    name: 'Kanjivaram Silk Elegance',
    fabric: 'Silk',
    region: 'Tamil Nadu',
    price: 12500,
    imageUrl: 'https://images.unsplash.com/photo-1610030469668-8f39f9b0f83f?auto=format&fit=crop&w=900&q=80',
    description: 'A rich burgundy and gold weave with temple border motifs for festive draping.',
  },
  {
    id: 's2',
    name: 'Banarasi Heritage Weave',
    fabric: 'Silk',
    region: 'Uttar Pradesh',
    price: 9800,
    imageUrl: 'https://images.unsplash.com/photo-1611078489935-0cb964de46d6?auto=format&fit=crop&w=900&q=80',
    description: 'Classic zari pallu and subtle floral motifs for occasion wear.',
  },
  {
    id: 's3',
    name: 'Chettinad Cotton Breeze',
    fabric: 'Cotton',
    region: 'Tamil Nadu',
    price: 4200,
    imageUrl: 'https://images.unsplash.com/photo-1617713964959-d9a36bbc7b52?auto=format&fit=crop&w=900&q=80',
    description: 'Breathable cotton texture designed for all-day comfort and bright contrast borders.',
  },
  {
    id: 's4',
    name: 'Bandhani Radiance',
    fabric: 'Georgette',
    region: 'Gujarat',
    price: 6100,
    imageUrl: 'https://images.unsplash.com/photo-1583391733956-6c77a9d9329b?auto=format&fit=crop&w=900&q=80',
    description: 'Fine tie-dye patterns with light drape and festive movement.',
  },
  {
    id: 's5',
    name: 'Paithani Regal Glow',
    fabric: 'Silk',
    region: 'Maharashtra',
    price: 18900,
    imageUrl: 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?auto=format&fit=crop&w=900&q=80',
    description: 'Peacock-inspired pallu and jewel-toned body for premium styling.',
  },
  {
    id: 's6',
    name: 'Sambalpuri Ikat Story',
    fabric: 'Silk',
    region: 'Odisha',
    price: 11200,
    imageUrl: 'https://images.unsplash.com/photo-1617254481478-4cb1d567d95d?auto=format&fit=crop&w=900&q=80',
    description: 'Traditional ikat narrative motifs with modern color blocking.',
  },
];

export const galleryItems: TryOnResult[] = [
  {
    id: 'g1',
    sareeId: 's1',
    sareeName: 'Kanjivaram Silk Elegance',
    imageUrl: 'https://images.unsplash.com/photo-1596704017254-9d1399c9f499?auto=format&fit=crop&w=700&q=80',
    createdAt: '2026-03-10',
  },
  {
    id: 'g2',
    sareeId: 's3',
    sareeName: 'Chettinad Cotton Breeze',
    imageUrl: 'https://images.unsplash.com/photo-1609758737610-3f164b8d97df?auto=format&fit=crop&w=700&q=80',
    createdAt: '2026-03-09',
  },
  {
    id: 'g3',
    sareeId: 's6',
    sareeName: 'Sambalpuri Ikat Story',
    imageUrl: 'https://images.unsplash.com/photo-1610030473255-e88f9c4b8b14?auto=format&fit=crop&w=700&q=80',
    createdAt: '2026-03-07',
  },
];

export const bundles: CreditBundle[] = [
  { id: 'b1', credits: 20, price: 499, label: 'Starter' },
  { id: 'b2', credits: 60, price: 1299, label: 'Creator' },
  { id: 'b3', credits: 150, price: 2799, label: 'Studio' },
];

export const apiKeys: ApiKey[] = [
  {
    id: 'k1',
    name: 'Production Key',
    value: 'sdai_live_x9Qw2M7a1',
    createdAt: '2026-03-01',
    status: 'active',
  },
  {
    id: 'k2',
    name: 'Staging Key',
    value: 'sdai_test_M4kP8r2b9',
    createdAt: '2026-02-21',
    status: 'active',
  },
];
