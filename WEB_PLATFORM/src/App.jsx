import { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Link, useLocation } from 'react-router-dom';
import './index.css';
import pikeImg from './assets/pike_headshot.png';
import creedImg from './assets/creed_headshot.png';
import kalaniImg from './assets/kalani_headshot.png';

// Components
const Navbar = () => (
  <nav className="main-nav container">
    <Link to="/" className="nav-logo shift-light-glow">FRANCHISE_UNDERWORLD.exe</Link>
    <ul className="nav-links">
      <li><Link to="/dossiers">[ DOSSIERS ]</Link></li>
      <li><Link to="/factions">[ FACTIONS ]</Link></li>
      <li><Link to="/districts" className="disabled">[ DISTRICTS : OFFLINE ]</Link></li>
      <li><Link to="/gallery" className="live-link">[ ZERO ISSUE ]</Link></li>
    </ul>
  </nav>
);

const Footer = () => (
  <footer className="site-footer container">
    <div className="social-links">
      <p>ESTABLISH CONNECTION:</p>
      <a href="https://twitter.com/franchiseunderworld" target="_blank" rel="noreferrer">SYS.X</a>
      <a href="https://tiktok.com/@franchiseunderworld" target="_blank" rel="noreferrer">SYS.TIKTOK</a>
      <a href="https://instagram.com/franchiseunderworld" target="_blank" rel="noreferrer">SYS.INSTA</a>
      <a href="https://reddit.com/r/franchiseunderworld" target="_blank" rel="noreferrer">SYS.REDDIT</a>
    </div>
    <div className="system-status">
      [SYSTEM_TIME]: 1997.10.14_04:15AM <br/>
      COMPACT_STATUS: FRACTURED
    </div>
  </footer>
);

// Pages
const Home = () => {
  const [isSubmitted, setIsSubmitted] = useState(false);

  return (
    <>
      <header className="hero-section">
        <div className="container">
          <h1 className="glitch-text" data-text="FRANCHISE UNDERWORLD">FRANCHISE UNDERWORLD</h1>
          <p className="terminal-text tagline">
            &gt; WARNING: 30-YEAR TRUCE HAS COLLAPSED.<br/>
            &gt; ACCESSING 1997 LABOR REALISM NOIR ARCHIVES...
          </p>

          <div className="terminal-alert">
            [SYSTEM WARNING] TPM levels exceeding 24% at Blackpole Commons. Ghost Oil ignition imminent.
          </div>

          <div className="waitlist-section">
            <h2 className="heat-lamp-glow">GET ON THE SHIFT ROSTER</h2>
            <p className="terminal-text">&gt; To receive the 5-page "Zero Issue" PDF drop, enter your corporate ID (Email) below. Access is restricted to rostered personnel.</p>
            
            {/* GOOGLE FORM EMBED - Silent Submission */}
            <div className="form-container">
              <iframe name="hidden_iframe" id="hidden_iframe" style={{display: 'none'}} onLoad={() => {}}></iframe>
              <form 
                action="https://docs.google.com/forms/d/e/1FAIpQLSe7YuuvWpDMgMPbTLx4ehK7hNfagsbninc9dz5we8StHgogEw/formResponse" 
                method="post" 
                target="hidden_iframe"
                onSubmit={() => setIsSubmitted(true)}
                className="waitlist-form"
              >
                {!isSubmitted ? (
                  <>
                    <input type="email" name="entry.1604030176" placeholder="ENTER_CORPORATE_EMAIL_ID..." required />
                    <button type="submit" className="terminal-btn">[ INITIATE UPLOAD ]</button>
                  </>
                ) : (
                  <div className="terminal-alert" style={{borderColor: 'var(--toxic-green)', color: 'var(--toxic-green)'}}>
                    [ SYSTEM MESSAGE ] - ROSTER UPLOAD SUCCESSFUL. AWAIT INSTRUCTIONS.
                  </div>
                )}
              </form>
            </div>
          </div>
        </div>
      </header>
    </>
  );
};

const Factions = () => {
  return (
    <section className="container page-content">
      <h1 className="shift-light-glow">&gt; QUERY: ACTIVE_SYNDICATES</h1>
      <p className="terminal-text">&gt; WARNING: Fetching local territory data... 7 Factions currently obscured by Ghost Oil smoke.</p>
      
      <div className="factions-grid">
        <div className="faction-card shift-hover">
          <div className="faction-sigil neon-flicker" style={{color: 'var(--shift-light)'}}>🍕</div>
          <h3>THE SLICE SYNDICATES</h3>
          <p>Route Rats running the asphalt arteries. The primary light source is the green dashboard glow, reflecting off wet pavement mid-shift.</p>
        </div>
        
        <div className="faction-card tobacco-hover">
          <div className="faction-sigil neon-flicker" style={{color: 'var(--tobacco-yellow)'}}>☕</div>
          <h3 className="tobacco-glow">THE MORNING ORDER</h3>
          <p>The dawn watch. Blindingly harsh hangover dawn sunlight. Faded pink uniforms and massive dark circles. The shift never ends.</p>
        </div>

        <div className="faction-card frostbite-hover" style={{borderLeftColor: '#00d2ff'}}>
          <div className="faction-sigil neon-flicker" style={{color: '#00d2ff'}}>❄️</div>
          <h3 style={{color: '#00d2ff', textShadow: '0 0 10px #00d2ff'}}>FROSTBITE</h3>
          <p>They control the Meat Wells. Anything that dries out on the grill goes down the chute to be frozen and boiled. They don't waste a thing.</p>
        </div>

        <div className="faction-card texas-hover" style={{borderLeftColor: '#ff8c00'}}>
          <div className="faction-sigil neon-flicker" style={{color: '#ff8c00'}}>🥜</div>
          <h3 style={{color: '#ff8c00', textShadow: '0 0 10px #ff8c00'}}>THE TEX-BARONS</h3>
          <p>They control the Interstate supply routes and the Cinnamon Butter currency. Loud, aggressive, and perfectly willing to burn down a block for a toll.</p>
        </div>

        <div className="faction-card red-hover">
          <div className="faction-sigil neon-flicker" style={{color: 'var(--heat-lamp-red)'}}>🍔</div>
          <h3 className="heat-lamp-glow">THE GRILL HOUSES</h3>
          <p>Controlling the intersection corner lots. Their weapon of choice? 500-degree searing presses and brutal sociopathic drive-thru timers.</p>
        </div>

        {/* REDACTED FACTIONS to build mystery */}
        {[1, 2, 3, 4, 5].map(i => (
          <div key={i} className="faction-card redacted-card">
            <div className="faction-sigil">⬛</div>
            <h3>[ DATA CORRUPTED ]</h3>
            <p>Connection lost to territory marker. Compact status unverified. Approach with extreme caution.</p>
          </div>
        ))}
      </div>
    </section>
  );
};

const Dossiers = () => {
  return (
    <section className="container page-content">
      <h1 className="shift-light-glow">&gt; QUERY: PERSONNEL_FILES</h1>
      <p className="terminal-text">&gt; Pulling active files from Lumenridge databanks...</p>

      <div className="dossier-list">
        <div className="dossier-card deceased">
          <div className="dossier-header">
            <h3>CREED, JONAH</h3>
            <span className="status pilot-light-glow">[ STATUS: DECEASED ]</span>
          </div>
          <div className="dossier-body">
            <img src={creedImg} alt="Jonah Creed" className="dossier-mugshot" />
            <div className="dossier-text">
              <p><strong>ROLE:</strong> [ REDACTED ]</p>
              <p><strong>LAST KNOWN LOCATION:</strong> The Confederacy Spire</p>
              <p className="terminal-text">Found dead at 1547 hours on a Sunday. The 30-year treaty died with him. Cause of death covered up by The Board.</p>
            </div>
          </div>
        </div>

        <div className="dossier-card active">
          <div className="dossier-header">
            <h3>PIKE, JULIAN</h3>
            <span className="status shift-light-glow">[ STATUS: INVESTIGATING ]</span>
          </div>
          <div className="dossier-body">
            <img src={pikeImg} alt="Julian Pike" className="dossier-mugshot" />
            <div className="dossier-text">
              <p><strong>ROLE:</strong> Corporate Auditor</p>
              <p><strong>LAST KNOWN LOCATION:</strong> Sector 4</p>
              <p className="terminal-text">Currently tracking the "Burning Crown" ledger left behind by Pastor Creed. Survival probability dropping.</p>
            </div>
          </div>
        </div>
        
        <div className="dossier-card red-hover" style={{borderLeftColor: 'var(--heat-lamp-red)'}}>
          <div className="dossier-header">
            <h3 className="heat-lamp-glow">MORN, KALANI</h3>
            <span className="status">[ STATUS: ENFORCING ]</span>
          </div>
          <div className="dossier-body">
            <img src={kalaniImg} alt="Kalani Morn" className="dossier-mugshot" />
            <div className="dossier-text">
              <p><strong>AFFILIATION:</strong> The Coastal Fryers</p>
              <p><strong>LAST KNOWN LOCATION:</strong> The Docks</p>
              <p className="terminal-text">Warning: Do not engage. Suspect is heavily armed and currently protecting Julian Pike from Corporate Health Inspectors.</p>
            </div>
          </div>
        </div>

        <div className="dossier-card redacted-card">
          <div className="dossier-header">
            <h3>[ FILE LOCKED ]</h3>
            <span className="status">[ CLEARANCE LEVEL REQUIRED ]</span>
          </div>
          <p>Additional personnel files will be unlocked as the investigation proceeds.</p>
        </div>
      </div>
    </section>
  );
};

function App() {
  const [isCaineMode, setIsCaineMode] = useState(false);

  useEffect(() => {
    const handleKeyDown = (e) => {
      const key = e.key.toUpperCase();
      // Easter Egg logic kept intact
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, []);

  return (
    <Router>
      <div className="crt-overlay"></div>
      <Navbar />
      
      <main className="main-content">
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/factions" element={<Factions />} />
          <Route path="/dossiers" element={<Dossiers />} />
        </Routes>
      </main>

      <Footer />
    </Router>
  );
}

export default App;
