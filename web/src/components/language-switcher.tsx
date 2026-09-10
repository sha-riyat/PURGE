"use client";

import { useLocale, useTranslations } from "next-intl";
import { Link } from "@/i18n/navigation";
import { routing } from "@/i18n/routing";

export function LanguageSwitcher() {
  const locale = useLocale();
  const t = useTranslations("Navigation");

  return (
    <div className="language-switcher" aria-label={t("language")}>
      {routing.locales.map((targetLocale) => (
        <Link
          key={targetLocale}
          href="/"
          locale={targetLocale}
          className={locale === targetLocale ? "language-option active" : "language-option"}
          aria-current={locale === targetLocale ? "page" : undefined}
        >
          {targetLocale.toUpperCase()}
        </Link>
      ))}
    </div>
  );
}
