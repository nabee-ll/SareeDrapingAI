import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import {
  BrowserRouter,
  Link,
  Navigate,
  Outlet,
  Route,
  Routes,
  useLocation,
  useNavigate,
  NavLink,
} from 'react-router-dom';
import { useGoogleLogin } from '@react-oauth/google';
import { apiKeys as seedApiKeys, bundles, galleryItems, sarees } from './mock';
import type { ApiKey, TryOnResult } from './types';
import frontViewImage from './assets/Front View.png';
import sideViewImage from './assets/Side View.png';
import backViewImage from './assets/Back View.png';
import palluViewImage from './assets/Pallu View.png';
import loginPageImage from './assets/Login_page.png';
import googleLogoImage from './assets/google-logo.jpg';
import heroResultImage from './assets/element on web.png';
import './styles/theme.css';
import './styles/ui.css';

const AUTH_USER_STORAGE_KEY = 'sdai_auth_user';
const AUTH_USER_UPDATED_EVENT = 'sdai-auth-user-updated';

function loadStoredAuthUser(): { name: string; email: string } | null {
  try {
    const raw = localStorage.getItem(AUTH_USER_STORAGE_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw) as { name?: string; email?: string };
    if (!parsed.email) return null;
    return {
      name: parsed.name?.trim() || deriveNameFromEmail(parsed.email),
      email: parsed.email.trim(),
    };
  } catch {
    return null;
  }
}

function saveStoredAuthUser(user: { name: string; email: string }) {
  localStorage.setItem(AUTH_USER_STORAGE_KEY, JSON.stringify(user));
  window.dispatchEvent(new Event(AUTH_USER_UPDATED_EVENT));
}

function clearStoredAuthUser() {
  localStorage.removeItem(AUTH_USER_STORAGE_KEY);
  window.dispatchEvent(new Event(AUTH_USER_UPDATED_EVENT));
}

function deriveNameFromEmail(email: string) {
  const local = email.split('@')[0] || 'User';
  return local
    .split(/[._-]+/)
    .filter(Boolean)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(' ');
}

type GoogleUserInfo = { name?: string; email?: string };

/* ─── helpers ─── */
function scrollTo(id: string) {
  document.getElementById(id)?.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

/* ─── Scroll Reveal Hook ─── */
function useScrollReveal() {
  useEffect(() => {
    const els = document.querySelectorAll('.reveal, .reveal-left, .reveal-right, .reveal-scale');
    const obs = new IntersectionObserver(
      (entries) => entries.forEach((e) => { if (e.isIntersecting) { e.target.classList.add('visible'); obs.unobserve(e.target); } }),
      { rootMargin: '0px 0px -60px 0px', threshold: 0.15 }
    );
    els.forEach((el) => obs.observe(el));
    return () => obs.disconnect();
  });
}

/* ─── Animated Counter Hook ─── */
function useAnimatedCounter(end: number, duration = 1500) {
  const [count, setCount] = useState(0);
  const ref = useRef<HTMLSpanElement>(null);
  const triggered = useRef(false);

  useEffect(() => {
    if (!ref.current) return;
    const obs = new IntersectionObserver(([entry]) => {
      if (entry.isIntersecting && !triggered.current) {
        triggered.current = true;
        const start = performance.now();
        const animate = (now: number) => {
          const progress = Math.min((now - start) / duration, 1);
          const eased = 1 - Math.pow(1 - progress, 3);
          setCount(Math.round(eased * end));
          if (progress < 1) requestAnimationFrame(animate);
        };
        requestAnimationFrame(animate);
      }
    }, { threshold: 0.5 });
    obs.observe(ref.current);
    return () => obs.disconnect();
  }, [end, duration]);

  return { count, ref };
}

/* ─── Scroll Progress ─── */
function useScrollProgress() {
  const [progress, setProgress] = useState(0);
  const [showTop, setShowTop] = useState(false);
  useEffect(() => {
    const onScroll = () => {
      const h = document.documentElement.scrollHeight - window.innerHeight;
      setProgress(h > 0 ? (window.scrollY / h) * 100 : 0);
      setShowTop(window.scrollY > 400);
    };
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, []);
  return { progress, showTop };
}

/* ─── Toast System ─── */
function useToast() {
  const [toasts, setToasts] = useState<{ id: number; msg: string; type?: string }[]>([]);
  const show = useCallback((msg: string, type = 'success') => {
    const id = Date.now();
    setToasts((t) => [...t, { id, msg, type }]);
    setTimeout(() => setToasts((t) => t.filter((x) => x.id !== id)), 3000);
  }, []);
  const ToastContainer = () =>
    toasts.length > 0 ? (
      <div className="toast-container">
        {toasts.map((t) => (<div key={t.id} className={`toast ${t.type}`}>{t.msg}</div>))}
      </div>
    ) : null;
  return { show, ToastContainer };
}

function ScrollProgressBar({ progress }: { progress: number }) {
  return <div className="scroll-progress" style={{ width: `${progress}%` }} />;
}

/* ═══════════════════════════════════════════════════
   APP — routes kept only for portal + auth
   ═══════════════════════════════════════════════════ */
function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<SinglePageApp />} />
        <Route path="/signup" element={<AuthPage initialMode="signup" />} />
        <Route path="/login" element={<AuthPage initialMode="login" />} />
        <Route path="/error" element={<ErrorFallbackPage />} />
        <Route path="/dashboard" element={<Navigate to="/portal/dashboard" replace />} />

        <Route path="/portal" element={<PortalLayout />}>
          <Route index element={<Navigate to="/portal/dashboard" replace />} />
          <Route path="login" element={<PortalLoginPage />} />
          <Route path="register" element={<PortalRegisterPage />} />
          <Route path="dashboard" element={<PortalDashboardPage />} />
          <Route path="api-keys" element={<PortalApiKeysPage />} />
          <Route path="webhooks" element={<PortalWebhooksPage />} />
          <Route path="billing" element={<PortalBillingPage />} />
          <Route path="docs" element={<PortalDocsPage />} />
        </Route>

        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  );
}

/* ═══════════════════════════════════════════════════
   SINGLE PAGE APP — everything on one screen
   ═══════════════════════════════════════════════════ */
function SinglePageApp() {
  const [authUser, setAuthUser] = useState<{ name: string; email: string } | null>(() => loadStoredAuthUser());
  const [activeSection, setActiveSection] = useState('hero');
  const [footerLanguage, setFooterLanguage] = useState('English');
  const { progress, showTop } = useScrollProgress();
  const { show: showToast, ToastContainer } = useToast();
  useScrollReveal();

  useEffect(() => {
    const syncAuthUser = () => setAuthUser(loadStoredAuthUser());
    window.addEventListener(AUTH_USER_UPDATED_EVENT, syncAuthUser);
    window.addEventListener('storage', syncAuthUser);
    return () => {
      window.removeEventListener(AUTH_USER_UPDATED_EVENT, syncAuthUser);
      window.removeEventListener('storage', syncAuthUser);
    };
  }, []);

  useEffect(() => {
    const sectionIds = ['hero', 'tryon', 'catalogue', 'gallery', 'credits', 'profile'];
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) setActiveSection(entry.target.id);
        });
      },
      { rootMargin: '-30% 0px -60% 0px' }
    );
    sectionIds.forEach((id) => {
      const el = document.getElementById(id);
      if (el) observer.observe(el);
    });
    return () => observer.disconnect();
  }, []);

  return (
    <div className="single-page">
      <ScrollProgressBar progress={progress} />

      {/* ── FIXED NAV ── */}
      <nav className="sp-nav" id="sp-nav">
        <span className="sp-logo" onClick={() => scrollTo('hero')}>✨ Drape&Glow</span>
        <div className="sp-links">
          <button className={activeSection === 'tryon' ? 'active' : ''} onClick={() => scrollTo('tryon')}>AI Try-On</button>
          <button className={activeSection === 'catalogue' ? 'active' : ''} onClick={() => scrollTo('catalogue')}>Catalogue</button>
          <button className={activeSection === 'gallery' ? 'active' : ''} onClick={() => scrollTo('gallery')}>Gallery</button>
          <button className={activeSection === 'credits' ? 'active' : ''} onClick={() => scrollTo('credits')}>Credits</button>
          <button className={activeSection === 'profile' ? 'active' : ''} onClick={() => scrollTo('profile')}>Profile</button>
        </div>
        {authUser ? (
          <div className="nav-auth-actions">
            <button className="btn ghost small" type="button" onClick={() => scrollTo('profile')}>
              {authUser.name.split(' ')[0] || 'Account'}
            </button>
            <button
              className="btn primary small"
              type="button"
              onClick={() => {
                clearStoredAuthUser();
                showToast('You have been logged out.', 'success');
              }}
            >
              Log Out
            </button>
          </div>
        ) : (
          <Link className="btn primary small" to="/signup">Get Started</Link>
        )}
      </nav>

      {/* ── HERO ── */}
      <HeroSection />

      {/* ── AI TRY-ON ── */}
      <TryOnSection showToast={showToast} />

      {/* ── CATALOGUE ── */}
      <CatalogueSection />

      {/* ── GALLERY ── */}
      <GallerySection />

      {/* ── CREDITS ── */}
      <CreditsSection showToast={showToast} />

      {/* ── PROFILE ── */}
      <ProfileSection showToast={showToast} />

      {/* ── FOOTER ── */}
      <footer className="sp-footer">
        <div className="sp-footer-inner">
          <div className="sp-footer-column">
            <span className="sp-footer-heading">Collections</span>
            <div className="sp-footer-links">
              <button onClick={() => scrollTo('catalogue')}>Kanjivaram Edit</button>
              <button onClick={() => scrollTo('catalogue')}>Banarasi Heritage</button>
              <button onClick={() => scrollTo('catalogue')}>Bandhani Stories</button>
              <button onClick={() => scrollTo('tryon')}>Festive Drapes</button>
              <button onClick={() => scrollTo('gallery')}>Saved Looks</button>
            </div>
          </div>
          <div className="sp-footer-column">
            <span className="sp-footer-heading">Useful Links</span>
            <div className="sp-footer-links">
              <button onClick={() => scrollTo('tryon')}>AI Try-On Studio</button>
              <button onClick={() => scrollTo('credits')}>Credits and Billing</button>
              <button onClick={() => scrollTo('profile')}>Profile Settings</button>
              <Link to="/portal/dashboard">Developer Portal</Link>
              <Link to="/portal/docs">API Docs</Link>
            </div>
          </div>
        </div>
        <div className="sp-footer-bottom">
          <div className="sp-footer-utility">
            <div className="sp-footer-socials" aria-label="Social links">
              <button type="button" aria-label="Facebook">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M18 2h-3a5 5 0 00-5 5v3H7v4h3v8h4v-8h3l1-4h-4V7a1 1 0 011-1h3z"/></svg>
              </button>
              <button type="button" aria-label="Instagram">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="2" y="2" width="20" height="20" rx="5" ry="5"/><path d="M16 11.37A4 4 0 1112.63 8 4 4 0 0116 11.37z"/><line x1="17.5" y1="6.5" x2="17.51" y2="6.5"/></svg>
              </button>
              <button type="button" aria-label="YouTube">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M23.498 6.186a3.016 3.016 0 00-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 00.502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 002.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 002.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z"/></svg>
              </button>
            </div>
            <label className="sp-footer-language">
              <span>Language</span>
              <select value={footerLanguage} onChange={(e) => setFooterLanguage(e.target.value)}>
                <option>English</option>
                <option>Hindi</option>
                <option>Tamil</option>
              </select>
            </label>
          </div>
          <p className="sp-footer-copy">© 2026 Drape&Glow. She is styled.</p>
        </div>
      </footer>

      {/* ── Back to top ── */}
      <button className={`back-to-top ${showTop ? 'visible' : ''}`} onClick={() => scrollTo('hero')} title="Back to top">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><polyline points="18 15 12 9 6 15"/></svg>
      </button>

      {/* ── Toasts ── */}
      <ToastContainer />
    </div>
  );
}

/* ═══════════════════════════════════════════════════
   HERO SECTION
   ═══════════════════════════════════════════════════ */
function AnimatedStat({ end, suffix, label }: { end: number; suffix: string; label: string }) {
  const { count, ref } = useAnimatedCounter(end);
  return (
    <div className="sp-stat">
      <span className="sp-stat-num" ref={ref}>{count.toLocaleString()}{suffix}</span>
      <span className="sp-stat-label">{label}</span>
    </div>
  );
}

function HeroSection() {
  return (
    <section className="sp-hero" id="hero">
      <div className="sp-hero-inner">
        <div className="sp-hero-left">
          <span className="sp-chip animated-badge">✨ AI-POWERED VIRTUAL TRY-ON</span>
          <h1 className="sp-headline">
            See Yourself in<br />
            Any <em>Saree</em>,<br />
            Instantly
          </h1>
          <p className="sp-sub">
            Upload your photo, choose a saree, and watch AI create a photorealistic
            image of you wearing it. No studio. No hassle. Just confidence.
          </p>
          <div className="sp-ctas">
            <button className="btn primary" onClick={() => scrollTo('tryon')}>Start Try-On →</button>
            <button className="btn outline" onClick={() => scrollTo('catalogue')}>Browse Sarees</button>
          </div>
          <div className="sp-stats">
            <AnimatedStat end={50} suffix="K+" label="Happy Customers" />
            <AnimatedStat end={200} suffix="K+" label="Try-Ons Generated" />
            <AnimatedStat end={98} suffix="%" label="Satisfaction Rate" />
          </div>
        </div>
        <div className="sp-hero-right">
          <img
            className="sp-hero-image"
            src={heroResultImage}
            alt="AI drape preview"
            loading="eager"
            decoding="async"
            fetchPriority="high"
          />
        </div>
      </div>

      {/* How It Works */}
      <div className="sp-steps-wrap">
        <p className="sp-section-label reveal">How It Works</p>
        <div className="sp-steps-row stagger">
          {[
            { n: '01', t: 'Upload Your Photo', d: 'A clear front-facing picture is all you need.', icon: '📸' },
            { n: '02', t: 'Pick a Saree & Style', d: 'Browse our curated catalogue and choose a draping direction.', icon: '👗' },
            { n: '03', t: 'Get Your Drape', d: 'Our AI renders a realistic preview in seconds.', icon: '✨' },
          ].map((s, i) => (
            <div key={i} className="sp-step-card reveal glow-card">
              <span className="sp-step-num">{s.icon} {s.n}</span>
              <h4>{s.t}</h4>
              <p>{s.d}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════════
   TRY-ON SECTION (full couture studio)
   ═══════════════════════════════════════════════════ */
function TryOnSection({ showToast }: { showToast: (msg: string, type?: string) => void }) {
  const [selectedSareeId, setSelectedSareeId] = useState('s1');
  const [collectionMode, setCollectionMode] = useState<'collection' | 'upload'>('collection');
  const [selectedStyle, setSelectedStyle] = useState('Nivi Style');
  const [showStylistModal, setShowStylistModal] = useState(false);
  const [stylistMode, setStylistMode] = useState<'autonomous' | 'describe'>('autonomous');
  const [progress, setProgress] = useState(12);
  const [isApplying, setIsApplying] = useState(false);
  const [activeVariationLabel, setActiveVariationLabel] = useState('Front View');
  const frameRef = useRef<HTMLDivElement>(null);
  const dragStateRef = useRef({ originX: 0, originY: 0, panStartX: 0, panStartY: 0, zoom: 1 });
  const [zoomLevel, setZoomLevel] = useState(1);
  const [panOffset, setPanOffset] = useState({ x: 0, y: 0 });
  const [isDragging, setIsDragging] = useState(false);
  const ZOOM_STEP = 0.5, ZOOM_MIN = 1, ZOOM_MAX = 3;

  const clampPan = (x: number, y: number, zoom: number) => {
    const fw = frameRef.current?.clientWidth ?? 600;
    const fh = frameRef.current?.clientHeight ?? 500;
    const maxX = (fw * (zoom - 1)) / 2;
    const maxY = (fh * (zoom - 1)) / 2;
    return { x: Math.max(-maxX, Math.min(maxX, x)), y: Math.max(-maxY, Math.min(maxY, y)) };
  };
  const handleZoomIn = () => { const n = Math.min(+(zoomLevel + ZOOM_STEP).toFixed(1), ZOOM_MAX); setZoomLevel(n); setPanOffset((p) => clampPan(p.x, p.y, n)); };
  const handleZoomOut = () => { const n = Math.max(+(zoomLevel - ZOOM_STEP).toFixed(1), ZOOM_MIN); setZoomLevel(n); setPanOffset((p) => clampPan(p.x, p.y, n)); };
  const handleZoomReset = () => { setZoomLevel(1); setPanOffset({ x: 0, y: 0 }); };
  const handleFrameMouseDown = (e: React.MouseEvent<HTMLDivElement>) => {
    if (zoomLevel <= 1) return;
    e.preventDefault();
    dragStateRef.current = { originX: e.clientX, originY: e.clientY, panStartX: panOffset.x, panStartY: panOffset.y, zoom: zoomLevel };
    setIsDragging(true);
    const onMove = (ev: MouseEvent) => {
      const { originX, originY, panStartX, panStartY, zoom } = dragStateRef.current;
      setPanOffset(clampPan(panStartX + (ev.clientX - originX), panStartY + (ev.clientY - originY), zoom));
    };
    const onUp = () => { setIsDragging(false); window.removeEventListener('mousemove', onMove); window.removeEventListener('mouseup', onUp); };
    window.addEventListener('mousemove', onMove);
    window.addEventListener('mouseup', onUp);
  };

  const selectedSaree = sarees.find((i) => i.id === selectedSareeId) || sarees[0];
  const drapeStyles = ['Nivi Style', 'Bengali Style', 'Nauvari/Kashta Style', 'Gujarati Style', 'Lehenga Style', 'Butterfly/Mumtaz Style', 'Madisar/Tamil Brahmin Style', 'Kodagu/Coorg Style'];
  const accessoryIdeas = [
    { name: 'Maang Tikka', place: 'Center of forehead' },
    { name: 'Nose Ring (Nath)', place: 'Left nostril' },
    { name: 'Bangles', place: 'Both wrists' },
    { name: 'Gajra', place: 'Wrapped around bun' },
    { name: 'Waist Belt', place: 'Over saree pleats' },
  ];
  const previewVariations = [
    { label: 'Front View', imageUrl: frontViewImage, objectPosition: 'center top' },
    { label: 'Side View', imageUrl: sideViewImage, objectPosition: 'center top' },
    { label: 'Back View', imageUrl: backViewImage, objectPosition: 'center top' },
    { label: 'Pallu View', imageUrl: palluViewImage, objectPosition: 'center top' },
  ];
  const activeVariation = previewVariations.find((v) => v.label === activeVariationLabel) || previewVariations[0];

  const onApplyAiCouture = () => {
    if (isApplying) return;
    showToast('Starting AI Drape generation...', 'success');
    setActiveVariationLabel('Front View');
    setIsApplying(true); setProgress(15);
    const timer = setInterval(() => {
      setProgress((v) => {
        if (v >= 100) {
          clearInterval(timer);
          setIsApplying(false);
          showToast('Success! Your drape is ready.', 'success');
          return 100;
        }
        return Math.min(v + 11, 100);
      });
    }, 340);
  };

  return (
    <section className="sp-section" id="tryon">
      <div className="sp-section-inner">
        <div className="section-header reveal">
          <span className="section-tag">GET STARTED</span>
          <h2 className="section-title">AI Virtual Try-On Studio</h2>
          <p className="section-description">Upload your photo, select a saree style, and let our AI create magic</p>
        </div>

        {/* Step 1: Saree Base */}
        <article className="card couture-section reveal glow-card">
          <h3>1. Choose Your Saree Base</h3>
          <div className="section-split">
            <div className="section-main">
              <div className="mode-switch">
                <button className={collectionMode === 'collection' ? 'active' : ''} onClick={() => setCollectionMode('collection')}>Curated Rack</button>
                <button className={collectionMode === 'upload' ? 'active' : ''} onClick={() => setCollectionMode('upload')}>Custom Upload</button>
              </div>
              {collectionMode === 'collection' ? (
                <>
                  <div className="fabric-grid">
                    {sarees.slice(0, 4).map((item) => (
                      <button key={item.id} className={`fabric-card ${selectedSareeId === item.id ? 'active' : ''}`} onClick={() => setSelectedSareeId(item.id)}>
                        <span className="fabric-chip" />
                        <strong>{item.name}</strong>
                        <small>{item.fabric}</small>
                      </button>
                    ))}
                  </div>
                  <div className="custom-color-row">
                    <div><p className="muted">Custom Color</p><strong>Tune saree palette</strong></div>
                    <div className="color-swatches"><span /><span /></div>
                  </div>
                </>
              ) : (
                <div className="upload-own-grid">
                  {['Body/Pattern', 'Border', 'Pallu'].map((slot) => (
                    <article className="upload-slot" key={slot}><div>Upload</div><small>{slot}</small></article>
                  ))}
                </div>
              )}
            </div>
            <aside className="section-side selection-summary">
              <p className="muted">Selected Saree</p>
              <div className="saree-icon-placeholder">🪡</div>
              <h4>{selectedSaree.name}</h4>
              <p className="muted">{selectedSaree.region} | {selectedSaree.fabric}</p>
              <button className="btn outline small">Change Photo</button>
            </aside>
          </div>
        </article>

        {/* Step 2: Draping Direction */}
        <article className="card couture-section reveal glow-card">
          <div className="list-head">
            <h3>2. Select Draping Direction</h3>
            <p className="muted">Pick a traditional flow or design your own</p>
          </div>
          <div className="section-split">
            <div className="section-main">
              <div className="style-grid">
                {drapeStyles.map((style) => (
                  <button key={style} className={`style-card ${selectedStyle === style ? 'active' : ''}`} onClick={() => setSelectedStyle(style)}>
                    <h4>{style}</h4>
                    <p>Traditional and modern drape behavior preview.</p>
                  </button>
                ))}
              </div>
            </div>
            <aside className="section-side style-quick-panel">
              <p className="muted">Current Style</p>
              <h4>{selectedStyle}</h4>
              <p className="muted">You can switch styles anytime before final export.</p>
              <button className="apply-couture" onClick={onApplyAiCouture}>
                {isApplying ? 'Composing Your Look...' : 'Craft My Drape'}
              </button>
            </aside>
          </div>
        </article>

        {/* Result Preview */}
        <section className="result-layout reveal">
          <article className="card result-preview glow-card">
            <div className="progress-wrap">
              <div className="progress-track"><span style={{ width: `${progress}%` }} /></div>
              <strong>{progress}%</strong>
            </div>
            <div ref={frameRef} className="result-image-frame" onMouseDown={handleFrameMouseDown}
              style={{ cursor: zoomLevel > 1 ? (isDragging ? 'grabbing' : 'grab') : 'default' }}>
              <img className="result-image" src={activeVariation.imageUrl} alt={`${activeVariation.label} output`} loading="lazy" decoding="async"
                style={{ objectPosition: activeVariation.objectPosition, transform: `translate(${panOffset.x}px, ${panOffset.y}px) scale(${zoomLevel})`, transformOrigin: 'center center', transition: isDragging ? 'none' : 'transform 0.2s ease', userSelect: 'none', pointerEvents: 'none' }} />
              <div className="zoom-controls">
                <button className="zoom-btn" title="Zoom Out" disabled={zoomLevel <= ZOOM_MIN} onClick={handleZoomOut}>−</button>
                <button className="zoom-btn zoom-label" title="Reset" disabled={zoomLevel === 1} onClick={handleZoomReset}>{Math.round(zoomLevel * 100)}%</button>
                <button className="zoom-btn" title="Zoom In" disabled={zoomLevel >= ZOOM_MAX} onClick={handleZoomIn}>+</button>
              </div>
            </div>
            <div className="result-thumbs">
              {previewVariations.map((v) => (
                <button key={v.label} type="button" className={`result-variant ${activeVariationLabel === v.label ? 'active' : ''}`}
                  onClick={() => { setActiveVariationLabel(v.label); setZoomLevel(1); setPanOffset({ x: 0, y: 0 }); }}>
                  <img src={v.imageUrl} alt={v.label} loading="lazy" decoding="async" style={{ objectPosition: v.objectPosition }} />
                  <span>{v.label}</span>
                </button>
              ))}
            </div>
          </article>
          <aside className="card stylist-panel">
            <h4>Stylist Notes</h4>
            <p className="muted">This pairing balances rich texture with a soft vertical fall, giving you a refined silhouette with festive warmth.</p>
            <button className="btn gold" onClick={() => setShowStylistModal(true)}>Refine with Stylist</button>
            <button className="btn ghost">Adjust Render Settings</button>
            <div className="palette-row"><span /><span /><span /><span /></div>
            <button className="btn primary">Download Hero Shot</button>
            <button className="btn primary">Download Full Set</button>
            <button className="btn ghost">Share Lookbook</button>
            <div className="accessory-list">
              {accessoryIdeas.map((a) => (<article key={a.name}><strong>{a.name}</strong><p>{a.place}</p></article>))}
            </div>
          </aside>
        </section>

        {showStylistModal && (
          <div className="stylist-modal-backdrop" role="presentation">
            <div className="stylist-modal card" role="dialog" aria-modal="true">
              <h3>Stylist Assist</h3>
              <p className="muted">Choose how you want to finalize this look.</p>
              <div className="stylist-options">
                <button className={stylistMode === 'autonomous' ? 'active' : ''} onClick={() => setStylistMode('autonomous')}>
                  <strong>Auto Curate</strong><span>Let the system suggest accessories and accents.</span>
                </button>
                <button className={stylistMode === 'describe' ? 'active' : ''} onClick={() => setStylistMode('describe')}>
                  <strong>Guide Manually</strong><span>Provide your preference notes for custom styling.</span>
                </button>
              </div>
              <div className="flow-actions">
                <button className="btn ghost" onClick={() => setShowStylistModal(false)}>Cancel</button>
                <button className="btn gold" onClick={() => setShowStylistModal(false)}>Apply</button>
              </div>
            </div>
          </div>
        )}
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════════
   CATALOGUE SECTION
   ═══════════════════════════════════════════════════ */
function CatalogueSection() {
  const fabricOptions = ['All', 'Silk', 'Cotton', 'Georgette'];
  const regionOptions = ['All', 'Tamil Nadu', 'Uttar Pradesh', 'Gujarat', 'Maharashtra', 'Odisha'];
  const [fabric, setFabric] = useState('All');
  const [region, setRegion] = useState('All');
  const [search, setSearch] = useState('');
  const [openFilter, setOpenFilter] = useState<'fabric' | 'region' | null>(null);
  const fabricFilterRef = useRef<HTMLDivElement>(null);
  const regionFilterRef = useRef<HTMLDivElement>(null);

  const fabricCounts = useMemo(() => {
    const counts: Record<string, number> = Object.fromEntries(fabricOptions.map((option) => [option, 0]));
    const normalizedSearch = search.trim().toLowerCase();
    sarees.forEach((item) => {
      if (region !== 'All' && item.region !== region) return;
      if (normalizedSearch && !item.name.toLowerCase().includes(normalizedSearch)) return;
      counts.All += 1;
      counts[item.fabric] = (counts[item.fabric] || 0) + 1;
    });
    return counts;
  }, [fabricOptions, region, search]);

  const regionCounts = useMemo(() => {
    const counts: Record<string, number> = Object.fromEntries(regionOptions.map((option) => [option, 0]));
    const normalizedSearch = search.trim().toLowerCase();
    sarees.forEach((item) => {
      if (fabric !== 'All' && item.fabric !== fabric) return;
      if (normalizedSearch && !item.name.toLowerCase().includes(normalizedSearch)) return;
      counts.All += 1;
      counts[item.region] = (counts[item.region] || 0) + 1;
    });
    return counts;
  }, [fabric, regionOptions, search]);

  useEffect(() => {
    const handleOutsideClick = (event: MouseEvent) => {
      const target = event.target as Node;
      if (
        fabricFilterRef.current?.contains(target)
        || regionFilterRef.current?.contains(target)
      ) {
        return;
      }
      setOpenFilter(null);
    };

    const handleEscape = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        setOpenFilter(null);
      }
    };

    document.addEventListener('mousedown', handleOutsideClick);
    document.addEventListener('keydown', handleEscape);
    return () => {
      document.removeEventListener('mousedown', handleOutsideClick);
      document.removeEventListener('keydown', handleEscape);
    };
  }, []);

  const filtered = useMemo(() => {
    return sarees.filter((item) => {
      if (fabric !== 'All' && item.fabric !== fabric) return false;
      if (region !== 'All' && item.region !== region) return false;
      if (search && !item.name.toLowerCase().includes(search.toLowerCase())) return false;
      return true;
    });
  }, [fabric, region, search]);

  return (
    <section className="sp-section sp-section-alt" id="catalogue">
      <div className="sp-section-inner">
        <div className="section-header reveal">
          <span className="section-tag">BROWSE</span>
          <h2 className="section-title">Saree Catalogue</h2>
          <p className="section-description">Explore our curated collection of premium sarees</p>
        </div>
        <div className="sp-filters reveal">
          <div className="filter-control filter-control-search">
            <label htmlFor="catalog-search">Search</label>
            <input id="catalog-search" value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search sarees..." className="sp-search" />
          </div>
          <div className="filter-control">
            <label id="catalog-fabric-label">Fabric</label>
            <div className="filter-dropdown" ref={fabricFilterRef}>
              <button
                type="button"
                className={`filter-dropdown-trigger ${openFilter === 'fabric' ? 'open' : ''}`}
                aria-expanded={openFilter === 'fabric'}
                aria-haspopup="listbox"
                aria-labelledby="catalog-fabric-label"
                onClick={() => setOpenFilter((current) => (current === 'fabric' ? null : 'fabric'))}
              >
                <span className="filter-trigger-value">{fabric}</span>
                <span className="filter-trigger-meta">{fabricCounts[fabric] || 0} styles</span>
              </button>
              {openFilter === 'fabric' && (
                <div className="filter-dropdown-menu" role="listbox" aria-label="Fabric options">
                  {fabricOptions.map((option) => (
                    <button
                      key={option}
                      type="button"
                      role="option"
                      aria-selected={fabric === option}
                      className={`filter-dropdown-option ${fabric === option ? 'selected' : ''}`}
                      onClick={() => {
                        setFabric(option);
                        setOpenFilter(null);
                      }}
                    >
                      <span className="filter-option-main">{option}</span>
                      <span className="filter-option-meta">{fabricCounts[option] || 0} sarees</span>
                    </button>
                  ))}
                </div>
              )}
            </div>
          </div>
          <div className="filter-control">
            <label id="catalog-region-label">Region</label>
            <div className="filter-dropdown" ref={regionFilterRef}>
              <button
                type="button"
                className={`filter-dropdown-trigger ${openFilter === 'region' ? 'open' : ''}`}
                aria-expanded={openFilter === 'region'}
                aria-haspopup="listbox"
                aria-labelledby="catalog-region-label"
                onClick={() => setOpenFilter((current) => (current === 'region' ? null : 'region'))}
              >
                <span className="filter-trigger-value">{region}</span>
                <span className="filter-trigger-meta">{regionCounts[region] || 0} styles</span>
              </button>
              {openFilter === 'region' && (
                <div className="filter-dropdown-menu" role="listbox" aria-label="Region options">
                  {regionOptions.map((option) => (
                    <button
                      key={option}
                      type="button"
                      role="option"
                      aria-selected={region === option}
                      className={`filter-dropdown-option ${region === option ? 'selected' : ''}`}
                      onClick={() => {
                        setRegion(option);
                        setOpenFilter(null);
                      }}
                    >
                      <span className="filter-option-main">{option}</span>
                      <span className="filter-option-meta">{regionCounts[option] || 0} sarees</span>
                    </button>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
        <div className="catalog-grid stagger">
          {filtered.map((item) => (
            <article className="saree-card card reveal glow-card" key={item.id}>
              <div className="saree-image-placeholder">Image Placeholder</div>
              <div className="saree-card-content">
                <h3>{item.name}</h3>
                <p className="muted">{item.region} | {item.fabric}</p>
                <p className="price">INR {item.price.toLocaleString('en-IN')}</p>
                <button className="btn primary small" onClick={() => scrollTo('tryon')}>Try On →</button>
              </div>
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════════
   GALLERY SECTION
   ═══════════════════════════════════════════════════ */
function GallerySection() {
  const [items] = useState<TryOnResult[]>(galleryItems);

  return (
    <section className="sp-section" id="gallery">
      <div className="sp-section-inner">
        <div className="section-header reveal">
          <span className="section-tag">YOUR CREATIONS</span>
          <h2 className="section-title">My Gallery</h2>
          <p className="section-description">Browse your AI-generated saree try-ons</p>
        </div>
        <div className="gallery-grid stagger">
          {items.map((item) => (
            <article className="card gallery-card reveal glow-card" key={item.id}>
              <img src={item.imageUrl} alt={item.sareeName} loading="lazy" decoding="async" />
              <div className="gallery-card-info">
                <h4>{item.sareeName}</h4>
                <p className="muted">{item.createdAt}</p>
              </div>
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════════
   CREDITS SECTION
   ═══════════════════════════════════════════════════ */
function CreditsSection({ showToast }: { showToast: (msg: string, type?: string) => void }) {
  const [balance, setBalance] = useState(42);
  const [selected, setSelected] = useState<string>('b2');
  const selectedBundle = bundles.find((bundle) => bundle.id === selected) || bundles[0];
  const projectedBalance = balance + selectedBundle.credits;
  const balanceProgress = Math.min((balance / 150) * 100, 100);
  const bundleDetails: Record<string, { label: string; save?: string; narrative: string; highlights: string[] }> = {
    b1: {
      label: 'Great for occasional styling',
      narrative: 'A lighter pack for quick festive try-ons and one-off experiments.',
      highlights: ['Quick top-up', 'Single-look friendly'],
    },
    b2: {
      label: 'Best for regular styling',
      save: 'Recommended',
      narrative: 'Balanced for repeat try-ons, polished previews, and weekly wardrobe planning.',
      highlights: ['Best value', 'Regular use'],
    },
    b3: {
      label: 'Built for high-volume work',
      narrative: 'Made for creators, repeated refinements, and bulk look development.',
      highlights: ['High volume', 'Campaign ready'],
    },
  };

  return (
    <section className="sp-section sp-section-alt" id="credits">
      <div className="sp-section-inner">
        <div className="section-header reveal">
          <span className="section-tag">PRICING</span>
          <h2 className="section-title">Credits & Billing</h2>
          <p className="section-description">Get 3 free credits every month. Need more? Choose a plan.</p>
        </div>
        <div className="sp-credits-layout">
          <div className="card balance-card reveal glow-card">
            <div className="balance-card-top">
              <span className="mini-kicker">Wallet</span>
              <p className="muted">A simple view of your credits, monthly refresh, and what your next pack adds.</p>
            </div>
            <div className="balance-display">
              <p className="muted">Available credits</p>
              <h2 className="balance-number">{balance}</h2>
            </div>
            <div className="balance-meter" aria-hidden="true">
              <span style={{ width: `${balanceProgress}%` }} />
            </div>
            <div className="balance-meta-grid">
              <article>
                <strong>{Math.max(1, Math.floor(balance / 3))}</strong>
                <span>Estimated premium renders</span>
              </article>
              <article>
                <strong>+3 / month</strong>
                <span>Free monthly credits</span>
              </article>
            </div>
            <p className="balance-caption muted">Selecting <strong>{selectedBundle.label}</strong> will take your balance to <strong>{projectedBalance}</strong> credits.</p>
          </div>
          <div className="card sp-bundles-card reveal glow-card">
            <div className="billing-headline-row">
              <div>
                <span className="mini-kicker">Pricing</span>
                <h3>Choose your credit pack</h3>
              </div>
              <div className="billing-inline-summary">
                <span className="muted">After purchase</span>
                <strong>{projectedBalance} credits</strong>
              </div>
            </div>
            <div className="bundle-grid">
              {bundles.map((b) => (
                <button key={b.id} className={`bundle ${selected === b.id ? 'active' : ''}`} onClick={() => setSelected(b.id)}>
                  <div className="bundle-topline">
                    <div>
                      <span className="bundle-plan">{b.label}</span>
                      <small>{bundleDetails[b.id].label}</small>
                    </div>
                    {bundleDetails[b.id].save && <span className="bundle-badge">{bundleDetails[b.id].save}</span>}
                  </div>
                  <span className="bundle-radio" aria-hidden="true"><i /></span>
                  <strong className="bundle-credits">{b.credits} credits</strong>
                  <span className="bundle-price">INR {b.price.toLocaleString('en-IN')}</span>
                  <span className="bundle-unit">INR {Math.round(b.price / b.credits)} per credit</span>
                  <p className="bundle-narrative">{bundleDetails[b.id].narrative}</p>
                  <div className="bundle-perks">
                    {bundleDetails[b.id].highlights.map((item) => (
                      <span key={item}>{item}</span>
                    ))}
                  </div>
                </button>
              ))}
            </div>
            <div className="billing-action-bar">
              <div className="billing-action-copy">
                <span className="muted">Selected pack</span>
                <strong>{selectedBundle.label} • {selectedBundle.credits} credits • INR {selectedBundle.price.toLocaleString('en-IN')}</strong>
                <small>Secure checkout preview. Credits are applied instantly in this demo flow.</small>
              </div>
              <button className="btn primary billing-pay-btn" onClick={() => {
                setBalance((v) => v + selectedBundle.credits);
                showToast(`Successfully purchased ${selectedBundle.credits} credits!`, 'success');
              }}>
                Pay INR {selectedBundle.price.toLocaleString('en-IN')}
              </button>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════════
   PROFILE SECTION
   ═══════════════════════════════════════════════════ */
function ProfileSection({ showToast }: { showToast: (msg: string, type?: string) => void }) {
  const storedAuthUser = useMemo(() => loadStoredAuthUser(), []);
  const [fullName, setFullName] = useState(storedAuthUser?.name || 'Guest User');
  const [email, setEmail] = useState(storedAuthUser?.email || 'guest@example.com');
  const [phone, setPhone] = useState('+91 98765 43210');
  const [city, setCity] = useState('Bengaluru');
  const [language, setLanguage] = useState('English');
  const [bodyType, setBodyType] = useState('Athletic');
  const [quality, setQuality] = useState('High');
  const [theme, setTheme] = useState('Rose Noir');
  const [pushEnabled, setPushEnabled] = useState(true);
  const [emailUpdates, setEmailUpdates] = useState(true);
  const initials = useMemo(() => {
    const parts = fullName.trim().split(/\s+/).filter(Boolean);
    if (!parts.length) return 'GU';
    return parts.slice(0, 2).map((p) => p[0].toUpperCase()).join('');
  }, [fullName]);

  return (
    <section className="sp-section" id="profile">
      <div className="sp-section-inner">
        <div className="section-header reveal">
          <span className="section-tag">ACCOUNT</span>
          <h2 className="section-title">Your Profile</h2>
          <p className="section-description">Manage your preferences and settings</p>
        </div>
        <div className="profile-layout stagger">
          <aside className="card profile-summary reveal glow-card">
            <div className="profile-identity">
              <div className="profile-avatar">{initials}</div>
              <div>
                <h2>{fullName}</h2>
                <p className="muted">{email}</p>
              </div>
            </div>
            <div className="profile-badges">
              <span className="chip">Premium Plan</span>
              <span className="chip muted-chip">Member since Jan 2026</span>
            </div>
            <div className="profile-summary-stats">
              <article>
                <span>Credits</span>
                <strong>42</strong>
              </article>
              <article>
                <span>Saved Drapes</span>
                <strong>18</strong>
              </article>
              <article>
                <span>Theme Packs</span>
                <strong>6</strong>
              </article>
            </div>
            <div className="profile-membership-card">
              <span className="mini-kicker">Styling Status</span>
              <h3>Ready for your next festive drape</h3>
              <p className="muted">Your current preferences are tuned for high-quality previews and editorial styling.</p>
            </div>
          </aside>
          <div className="profile-settings-stack">
            <article className="card profile-card reveal glow-card">
              <div className="profile-section-head">
                <div>
                  <h3>Personal Details</h3>
                  <p className="muted">Update the details used across your try-ons and account history.</p>
                </div>
              </div>
              <div className="profile-form-grid">
                <label>Full Name<input value={fullName} onChange={(e) => setFullName(e.target.value)} /></label>
                <label>Email Address<input value={email} onChange={(e) => setEmail(e.target.value)} /></label>
                <label>Mobile<input value={phone} onChange={(e) => setPhone(e.target.value)} /></label>
                <label>City<input value={city} onChange={(e) => setCity(e.target.value)} /></label>
                <label>Language<select value={language} onChange={(e) => setLanguage(e.target.value)}><option>English</option><option>Hindi</option><option>Tamil</option><option>Telugu</option><option>Kannada</option></select></label>
                <label>Body Type<select value={bodyType} onChange={(e) => setBodyType(e.target.value)}><option>Athletic</option><option>Petite</option><option>Curvy</option><option>Tall</option></select></label>
              </div>
            </article>
            <article className="card profile-card reveal glow-card">
              <div className="profile-section-head">
                <div>
                  <h3>Draping Preferences</h3>
                  <p className="muted">Choose the rendering quality, theme, and update preferences for styling alerts.</p>
                </div>
              </div>
              <div className="profile-form-grid compact">
                <label>Default Quality<select value={quality} onChange={(e) => setQuality(e.target.value)}><option>Balanced</option><option>High</option><option>Ultra</option></select></label>
                <label>Interface Theme<select value={theme} onChange={(e) => setTheme(e.target.value)}><option>Rose Noir</option><option>Ivory Gold</option><option>Monochrome Silk</option></select></label>
              </div>
              <div className="profile-toggles">
                <label className="toggle-row">
                  <span><strong>Push Notifications</strong><small>Get alerts for completed drapes and credits</small></span>
                  <input type="checkbox" checked={pushEnabled} onChange={(e) => setPushEnabled(e.target.checked)} />
                </label>
                <label className="toggle-row">
                  <span><strong>Email Updates</strong><small>Receive design drops and seasonal tips</small></span>
                  <input type="checkbox" checked={emailUpdates} onChange={(e) => setEmailUpdates(e.target.checked)} />
                </label>
              </div>
              <div className="profile-actions">
                <button className="btn ghost">Cancel</button>
                <button className="btn primary" onClick={() => {
                  saveStoredAuthUser({ name: fullName.trim() || 'Guest User', email: email.trim() || 'guest@example.com' });
                  showToast('Profile settings saved successfully!', 'success');
                }}>Save Changes</button>
              </div>
            </article>
          </div>
        </div>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════════
   AUTH PAGES (kept as separate routes)
   ═══════════════════════════════════════════════════ */
function AuthPage({ initialMode }: { initialMode: 'login' | 'signup' }) {
  const navigate = useNavigate();
  const [mode, setMode] = useState<'login' | 'signup'>(initialMode);
  const [remember, setRemember] = useState(true);
  const [authName, setAuthName] = useState('');
  const [authEmail, setAuthEmail] = useState('');
  const [authPassword, setAuthPassword] = useState('');
  const [googleAuthError, setGoogleAuthError] = useState<string | null>(null);
  const hasGoogleClientId = Boolean(import.meta.env.VITE_GOOGLE_CLIENT_ID);

  const googleLogin = useGoogleLogin({
    flow: 'implicit',
    scope: 'openid profile email',
    prompt: 'select_account',
    onSuccess: async (tokenResponse) => {
      try {
        const profileRes = await fetch('https://www.googleapis.com/oauth2/v3/userinfo', {
          headers: {
            Authorization: `Bearer ${tokenResponse.access_token}`,
          },
        });

        if (!profileRes.ok) {
          throw new Error('Failed to read Google profile');
        }

        const profile = (await profileRes.json()) as GoogleUserInfo;
        if (!profile.email) {
          throw new Error('Google account email is unavailable');
        }

        const resolvedName = profile.name?.trim() || deriveNameFromEmail(profile.email);
        saveStoredAuthUser({ name: resolvedName, email: profile.email.trim() });
        setAuthName(resolvedName);
        setAuthEmail(profile.email.trim());
        setGoogleAuthError(null);
        navigate('/');
      } catch {
        setGoogleAuthError('Google sign-in could not be completed. Please try again.');
      }
    },
    onError: () => {
      setGoogleAuthError('Google sign-in was canceled or failed.');
    },
  });

  useEffect(() => {
    setMode(initialMode);
  }, [initialMode]);

  return (
    <section className="login-shell">
      <div className="login-visual">
        <img src={loginPageImage} alt="Architectural background" loading="eager" decoding="async" fetchPriority="high" />
      </div>

      <div className="login-panel card">
        <div className="login-header">
          <span className="mini-kicker">{mode === 'login' ? 'Member Access' : 'Get Started'}</span>
          <h2>{mode === 'login' ? 'Welcome back' : 'Create your account'}</h2>
          <p className="muted">
            {mode === 'login'
              ? 'Sign in to continue your saree try-ons, saved looks, and styling preferences.'
              : 'Create your account to save looks, manage preferences, and continue your styling journey.'}
          </p>
        </div>

        <div className="social-auth-stack">
          <button
            className="social-auth-btn google-auth-btn"
            type="button"
            disabled={!hasGoogleClientId}
            onClick={() => {
              if (!hasGoogleClientId) {
                setGoogleAuthError('Google OAuth is not configured yet. Add VITE_GOOGLE_CLIENT_ID in your frontend env file.');
                return;
              }
              setGoogleAuthError(null);
              googleLogin();
            }}
          >
            <img className="google-auth-icon" src={googleLogoImage} alt="" aria-hidden="true" />
            <span>Continue with Google</span>
          </button>
          {googleAuthError && <p className="auth-inline-error">{googleAuthError}</p>}
        </div>

        <div className="auth-divider" aria-hidden="true"><span>or</span></div>

        <form className="stack login-form" onSubmit={(e) => {
          e.preventDefault();
          const cleanEmail = authEmail.trim();
          const previousUser = loadStoredAuthUser();
          const resolvedName = mode === 'signup'
            ? (authName.trim() || deriveNameFromEmail(cleanEmail))
            : (previousUser?.name || deriveNameFromEmail(cleanEmail));
          saveStoredAuthUser({ name: resolvedName, email: cleanEmail });
          navigate('/');
        }}>
          {mode === 'signup' && <label>Full Name<input required value={authName} onChange={(e) => setAuthName(e.target.value)} placeholder="Your name" /></label>}
          <label>Email<input type="email" required value={authEmail} onChange={(e) => setAuthEmail(e.target.value)} placeholder="you@example.com" /></label>
          <label>Password<input type="password" required value={authPassword} onChange={(e) => setAuthPassword(e.target.value)} placeholder="Enter password" /></label>
          <div className="login-inline-actions">
            {mode === 'login' ? (
              <>
                <label className="remember-row">
                  <input type="checkbox" checked={remember} onChange={(e) => setRemember(e.target.checked)} />
                  <span>Remember me</span>
                </label>
                <button type="button" className="forgot-link" onClick={() => navigate('/error')}>Forgot password?</button>
              </>
            ) : (
              <label className="remember-row">
                <input type="checkbox" defaultChecked />
                <span>I agree to Terms and Privacy Policy</span>
              </label>
            )}
          </div>
          <button className="btn primary login-submit" type="submit">{mode === 'login' ? 'Log In' : 'Create Account'}</button>
        </form>

        <div className="login-footer-note">
          <p className="muted">
            {mode === 'login' ? 'New here?' : 'Already have an account?'}{' '}
            <button type="button" className="auth-toggle-link" onClick={() => setMode(mode === 'login' ? 'signup' : 'login')}>
              {mode === 'login' ? 'Create account' : 'Log in'}
            </button>
          </p>
        </div>
      </div>
    </section>
  );
}

function ErrorFallbackPage() {
  return (
    <section className="center-page card">
      <h2>Something went wrong</h2>
      <p className="muted">An unexpected issue occurred.</p>
      <Link className="btn primary" to="/">Go Home</Link>
    </section>
  );
}

/* ═══════════════════════════════════════════════════
   PORTAL PAGES (kept as separate routes)
   ═══════════════════════════════════════════════════ */
function PortalLayout() {
  const location = useLocation();
  const inAuth = location.pathname.includes('/portal/login') || location.pathname.includes('/portal/register');
  if (inAuth) return <main className="portal-auth-wrap"><Outlet /></main>;
  return (
    <div className="portal-shell">
      <aside className="portal-sidebar">
        <h2>Developer Portal</h2>
        <NavLink to="/portal/dashboard">Dashboard</NavLink>
        <NavLink to="/portal/api-keys">API Keys</NavLink>
        <NavLink to="/portal/webhooks">Webhooks</NavLink>
        <NavLink to="/portal/billing">Billing</NavLink>
        <NavLink to="/portal/docs">Docs</NavLink>
      </aside>
      <section className="portal-main"><Outlet /></section>
    </div>
  );
}

function PortalLoginPage() { const n = useNavigate(); return (<section className="auth-page card"><h2>Developer Portal Login</h2><form className="stack" onSubmit={(e) => { e.preventDefault(); n('/portal/dashboard') }}><label>Email<input type="email" required /></label><label>Password<input type="password" required /></label><button className="btn primary" type="submit">Login</button></form><Link to="/portal/register" className="muted">Create portal account</Link></section>); }
function PortalRegisterPage() { const n = useNavigate(); return (<section className="auth-page card"><h2>Register for Developer Portal</h2><form className="stack" onSubmit={(e) => { e.preventDefault(); n('/portal/dashboard') }}><label>Company<input required /></label><label>Work Email<input type="email" required /></label><label>Password<input type="password" required /></label><button className="btn primary" type="submit">Register</button></form><Link to="/portal/login" className="muted">Already registered? Login</Link></section>); }

function PortalDashboardPage() {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const points = [35, 52, 48, 70, 60, 80, 76];
  const maxVal = Math.max(...points);
  return (
    <section className="dashboard-page">
      <div className="list-head"><h2>Dashboard</h2></div>
      <div className="stat-grid">
        {[{ l: 'Total API Calls', v: '12,480', b: '+8% this week', u: true }, { l: 'Credits Remaining', v: '3,200', b: 'Active plan', u: false }, { l: 'Try-Ons Generated', v: '847', b: '+23 today', u: true }, { l: 'Active API Keys', v: '2', b: '1 revoked', u: false }].map((s, i) => (
          <div className="card stat-card" key={i}><p className="muted">{s.l}</p><h2>{s.v}</h2><span className={`stat-badge ${s.u ? 'up' : ''}`}>{s.b}</span></div>
        ))}
      </div>
      <div className="card"><p className="muted" style={{ marginBottom: 12 }}>API Calls — Last 7 Days</p><div className="chart-box">{points.map((v, i) => (<div key={i} className="bar-col"><div className="bar" style={{ height: `${(v / maxVal) * 100}%` }} /><span className="bar-label">{days[i]}</span></div>))}</div></div>
    </section>
  );
}

function PortalApiKeysPage() {
  const [keys, setKeys] = useState<ApiKey[]>(seedApiKeys);
  return (
    <section>
      <div className="list-head"><h2>API Keys</h2><button className="btn primary small" onClick={() => setKeys((a) => [{ id: `k${a.length + 1}`, name: `New Key ${a.length + 1}`, value: `sdai_live_${Math.random().toString(36).slice(2, 10)}`, createdAt: '2026-03-13', status: 'active' }, ...a])}>Create Key</button></div>
      <div className="card table-card">{keys.map((k) => (<article className="key-row" key={k.id}><div><strong>{k.name}</strong><p className="muted">{k.value}</p></div><div className="key-actions"><span className={`status ${k.status}`}>{k.status}</span><button className="btn ghost small" onClick={() => setKeys((a) => a.map((i) => i.id === k.id ? { ...i, status: 'revoked' } : i))}>Revoke</button></div></article>))}</div>
    </section>
  );
}

function PortalWebhooksPage() { return (<section className="card"><h2>Webhook Configuration</h2><label>Endpoint URL<input placeholder="https://example.com/webhooks/tryon" /></label><label>Secret<input placeholder="whsec_xxx" /></label><label>Events<select defaultValue="tryon.completed"><option value="tryon.completed">tryon.completed</option><option value="credits.debited">credits.debited</option></select></label><button className="btn primary">Save Webhook</button></section>); }
function PortalBillingPage() { return (<section className="card"><h2>Portal Billing and Credits</h2><p className="muted">Manage organization-level credit plans.</p><div className="bundle-grid"><div className="bundle active"><strong>Team Pro</strong><span>500 credits</span><span>INR 8,999</span></div><div className="bundle"><strong>Enterprise</strong><span>2,000 credits</span><span>INR 29,999</span></div></div><button className="btn primary">Proceed to Stripe (Mocked)</button></section>); }
function PortalDocsPage() { return (<section className="docs-wrap"><aside className="card docs-nav"><h4>Documentation</h4><a href="#">Getting Started</a><a href="#">Authentication</a><a href="#">Try-On API</a><a href="#">Credits API</a><a href="#">Webhook Events</a></aside><article className="card docs-content"><h2>API Reference Layout</h2><p className="muted">Developer documentation shell for milestone 1.</p><pre>{`POST /v1/tryon/jobs\nAuthorization: Bearer <api_key>\nContent-Type: multipart/form-data`}</pre></article></section>); }

export default App;
