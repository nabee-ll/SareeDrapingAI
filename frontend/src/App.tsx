import { useEffect, useMemo, useState } from 'react';
import {
  BrowserRouter,
  Link,
  NavLink,
  Navigate,
  Outlet,
  Route,
  Routes,
  useLocation,
  useNavigate,
  useParams,
  useSearchParams,
} from 'react-router-dom';
import { apiKeys as seedApiKeys, bundles, galleryItems, sarees } from './mock';
import type { ApiKey, TryOnResult } from './types';
import './styles/theme.css';
import './styles/ui.css';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<LandingPage />} />
        <Route path="/signup" element={<SignupPage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/error" element={<ErrorFallbackPage />} />
        <Route
          path="/dashboard"
          element={<Navigate to="/portal/dashboard" replace />}
        />

        <Route element={<ConsumerLayout />}>
          <Route path="/home" element={<CataloguePage />} />
          <Route path="/saree/:id" element={<SareeDetailPage />} />
          <Route path="/try-on/upload" element={<TryOnUploadPage />} />
          <Route path="/try-on/confirm" element={<TryOnConfirmPage />} />
          <Route path="/try-on/processing" element={<TryOnProcessingPage />} />
          <Route path="/try-on/result" element={<TryOnResultPage />} />
          <Route path="/gallery" element={<MyGalleryPage />} />
          <Route path="/credits" element={<CreditsBillingPage />} />
          <Route path="/profile" element={<ProfileSettingsPage />} />
        </Route>

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

        <Route path="*" element={<NotFoundPage />} />
      </Routes>
    </BrowserRouter>
  );
}

function ConsumerLayout() {
  return (
    <div className="app-shell">
      <header className="topbar">
        <Link to="/home" className="brand">
          Drape & Glow
        </Link>
        <nav className="top-links">
          <NavLink to="/home">Catalogue</NavLink>
          <NavLink to="/try-on/upload">AI Try-On</NavLink>
          <NavLink to="/gallery">My Gallery</NavLink>
          <NavLink to="/credits">Credits</NavLink>
          <NavLink to="/profile">Profile</NavLink>
        </nav>
      </header>
      <main className="content-wrap">
        <Outlet />
      </main>
    </div>
  );
}

function PortalLayout() {
  const location = useLocation();
  const inAuth =
    location.pathname.includes('/portal/login') ||
    location.pathname.includes('/portal/register');

  if (inAuth) {
    return (
      <main className="portal-auth-wrap">
        <Outlet />
      </main>
    );
  }

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
      <section className="portal-main">
        <Outlet />
      </section>
    </div>
  );
}

function LandingPage() {
  return (
    <div className="landing-page">
      {/* ── TOP NAV ── */}
      <header className="land-nav">
        <span className="land-logo">Drape &amp; Glow</span>
        <nav className="land-links">
          <Link to="/home">Catalogue</Link>
          <Link to="/try-on/upload">AI Try-On</Link>
          <Link to="/login">Login</Link>
        </nav>
        <Link className="btn primary small" to="/signup">Get Started</Link>
      </header>

      {/* ── HERO ── */}
      <section className="land-hero">
        <div className="land-hero-left">
          <span className="land-chip">AI-Powered Virtual Draping</span>
          <h1 className="land-headline">
            Every Saree,<br />
            <em>Draped on You.</em>
          </h1>
          <p className="land-sub">
            Upload your photo once. Explore hundreds of draping styles in seconds — no
            fitting room, no uncertainty.
          </p>
          <div className="land-ctas">
            <Link className="btn primary" to="/signup">Start for Free</Link>
            <Link className="btn ghost" to="/try-on/upload">See a Demo</Link>
          </div>
          <p className="land-note">No credit card required · Results in under 10 seconds</p>
        </div>
        <div className="land-hero-right">
          <div className="land-mockup">
            <div className="land-mock-badge">✨ AI Result</div>
            <div className="land-mock-body">🪡</div>
            <div className="land-mock-label">Banarasi Heritage · Nivi Style</div>
          </div>
        </div>
      </section>

      {/* ── HOW IT WORKS ── */}
      <section className="land-steps">
        <p className="land-section-label">How It Works</p>
        <div className="land-step-row">
          <div className="land-step">
            <span className="land-step-num">01</span>
            <h4>Upload Your Photo</h4>
            <p>A clear front-facing picture is all you need — no studio setup required.</p>
          </div>
          <div className="land-step-arrow">→</div>
          <div className="land-step">
            <span className="land-step-num">02</span>
            <h4>Pick a Saree &amp; Style</h4>
            <p>Browse our curated catalogue and choose a draping direction.</p>
          </div>
          <div className="land-step-arrow">→</div>
          <div className="land-step">
            <span className="land-step-num">03</span>
            <h4>Get Your Drape</h4>
            <p>Our AI renders a realistic preview in seconds, ready to save or share.</p>
          </div>
        </div>
      </section>

      {/* ── FEATURES ── */}
      <section className="land-features">
        <p className="land-section-label">Why Drape &amp; Glow</p>
        <div className="land-feature-grid">
          <div className="land-feature-card">
            <span className="land-feat-icon">🎨</span>
            <h4>100+ Draping Styles</h4>
            <p>From classic Nivi to rare regional forms — all in one place.</p>
          </div>
          <div className="land-feature-card">
            <span className="land-feat-icon">🪞</span>
            <h4>True-to-Body Preview</h4>
            <p>AI aligns fabric to your exact body proportions for realistic output.</p>
          </div>
          <div className="land-feature-card">
            <span className="land-feat-icon">🗂️</span>
            <h4>Your Style Gallery</h4>
            <p>Every look you generate is saved — revisit, compare, and share anytime.</p>
          </div>
          <div className="land-feature-card">
            <span className="land-feat-icon">⚡</span>
            <h4>Under 10 Seconds</h4>
            <p>Fast GPU inference means you get results before you second-guess your pick.</p>
          </div>
        </div>
      </section>

      {/* ── BOTTOM CTA ── */}
      <section className="land-cta-strip">
        <h2>Ready to find your drape?</h2>
        <p>Join thousands of saree lovers who style smarter with AI.</p>
        <Link className="btn primary" to="/signup">Create Free Account</Link>
      </section>
    </div>
  );
}

function SignupPage() {
  const navigate = useNavigate();

  return (
    <section className="auth-page card">
      <h2>Create your account</h2>
      <p className="muted">Email signup with mocked Google OAuth.</p>
      <form
        className="stack"
        onSubmit={(e) => {
          e.preventDefault();
          navigate('/home');
        }}
      >
        <label>
          Full name
          <input required placeholder="Your name" />
        </label>
        <label>
          Email
          <input type="email" required placeholder="you@example.com" />
        </label>
        <label>
          Password
          <input type="password" required placeholder="********" />
        </label>
        <button className="btn primary" type="submit">
          Create Account
        </button>
      </form>
      <button className="btn outline" onClick={() => navigate('/home')}>
        Continue with Google (Mocked)
      </button>
      <p className="muted">
        Already have an account? <Link to="/login">Login</Link>
      </p>
    </section>
  );
}

function LoginPage() {
  const navigate = useNavigate();

  return (
    <section className="auth-page card">
      <h2>Welcome back</h2>
      <p className="muted">Access your saree catalogue and try-ons.</p>
      <form
        className="stack"
        onSubmit={(e) => {
          e.preventDefault();
          navigate('/home');
        }}
      >
        <label>
          Email
          <input type="email" required placeholder="you@example.com" />
        </label>
        <label>
          Password
          <input type="password" required placeholder="********" />
        </label>
        <button className="btn primary" type="submit">
          Login
        </button>
      </form>
      <p className="muted">
        New here? <Link to="/signup">Create account</Link>
      </p>
    </section>
  );
}

function CataloguePage() {
  const [fabric, setFabric] = useState('All');
  const [region, setRegion] = useState('All');
  const [search, setSearch] = useState('');

  const filtered = useMemo(() => {
    return sarees.filter((item) => {
      if (fabric !== 'All' && item.fabric !== fabric) return false;
      if (region !== 'All' && item.region !== region) return false;
      if (search && !item.name.toLowerCase().includes(search.toLowerCase())) {
        return false;
      }
      return true;
    });
  }, [fabric, region, search]);

  return (
    <div className="catalog-layout">
      <div className="list-head catalogue-head">
        <h2>Saree Catalogue</h2>
      </div>
      <aside className="filter-panel card">
        <h3>Filters</h3>
        <label>
          Search
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search sarees"
          />
        </label>
        <label>
          Fabric
          <select value={fabric} onChange={(e) => setFabric(e.target.value)}>
            <option>All</option>
            <option>Silk</option>
            <option>Cotton</option>
            <option>Georgette</option>
          </select>
        </label>
        <label>
          Region
          <select value={region} onChange={(e) => setRegion(e.target.value)}>
            <option>All</option>
            <option>Tamil Nadu</option>
            <option>Uttar Pradesh</option>
            <option>Gujarat</option>
            <option>Maharashtra</option>
            <option>Odisha</option>
          </select>
        </label>
      </aside>
      <section>
        <div className="catalog-grid">
          {filtered.map((item) => (
            <article className="saree-card card" key={item.id}>
              <div className="saree-image-placeholder" aria-label="Saree image placeholder">
                Image Placeholder
              </div>
              <div className="saree-card-content">
                <h3>{item.name}</h3>
                <p className="muted">
                  {item.region} | {item.fabric}
                </p>
                <p className="price">INR {item.price.toLocaleString('en-IN')}</p>
                <Link className="btn primary small" to={`/saree/${item.id}`}>
                  View Details
                </Link>
              </div>
            </article>
          ))}
        </div>
      </section>
    </div>
  );
}

function SareeDetailPage() {
  const { id } = useParams();
  const saree = sarees.find((s) => s.id === id) || sarees[0];
  const navigate = useNavigate();

  return (
    <div className="detail-wrap card">
      <img src={saree.imageUrl} alt={saree.name} className="detail-image" />
      <div>
        <h2>{saree.name}</h2>
        <p className="muted">
          {saree.region} | {saree.fabric}
        </p>
        <p>{saree.description}</p>
        <p className="price">INR {saree.price.toLocaleString('en-IN')}</p>
        <button
          className="btn primary"
          onClick={() => navigate(`/try-on/upload?sareeId=${saree.id}`)}
        >
          Try On
        </button>
      </div>
    </div>
  );
}

function TryOnUploadPage() {
  const [params] = useSearchParams();
  const [selectedSareeId, setSelectedSareeId] = useState(params.get('sareeId') ?? 's1');
  const [collectionMode, setCollectionMode] = useState<'collection' | 'upload'>('collection');
  const [selectedStyle, setSelectedStyle] = useState('Nivi Style');
  const [showStylistModal, setShowStylistModal] = useState(false);
  const [stylistMode, setStylistMode] = useState<'autonomous' | 'describe'>('autonomous');
  const [progress, setProgress] = useState(12);
  const [isApplying, setIsApplying] = useState(false);

  const selectedSaree = sarees.find((item) => item.id === selectedSareeId) || sarees[0];

  const drapeStyles = [
    'Nivi Style',
    'Bengali Style',
    'Nauvari/Kashta Style',
    'Gujarati Style',
    'Lehenga Style',
    'Butterfly/Mumtaz Style',
    'Madisar/Tamil Brahmin Style',
    'Kodagu/Coorg Style',
    'Gond/Tribal Style',
    'Kerala/Kasavu Style',
    'Rajasthani Style',
    'Seedha Pallu/Ulta Pallu',
    'Dhoti Style',
    'Pant Saree Style',
    'Mermaid/Fishtail Style',
    'Add Custom',
  ];

  const accessoryIdeas = [
    { name: 'Maang Tikka', place: 'Center of forehead' },
    { name: 'Nose Ring (Nath)', place: 'Left nostril' },
    { name: 'Bangles', place: 'Both wrists' },
    { name: 'Gajra', place: 'Wrapped around bun' },
    { name: 'Waist Belt', place: 'Over saree pleats' },
  ];

  const onApplyAiCouture = () => {
    if (isApplying) return;

    setIsApplying(true);
    setProgress(15);
    const timer = setInterval(() => {
      setProgress((value) => {
        if (value >= 100) {
          clearInterval(timer);
          setIsApplying(false);
          return 100;
        }
        return Math.min(value + 11, 100);
      });
    }, 340);
  };

  return (
    <section className="couture-page">
      <header className="couture-hero card">
        <div className="step-row">
          {[1, 2, 3, 4].map((step) => (
            <div className={`step-dot ${step === 1 ? 'active' : ''}`} key={step}>
              {step}
            </div>
          ))}
        </div>
        <h1>
          Drape Stories, Reimagined
          <em>For Your Own Glow.</em>
        </h1>
        <p>
          Build your look with signature drapes, curated fabric moods, and
          stylist-guided finishing touches in one creative studio.
        </p>
        <div className="hero-cta-row">
          <button className="btn gold">Upload Portrait</button>
          <button className="btn ghost">Open Camera</button>
        </div>
      </header>

      <article className="card couture-section">
        <h3>1. Choose Your Saree Base</h3>
        <div className="section-split">
          <div className="section-main">
            <div className="mode-switch">
              <button
                className={collectionMode === 'collection' ? 'active' : ''}
                onClick={() => setCollectionMode('collection')}
              >
                Curated Rack
              </button>
              <button
                className={collectionMode === 'upload' ? 'active' : ''}
                onClick={() => setCollectionMode('upload')}
              >
                Custom Upload
              </button>
            </div>

            {collectionMode === 'collection' ? (
              <>
                <div className="fabric-grid">
                  {sarees.slice(0, 4).map((item) => (
                    <button
                      key={item.id}
                      className={`fabric-card ${selectedSareeId === item.id ? 'active' : ''}`}
                      onClick={() => setSelectedSareeId(item.id)}
                    >
                      <span className="fabric-chip" />
                      <strong>{item.name}</strong>
                      <small>{item.fabric}</small>
                    </button>
                  ))}
                </div>
                <div className="custom-color-row">
                  <div>
                    <p className="muted">Custom Color</p>
                    <strong>Tune saree palette</strong>
                  </div>
                  <div className="color-swatches">
                    <span />
                    <span />
                  </div>
                </div>
              </>
            ) : (
              <div className="upload-own-grid">
                {['Body/Pattern', 'Border', 'Pallu'].map((slot) => (
                  <article className="upload-slot" key={slot}>
                    <div>Upload</div>
                    <small>{slot}</small>
                  </article>
                ))}
              </div>
            )}
          </div>

          <aside className="section-side selection-summary">
            <p className="muted">Selected Saree</p>
            <div className="saree-icon-placeholder">🪡</div>
            <h4>{selectedSaree.name}</h4>
            <p className="muted">
              {selectedSaree.region} | {selectedSaree.fabric}
            </p>
            <button className="btn outline small">Change Photo</button>
          </aside>
        </div>
      </article>

      <article className="card couture-section">
        <div className="list-head">
          <h3>2. Select Draping Direction</h3>
          <p className="muted">Pick a traditional flow or design your own</p>
        </div>
        <div className="section-split">
          <div className="section-main">
            <div className="style-grid">
              {drapeStyles.slice(0, 8).map((style) => (
                <button
                  key={style}
                  className={`style-card ${selectedStyle === style ? 'active' : ''}`}
                  onClick={() => setSelectedStyle(style)}
                >
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

      <section className="result-layout">
        <article className="card result-preview">
          <div className="progress-wrap">
            <div className="progress-track">
              <span style={{ width: `${progress}%` }} />
            </div>
            <strong>{progress}%</strong>
          </div>
          <img
            className="result-image"
            src="https://images.unsplash.com/photo-1602810319428-019690571b5b?auto=format&fit=crop&w=900&q=80"
            alt="AI drape output"
          />
          <div className="result-thumbs">
            {[1, 2, 3].map((item) => (
              <img
                key={item}
                src={selectedSaree.imageUrl}
                alt="variation"
              />
            ))}
          </div>
        </article>

        <aside className="card stylist-panel">
          <h4>Stylist Notes</h4>
          <p className="muted">
            This pairing balances rich texture with a soft vertical fall,
            giving you a refined silhouette with festive warmth.
          </p>
          <button className="btn gold" onClick={() => setShowStylistModal(true)}>
            Refine with Stylist
          </button>
          <button className="btn ghost">Adjust Render Settings</button>
          <div className="palette-row">
            <span />
            <span />
            <span />
            <span />
          </div>
          <button className="btn primary">Download Hero Shot</button>
          <button className="btn primary">Download Full Set</button>
          <button className="btn ghost">Share Lookbook</button>

          <div className="accessory-list">
            {accessoryIdeas.map((item) => (
              <article key={item.name}>
                <strong>{item.name}</strong>
                <p>{item.place}</p>
              </article>
            ))}
          </div>
        </aside>
      </section>

      {showStylistModal ? (
        <div className="stylist-modal-backdrop" role="presentation">
          <div className="stylist-modal card" role="dialog" aria-modal="true">
            <h3>Stylist Assist</h3>
            <p className="muted">Choose how you want to finalize this look.</p>
            <div className="stylist-options">
              <button
                className={stylistMode === 'autonomous' ? 'active' : ''}
                onClick={() => setStylistMode('autonomous')}
              >
                <strong>Auto Curate</strong>
                <span>Let the system suggest accessories and accents.</span>
              </button>
              <button
                className={stylistMode === 'describe' ? 'active' : ''}
                onClick={() => setStylistMode('describe')}
              >
                <strong>Guide Manually</strong>
                <span>Provide your preference notes for custom styling.</span>
              </button>
            </div>
            <div className="flow-actions">
              <button className="btn ghost" onClick={() => setShowStylistModal(false)}>
                Cancel
              </button>
              <button className="btn gold" onClick={() => setShowStylistModal(false)}>
                Apply
              </button>
            </div>
          </div>
        </div>
      ) : null}
    </section>
  );
}

function TryOnConfirmPage() {
  const navigate = useNavigate();
  const [params] = useSearchParams();
  const saree = sarees.find((s) => s.id === params.get('sareeId')) || sarees[0];
  const [drape, setDrape] = useState(72);
  const [texture, setTexture] = useState(65);

  return (
    <section className="card flow-wrap">
      <FlowHeader
        step={2}
        title="Confirm saree and fidelity"
        subtitle="POC-inspired AI controls"
      />
      <div className="confirm-grid">
        <article className="mini-panel">
          <h4>Selected Saree</h4>
          <img src={saree.imageUrl} alt={saree.name} className="mini-image" />
          <p>{saree.name}</p>
        </article>
        <article className="mini-panel">
          <h4>Preview Inputs</h4>
          <label>
            Drape Fidelity: {drape}%
            <input
              type="range"
              min={40}
              max={100}
              value={drape}
              onChange={(e) => setDrape(Number(e.target.value))}
            />
          </label>
          <label>
            Texture Accuracy: {texture}%
            <input
              type="range"
              min={40}
              max={100}
              value={texture}
              onChange={(e) => setTexture(Number(e.target.value))}
            />
          </label>
          <small className="muted">Higher values may increase processing time.</small>
        </article>
      </div>
      <div className="flow-actions">
        <button className="btn outline" onClick={() => navigate(-1)}>
          Back
        </button>
        <button
          className="btn primary"
          onClick={() => navigate(`/try-on/processing?sareeId=${saree.id}`)}
        >
          Generate Try-On
        </button>
      </div>
    </section>
  );
}

function TryOnProcessingPage() {
  const navigate = useNavigate();
  const [progress, setProgress] = useState(15);

  useEffect(() => {
    const timer = setInterval(() => {
      setProgress((p) => {
        if (p >= 100) {
          clearInterval(timer);
          setTimeout(() => navigate('/try-on/result?sareeId=s1'), 500);
          return 100;
        }
        return p + 12;
      });
    }, 650);
    return () => clearInterval(timer);
  }, [navigate]);

  return (
    <section className="card flow-wrap">
      <FlowHeader
        step={3}
        title="AI processing your drape"
        subtitle="Aligning silhouette and enhancing texture"
      />
      <div className="progress-wrap">
        <div className="progress-track">
          <span style={{ width: `${progress}%` }} />
        </div>
        <strong>{progress}%</strong>
      </div>
      <p className="muted">This is a mocked processing experience for milestone 1.</p>
    </section>
  );
}

function TryOnResultPage() {
  const [params] = useSearchParams();
  const saree = sarees.find((s) => s.id === params.get('sareeId')) || sarees[0];

  return (
    <section className="card flow-wrap">
      <FlowHeader
        step={4}
        title="Your try-on is ready"
        subtitle="Draped image output and sharing action"
      />
      <img
        className="result-image"
        src="https://images.unsplash.com/photo-1602810319428-019690571b5b?auto=format&fit=crop&w=900&q=80"
        alt="Draped result"
      />
      <p>
        <strong>Saree:</strong> {saree.name}
      </p>
      <div className="flow-actions">
        <button className="btn ghost">Share</button>
        <button className="btn primary">Purchase Saree</button>
      </div>
    </section>
  );
}

function MyGalleryPage() {
  const [items] = useState<TryOnResult[]>(galleryItems);

  return (
    <section>
      <div className="list-head">
        <h2>My Gallery</h2>
        <p className="muted">Mocked past try-on results</p>
      </div>
      <div className="gallery-grid">
        {items.map((item) => (
          <article className="card gallery-card" key={item.id}>
            <img src={item.imageUrl} alt={item.sareeName} />
            <h4>{item.sareeName}</h4>
            <p className="muted">{item.createdAt}</p>
          </article>
        ))}
      </div>
    </section>
  );
}

function CreditsBillingPage() {
  const [balance, setBalance] = useState(42);
  const [selected, setSelected] = useState<string>('b2');

  return (
    <section className="credits-page">
      <div className="card balance-card">
        <p className="muted">Credits Balance</p>
        <h2>{balance}</h2>
      </div>

      <div className="card">
        <h3>Choose a bundle</h3>
        <div className="bundle-grid">
          {bundles.map((bundle) => (
            <button
              key={bundle.id}
              className={`bundle ${selected === bundle.id ? 'active' : ''}`}
              onClick={() => setSelected(bundle.id)}
            >
              <strong>{bundle.label}</strong>
              <span>{bundle.credits} credits</span>
              <span>INR {bundle.price}</span>
            </button>
          ))}
        </div>
        <button
          className="btn primary"
          onClick={() =>
            setBalance((b) => b + bundles.find((bundle) => bundle.id === selected)!.credits)
          }
        >
          Pay with Stripe (Mocked)
        </button>
      </div>
    </section>
  );
}

function ProfileSettingsPage() {
  return (
    <section className="card profile-card">
      <h2>User Profile and Settings</h2>
      <label>
        Full Name
        <input defaultValue="Nabeel" />
      </label>
      <label>
        Email
        <input defaultValue="nabeel@example.com" />
      </label>
      <label>
        Default Draping Quality
        <select defaultValue="High">
          <option>Balanced</option>
          <option>High</option>
          <option>Ultra</option>
        </select>
      </label>
      <label className="toggle">
        <input type="checkbox" defaultChecked />Enable push notifications
      </label>
      <button className="btn primary">Save Settings</button>
    </section>
  );
}

function ErrorFallbackPage() {
  return (
    <section className="center-page card">
      <h2>Something went wrong</h2>
      <p className="muted">An unexpected issue occurred. Please retry or return home.</p>
      <Link className="btn primary" to="/home">
        Go Home
      </Link>
    </section>
  );
}

function NotFoundPage() {
  return (
    <section className="center-page card">
      <h2>404</h2>
      <p className="muted">The page you requested does not exist.</p>
      <Link className="btn primary" to="/">
        Back to Landing
      </Link>
    </section>
  );
}

function PortalLoginPage() {
  const navigate = useNavigate();
  return (
    <section className="auth-page card">
      <h2>Developer Portal Login</h2>
      <p className="muted">Mocked authentication for milestone shell.</p>
      <form
        className="stack"
        onSubmit={(e) => {
          e.preventDefault();
          navigate('/portal/dashboard');
        }}
      >
        <label>
          Email
          <input type="email" required />
        </label>
        <label>
          Password
          <input type="password" required />
        </label>
        <button className="btn primary" type="submit">
          Login
        </button>
      </form>
      <Link to="/portal/register" className="muted">
        Create portal account
      </Link>
    </section>
  );
}

function PortalRegisterPage() {
  const navigate = useNavigate();
  return (
    <section className="auth-page card">
      <h2>Register for Developer Portal</h2>
      <form
        className="stack"
        onSubmit={(e) => {
          e.preventDefault();
          navigate('/portal/dashboard');
        }}
      >
        <label>
          Company
          <input required />
        </label>
        <label>
          Work Email
          <input type="email" required />
        </label>
        <label>
          Password
          <input type="password" required />
        </label>
        <button className="btn primary" type="submit">
          Register
        </button>
      </form>
      <Link to="/portal/login" className="muted">
        Already registered? Login
      </Link>
    </section>
  );
}

function PortalDashboardPage() {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const points = [35, 52, 48, 70, 60, 80, 76];
  const maxVal = Math.max(...points);
  return (
    <section className="dashboard-page">
      <div className="list-head">
        <h2>Dashboard</h2>
        <Link className="btn gold small" to="/try-on/upload">
          AI Try-On
        </Link>
      </div>
      <div className="stat-grid">
        <div className="card stat-card">
          <p className="muted">Total API Calls</p>
          <h2>12,480</h2>
          <span className="stat-badge up">+8% this week</span>
        </div>
        <div className="card stat-card">
          <p className="muted">Credits Remaining</p>
          <h2>3,200</h2>
          <span className="stat-badge">Active plan</span>
        </div>
        <div className="card stat-card">
          <p className="muted">Try-Ons Generated</p>
          <h2>847</h2>
          <span className="stat-badge up">+23 today</span>
        </div>
        <div className="card stat-card">
          <p className="muted">Active API Keys</p>
          <h2>2</h2>
          <span className="stat-badge">1 revoked</span>
        </div>
      </div>
      <div className="card">
        <p className="muted" style={{ marginBottom: 12 }}>API Calls — Last 7 Days</p>
        <div className="chart-box">
          {points.map((v, i) => (
            <div key={`col-${i}`} className="bar-col">
              <div
                className="bar"
                style={{ height: `${(v / maxVal) * 100}%` }}
                title={`${days[i]}: ${v * 15} calls`}
              />
              <span className="bar-label">{days[i]}</span>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

function PortalApiKeysPage() {
  const [keys, setKeys] = useState<ApiKey[]>(seedApiKeys);

  return (
    <section>
      <div className="list-head">
        <h2>API Keys</h2>
        <button
          className="btn primary small"
          onClick={() =>
            setKeys((all) => [
              {
                id: `k${all.length + 1}`,
                name: `New Key ${all.length + 1}`,
                value: `sdai_live_${Math.random().toString(36).slice(2, 10)}`,
                createdAt: '2026-03-13',
                status: 'active',
              },
              ...all,
            ])
          }
        >
          Create Key
        </button>
      </div>
      <div className="card table-card">
        {keys.map((key) => (
          <article className="key-row" key={key.id}>
            <div>
              <strong>{key.name}</strong>
              <p className="muted">{key.value}</p>
            </div>
            <div className="key-actions">
              <span className={`status ${key.status}`}>{key.status}</span>
              <button
                className="btn ghost small"
                onClick={() =>
                  setKeys((all) =>
                    all.map((item) =>
                      item.id === key.id ? { ...item, status: 'revoked' } : item,
                    ),
                  )
                }
              >
                Revoke
              </button>
            </div>
          </article>
        ))}
      </div>
    </section>
  );
}

function PortalWebhooksPage() {
  return (
    <section className="card">
      <h2>Webhook Configuration</h2>
      <label>
        Endpoint URL
        <input placeholder="https://example.com/webhooks/tryon" />
      </label>
      <label>
        Secret
        <input placeholder="whsec_xxx" />
      </label>
      <label>
        Events
        <select defaultValue="tryon.completed">
          <option value="tryon.completed">tryon.completed</option>
          <option value="credits.debited">credits.debited</option>
        </select>
      </label>
      <button className="btn primary">Save Webhook</button>
    </section>
  );
}

function PortalBillingPage() {
  return (
    <section className="card">
      <h2>Portal Billing and Credits</h2>
      <p className="muted">Manage organization-level credit plans and invoices.</p>
      <div className="bundle-grid">
        <div className="bundle active">
          <strong>Team Pro</strong>
          <span>500 credits</span>
          <span>INR 8,999</span>
        </div>
        <div className="bundle">
          <strong>Enterprise</strong>
          <span>2,000 credits</span>
          <span>INR 29,999</span>
        </div>
      </div>
      <button className="btn primary">Proceed to Stripe (Mocked)</button>
    </section>
  );
}

function PortalDocsPage() {
  return (
    <section className="docs-wrap">
      <aside className="card docs-nav">
        <h4>Documentation</h4>
        <a href="#">Getting Started</a>
        <a href="#">Authentication</a>
        <a href="#">Try-On API</a>
        <a href="#">Credits API</a>
        <a href="#">Webhook Events</a>
      </aside>
      <article className="card docs-content">
        <h2>API Reference Layout</h2>
        <p className="muted">Developer documentation shell for milestone 1.</p>
        <pre>{`POST /v1/tryon/jobs\nAuthorization: Bearer <api_key>\nContent-Type: multipart/form-data`}</pre>
      </article>
    </section>
  );
}

function FlowHeader({
  step,
  title,
  subtitle,
}: {
  step: number;
  title: string;
  subtitle: string;
}) {
  return (
    <header>
      <p className="pill">Step {step}</p>
      <h2>{title}</h2>
      <p className="muted">{subtitle}</p>
    </header>
  );
}

export default App;
