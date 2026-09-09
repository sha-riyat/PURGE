import { HugeiconsIcon } from "@hugeicons/react";
import {
  ArrowDown01Icon,
  ArrowRight01Icon,
  ArrowUpRight01Icon,
  CheckListIcon,
  CheckmarkCircle02Icon,
  Delete02Icon,
  Download04Icon,
  FileCheckIcon,
  LockKeyholeIcon,
  Refresh04Icon,
  Settings01Icon,
} from "@hugeicons/core-free-icons";
import { Badge } from "@/components/ui/badge";
import { buttonVariants } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { MotionScroll } from "@/components/motion-scroll";
import { cn } from "@/lib/utils";

type Icon = typeof Delete02Icon;

const useSteps: { number: string; icon: Icon; title: string; text: string }[] = [
  { number: "01", icon: Download04Icon, title: "Télécharger", text: "Téléchargez le paquet et extrayez-le dans un dossier." },
  { number: "02", icon: FileCheckIcon, title: "Lancer", text: "Ouvrez Purge.cmd, puis acceptez la demande UAC." },
  { number: "03", icon: LockKeyholeIcon, title: "Confirmer", text: "Dans la fenêtre, écrivez exactement NETTOYER." },
  { number: "04", icon: Refresh04Icon, title: "Réinitialiser", text: "Dans Windows, choisissez Réinitialiser ce PC puis Supprimer tout." },
];

function Logo() {
  return (
    <a href="#top" className="logo" aria-label="PURGE, accueil">
      <span className="logo-mark" aria-hidden="true">
        <HugeiconsIcon icon={Delete02Icon} size={19} strokeWidth={2} />
      </span>
      <span>PURGE</span>
    </a>
  );
}

function IconBox({ icon }: { icon: Icon }) {
  return (
    <span className="icon-box" aria-hidden="true">
      <HugeiconsIcon icon={icon} size={20} strokeWidth={1.8} />
    </span>
  );
}

export default function Home() {
  return (
    <main id="top" className="site-shell">
      <div className="ambient ambient-one" aria-hidden="true" />
      <div className="ambient ambient-two" aria-hidden="true" />
      <MotionScroll />

      <header className="site-header container-wide">
        <Logo />
        <nav className="desktop-nav" aria-label="Navigation principale">
          <a href="#utiliser">Utiliser</a>
          <a href="#apres">Après</a>
          <a href="#telecharger">Télécharger</a>
        </nav>
        <a className={cn(buttonVariants({ variant: "outline", size: "sm" }), "header-cta")} href="#utiliser">
          Commencer <HugeiconsIcon icon={ArrowRight01Icon} size={16} strokeWidth={1.8} />
        </a>
      </header>

      <section className="hero container-wide" aria-labelledby="hero-title">
        <div className="hero-copy">
          <h1 id="hero-title">
            Nettoyez un PC Windows.
            <span>Remettez-le à zéro.</span>
          </h1>
          <p className="hero-lede">Un parcours court pour vérifier, confirmer et réinitialiser Windows.</p>
          <div className="hero-actions">
            <a className={cn(buttonVariants({ size: "lg" }), "button-primary")} href="#telecharger">
              Télécharger PURGE <HugeiconsIcon icon={Download04Icon} size={18} />
            </a>
            <a className={cn(buttonVariants({ variant: "ghost", size: "lg" }), "button-quiet")} href="#utiliser">
              Voir les étapes <HugeiconsIcon icon={ArrowDown01Icon} size={18} />
            </a>
          </div>
        </div>

        <div className="hero-panel-wrap" aria-label="Aperçu du parcours PURGE">
          <div className="hero-panel-glow" aria-hidden="true" />
          <Card className="status-card">
            <div className="status-card-top">
              <span className="terminal-label"><span className="terminal-dot" /> PURGE / SESSION</span>
              <Badge className="ready-badge">READY</Badge>
            </div>
            <div className="status-machine">
              <div><span className="meta-label">MACHINE</span><strong>PC-WIN-042</strong></div>
              <div className="machine-state"><span className="pulse-dot" /> En cours</div>
            </div>
            <div className="progress-track"><span /></div>
            <div className="status-list">
              <div className="status-row done"><span className="row-icon"><HugeiconsIcon icon={CheckmarkCircle02Icon} size={17} /></span><span>Windows</span><b>OK</b></div>
              <div className="status-row done"><span className="row-icon"><HugeiconsIcon icon={CheckmarkCircle02Icon} size={17} /></span><span>Droits admin</span><b>OK</b></div>
              <div className="status-row active"><span className="row-icon"><HugeiconsIcon icon={Settings01Icon} size={17} /></span><span>Réinitialisation</span><b>...</b></div>
              <div className="status-row muted"><span className="row-icon"><HugeiconsIcon icon={CheckListIcon} size={17} /></span><span>Écran initial</span><b>—</b></div>
            </div>
            <div className="status-footer"><span>STATUS</span><strong>RESET_PENDING</strong><span className="footer-time">12:04:31 UTC</span></div>
          </Card>
          <div className="floating-chip chip-report"><HugeiconsIcon icon={FileCheckIcon} size={17} /> rapport.json</div>
          <div className="floating-chip chip-secure"><HugeiconsIcon icon={LockKeyholeIcon} size={17} /> UAC</div>
        </div>
      </section>

      <section id="utiliser" className="section container-wide use-section" aria-labelledby="use-title">
        <div className="section-heading">
          <div><h2 id="use-title">Lancer PURGE.<br /><em>Réinitialiser Windows.</em></h2></div>
          <p>Les quatre actions à faire, dans l’ordre.</p>
        </div>
        <div className="use-layout">
          <div className="use-steps">
            {useSteps.map((step) => (
              <article className="use-step" key={step.number}>
                <span className="use-step-number">{step.number}</span>
                <div className="use-step-copy">
                  <div className="use-step-title"><IconBox icon={step.icon} /><h3>{step.title}</h3></div>
                  <p>{step.text}</p>
                </div>
              </article>
            ))}
          </div>

          <div className="operator-console" aria-label="Exemple de commande et d'écran Windows">
            <div className="console-block">
              <div className="console-bar"><span className="terminal-circles"><i /><i /><i /></span><span>Purge.cmd</span><span className="terminal-path">C:\PURGE</span></div>
              <div className="console-body">
                <p><span className="terminal-muted">PS C:\PURGE&gt;</span> .\Purge.cmd</p>
                <p className="terminal-muted">Vérification...</p>
                <p><span className="console-status">OK</span> Windows 11 · 64 bits</p>
                <p><span className="console-status">OK</span> Droits admin</p>
                <p><span className="console-action">ACTION</span> Écrire : <b>NETTOYER</b></p>
              </div>
            </div>
            <div className="console-block recovery-block">
              <span className="console-label">WINDOWS / RÉCUPÉRATION</span>
              <p className="recovery-line">Réinitialiser ce PC <span>›</span></p>
              <p className="recovery-line">Supprimer tout <span>›</span></p>
              <p className="recovery-note">Activer le nettoyage des données si Windows le propose.</p>
            </div>
          </div>
        </div>
      </section>

      <section id="apres" className="section section-dark after-section" aria-labelledby="after-title">
        <div className="container-wide">
          <div className="section-heading section-heading-light">
            <div><h2 id="after-title">Ce qui se passe<br /><em>après.</em></h2></div>
            <p>PURGE s’arrête avant la configuration du prochain utilisateur.</p>
          </div>
          <div className="state-grid">
            <article className="state-card"><span>01</span><strong>RESET_PENDING</strong><p>La confirmation est reçue. Windows ouvre Récupération.</p></article>
            <article className="state-card"><span>02</span><strong>Redémarrage</strong><p>Windows applique la remise à zéro et redémarre automatiquement.</p></article>
            <article className="state-card"><span>03</span><strong>Écran initial</strong><p>L’ordinateur revient à la première configuration Windows.</p></article>
          </div>
        </div>
      </section>

      <section id="telecharger" className="download-section" aria-labelledby="download-title">
        <div className="container-wide download-card">
          <div className="download-copy"><h2 id="download-title">Prêt à lancer ?</h2><p>Téléchargez, extrayez le paquet, puis ouvrez <code>Purge.cmd</code>.</p></div>
          <div className="download-actions"><a className={cn(buttonVariants({ size: "lg" }), "button-primary")} href="/downloads/purge-windows.zip" download>Télécharger <HugeiconsIcon icon={Download04Icon} size={18} /></a></div>
        </div>
      </section>

      <footer className="site-footer container-wide">
        <Logo />
        <span>Windows · remise à zéro · rapport local</span>
        <a href="#top">Retour en haut <HugeiconsIcon icon={ArrowUpRight01Icon} size={15} /></a>
      </footer>
    </main>
  );
}
