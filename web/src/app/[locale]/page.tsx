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
import { useTranslations } from "next-intl";
import { Badge } from "@/components/ui/badge";
import { buttonVariants } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { LanguageSwitcher } from "@/components/language-switcher";
import { MotionScroll } from "@/components/motion-scroll";
import { cn } from "@/lib/utils";

type Icon = typeof Delete02Icon;

function Logo({ label }: { label: string }) {
  return (
    <a href="#top" className="logo" aria-label={label}>
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
  const t = useTranslations();
  const useSteps: { number: string; icon: Icon; title: string; text: string }[] = [
    { number: "01", icon: Download04Icon, title: t("Use.stepDownload"), text: t("Use.stepDownloadText") },
    { number: "02", icon: FileCheckIcon, title: t("Use.stepLaunch"), text: t("Use.stepLaunchText") },
    { number: "03", icon: LockKeyholeIcon, title: t("Use.stepConfirm"), text: t("Use.stepConfirmText") },
    { number: "04", icon: Refresh04Icon, title: t("Use.stepReset"), text: t("Use.stepResetText") },
  ];

  return (
    <main id="top" className="site-shell">
      <div className="ambient ambient-one" aria-hidden="true" />
      <div className="ambient ambient-two" aria-hidden="true" />
      <MotionScroll />

      <header className="site-header container-wide">
        <Logo label={t("Navigation.home")} />
        <nav className="desktop-nav" aria-label={t("Navigation.primary")}>
          <a href="#utiliser">{t("Navigation.use")}</a>
          <a href="#apres">{t("Navigation.after")}</a>
          <a href="#telecharger">{t("Navigation.download")}</a>
        </nav>
        <div className="header-actions">
          <LanguageSwitcher />
          <a className={cn(buttonVariants({ variant: "outline", size: "sm" }), "header-cta")} href="#utiliser">
            {t("Navigation.start")} <HugeiconsIcon icon={ArrowRight01Icon} size={16} strokeWidth={1.8} />
          </a>
        </div>
      </header>

      <section className="hero container-wide" aria-labelledby="hero-title">
        <div className="hero-copy">
          <h1 id="hero-title">
            {t("Hero.titleLine1")}
            <span>{t("Hero.titleLine2")}</span>
          </h1>
          <p className="hero-lede">{t("Hero.lede")}</p>
          <div className="hero-actions">
            <a className={cn(buttonVariants({ size: "lg" }), "button-primary")} href="#telecharger">
              {t("Hero.download")} <HugeiconsIcon icon={Download04Icon} size={18} />
            </a>
            <a className={cn(buttonVariants({ variant: "ghost", size: "lg" }), "button-quiet")} href="#utiliser">
              {t("Hero.steps")} <HugeiconsIcon icon={ArrowDown01Icon} size={18} />
            </a>
          </div>
        </div>

        <div className="hero-panel-wrap" aria-label={t("Hero.preview")}>
          <div className="hero-panel-glow" aria-hidden="true" />
          <Card className="status-card">
            <div className="status-card-top">
              <span className="terminal-label"><span className="terminal-dot" /> PURGE / SESSION</span>
              <Badge className="ready-badge">READY</Badge>
            </div>
            <div className="status-machine">
              <div><span className="meta-label">{t("Hero.machine")}</span><strong>PC-WIN-042</strong></div>
              <div className="machine-state"><span className="pulse-dot" /> {t("Hero.machineState")}</div>
            </div>
            <div className="progress-track"><span /></div>
            <div className="status-list">
              <div className="status-row done"><span className="row-icon"><HugeiconsIcon icon={CheckmarkCircle02Icon} size={17} /></span><span>{t("Hero.windows")}</span><b>OK</b></div>
              <div className="status-row done"><span className="row-icon"><HugeiconsIcon icon={CheckmarkCircle02Icon} size={17} /></span><span>{t("Hero.adminRights")}</span><b>OK</b></div>
              <div className="status-row active"><span className="row-icon"><HugeiconsIcon icon={Settings01Icon} size={17} /></span><span>{t("Hero.reset")}</span><b>...</b></div>
              <div className="status-row muted"><span className="row-icon"><HugeiconsIcon icon={CheckListIcon} size={17} /></span><span>{t("Hero.initialScreen")}</span><b>—</b></div>
            </div>
            <div className="status-footer"><span>STATUS</span><strong>RESET_PENDING</strong><span className="footer-time">12:04:31 UTC</span></div>
          </Card>
          <div className="floating-chip chip-report"><HugeiconsIcon icon={FileCheckIcon} size={17} /> {t("Hero.report")}</div>
          <div className="floating-chip chip-secure"><HugeiconsIcon icon={LockKeyholeIcon} size={17} /> UAC</div>
        </div>
      </section>

      <section id="utiliser" className="section container-wide use-section" aria-labelledby="use-title">
        <div className="section-heading">
          <div><h2 id="use-title">{t("Use.titleLine1")}<br /><em>{t("Use.titleLine2")}</em></h2></div>
          <p>{t("Use.summary")}</p>
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

          <div className="operator-console" aria-label={t("Use.consoleLabel")}>
            <div className="console-block">
              <div className="console-bar"><span className="terminal-circles"><i /><i /><i /></span><span>Purge.cmd</span><span className="terminal-path">C:\PURGE</span></div>
              <div className="console-body">
                <p><span className="terminal-muted">PS C:\PURGE&gt;</span> .\Purge.cmd</p>
                <p className="terminal-muted">{t("Use.checking")}</p>
                <p><span className="console-status">OK</span> Windows 11 · 64 bits</p>
                <p><span className="console-status">OK</span> {t("Use.admin")}</p>
                <p><span className="console-status">OK</span> {t("Use.scope")}</p>
                <p><span className="console-action">{t("Use.action")}</span> {t("Use.type")} <b>NETTOYER TOUS LES DISQUES</b></p>
              </div>
            </div>
            <div className="console-block recovery-block">
              <span className="console-label">{t("Use.recovery")}</span>
              <p className="recovery-line">{t("Use.resetThisPc")} <span>›</span></p>
              <p className="recovery-line">{t("Use.removeEverything")} <span>›</span></p>
              <p className="recovery-line">{t("Use.allDrives")} <span>›</span></p>
              <p className="recovery-note">{t("Use.cleanData")}</p>
              <p className="recovery-note">{t("Use.externalMedia")}</p>
            </div>
          </div>
        </div>
      </section>

      <section id="apres" className="section section-dark after-section" aria-labelledby="after-title">
        <div className="container-wide">
          <div className="section-heading section-heading-light">
            <div><h2 id="after-title">{t("After.titleLine1")}<br /><em>{t("After.titleLine2")}</em></h2></div>
            <p>{t("After.summary")}</p>
          </div>
          <div className="state-grid">
            <article className="state-card"><span>01</span><strong>RESET_PENDING</strong><p>{t("After.resetPending")}</p></article>
            <article className="state-card"><span>02</span><strong>{t("After.restart")}</strong></article>
            <article className="state-card"><span>03</span><strong>{t("Hero.initialScreen")}</strong><p>{t("After.initialScreen")}</p></article>
          </div>
        </div>
      </section>

      <section id="telecharger" className="download-section" aria-labelledby="download-title">
        <div className="container-wide download-card">
          <div className="download-copy"><h2 id="download-title">{t("Download.title")}</h2><p>{t("Download.description")} <code>Purge.cmd</code>.</p></div>
          <div className="download-actions"><a className={cn(buttonVariants({ size: "lg" }), "button-primary")} href="/downloads/purge-windows.zip" download>{t("Download.button")} <HugeiconsIcon icon={Download04Icon} size={18} /></a></div>
        </div>
      </section>

      <footer className="site-footer container-wide">
        <Logo label={t("Navigation.home")} />
        <span>{t("Footer.summary")}</span>
        <a href="#top">{t("Footer.backToTop")} <HugeiconsIcon icon={ArrowUpRight01Icon} size={15} /></a>
      </footer>
    </main>
  );
}
